---
title:    How I Manage The Configuration of My Environment
layout:   post
comments: true
tags:     dotfiles config
---

> Like many people I have an automated scheme for setting up a new
> machine. My students have bugged me to write it up.

I want to be able to work on any machine: if a computer dies (as my MBP
did when I filled it with iced tea) I need to be able to set up a
replacement in minutes and get productive again. I also need to be able
to do this across different operating systems.[^fn-os]

[^fn-os]: Right now I mostly use Linux, but many of my presentations are
  in Keynote, so I still bring out the Macbook Air for those.

There are three components to making this work:

1. Making sure I don't rely on any data on a particular machine. If an
   SSD dies, I need to be able to continue working on another computer with minimal data
   loss.

2. Having the tools I need (editors, languages, etc) installed.

3. Having all the configuration for these tools sharable between
   machines, regardless of the environment on which they run.

## Location Independent Data

I make a habit of keeping _all_ work products in version control, and
pushing them offsite when I reach the point where I'd feel annoyed if I
accidentally lost the local copy.

Right now, it's all in git, and it's stored on GitHub. I have a cheap
monthly plan that gives me plenty of storage for my hundreds of private
repos. Thank you GitHub.

There's one exception to this rule. I tried storing the video assets for
my screencasts and courses on Github. It works, and the large file support
at GitHub handles them. But they are big: my Elixir course has about
80Gb of assets, and life's too short to be cloning that much data.
Instead, I have a separate headless Git repos on two external SSDs, and
I check the assets into them. One SSD gets stored offsite, and the other is
in our fireproof box.

I'd welcome suggestions on better ways of managing these.

## Tools and Configuration

In the past I treated these two areas separately. I'd have a script that
installed things I needed (typically using Homebrew and apt-get) and a
sparse repo containing dotfiles.

But this was never particularly convenient. I'd forget to update stuff,
on only update the Linux version and let the Mac version languish. So
something needed to be done.

There are roughly a billion dotfile management systems out
there.[^fn-billion] I spent a while evaluating the different
approaches, and couldn't find one that worked for me. So (and you knew
this was coming) I wrote my own. But it's trivial.

[^fn-billion]: I saw that on the internet, so it must be true.

I have a single Git repo (called `dotfiles`) which manages all the stuff
I need to install and configure. Inside this theres a separate directory
for each tool or set of tools I need to install and configure. For
example, my current `dotfiles` looks like this:

~~~
/home/dave/dotfiles/
├── dotfiles.rb
├── elixir
├── emacs
├── fish
├── fonts
├── git
 :  :
├── ssh
├── tmux
├── ubuntu-setup
└── vscode
~~~

Inside each directory there's a script named `install.rb`. This is
responsible for

* installing the appropriate software
* customizing the configuration for the current environment
* creating a symlink from the place where the app expects to find the
  configuration to the customized configuration insid `dotfiles`.

These `install.rb` files use the library `dotfiles.rb` (the first file
in the previous directory listing), so they're pretty high-level. The
source of `dotfiles.rb` is at the end of this post.

### Example: tmux installation and configuration

TMUX doesn't require much magic: we just install the binary, and then
setup links in our home directory to the config (`~/.tmux.conf`) and a
directory containing our plugins (so they'll be avaiable on all my
boxes).

Here's the `tmux/install.rb`

~~~ ruby
require_relative "../dotfiles"

maybe_install("tmux")

[ "tmux.conf", "tmux" ].each do |name|
    link_file(name, "~/.#{name}")
end
~~~

The `maybe_install` line checks to see if tmux is already installed. If
not, it uses either `apt-get` or Homebrew to fetch it. We then create
symlinks for the config and the plugin directory.

Run this on a Linux box for the first time, and you see this:

~~~
$ ruby install.rb
sudo apt-get install tmux
[sudo] password for dave:
Reading package lists... Done
Building dependency tree
Reading state information... Done
Starting pkgProblemResolver with broken count: 0
 . .
Processing triggers for libc-bin (2.27-3ubuntu1) ...
Setting up tmux (2.6-3) ...
Processing triggers for man-db (2.8.3-2) ...
ln -s /home/dave/dotfiles/tmux/tmux.conf /home/dave/.tmux.conf
ln -s /home/dave/dotfiles/tmux/tmux /home/dave/.tmux
$
~~~

Run it a second time, and nothing happens:

~~~
$ ruby install.rb
$
~~~

### Example: git

The git installation is slightly more complex.

`dotfiles/git` contains three files:

~~~
.
├── gitconfig.erb
├── git-diff-cmd.sh.erb
└── install.rb
~~~

The `git/install.rb` looks like this:

~~~ ruby
require_relative "../dotfiles"

maybe_install('git')
maybe_install({ linux: 'meld', osx: 'opendiff' })

expand_and_link_file  "gitconfig.erb", "~/.gitconfig"

bin = File.expand_path("~/bin")

mkdir(bin) unless File.directory?(bin)
expand_and_link_file "git-diff-cmd.sh.erb", "#{bin}/git-diff-cmd.sh"
~~~

The two `maybe_install` lines install git and the tool I use for diffs
(on Linux it's`meld`, on OS X I use `opendiff`).

I then expand two supporting files (`gitconfig` and a shell script to
run the diff) and link them to the appropriate places.

The raw `gitconfig.eex` looks like this:

~~~ ini
[push]
      default = simple

[user]
      name = pragdave
      email = dave@pragdave.me

[filter "lfs"]
      smudge = git-lfs smudge -- %f
      required = true
      clean = git-lfs clean -- %f

[alias]
      mr = !sh -c 'git fetch origin merge-requests/$1/head:mr-$1 && git checkout mr-$1' -

[diff]
      external = <%= File.expand_path("~") %>/bin/git-diff-cmd.sh

  . . .
~~~

Notice that in the `[diff]` section I have an ERb substitution, creating
an absolute path to a script in `~/bin`. Back in the `install.rb`
script, you'll notice that this is where I linked the diff script.

The diff script also uses ERb to configure the parameters it uses
depending on the OS:

~~~ sh
#!/bin/sh
<%= OS == :linux ? "meld" : "opendiff" %> "$2" "$5"  <%= unless OS == :linux then '-merge "$1"' end %>
~~~

## Overly Simple, I Agree

I didn't set out to create a world-beating environment management tool:
I just needed something to help me migrate back and forth between boxes.

So far, this system has worked well for me. One way I can tell: a couple
of weeks back I wanted to change the distro of Linux I use. I read all
about how to install X under Y, but it just seemed complex.

This system to the rescue. I simple made sure I'd done `git commit/push`
everywhere, and the reformatted the SSD. Once I had the new distro
installed, I was back working on my current project in abut 30 minutes.

## Problems

The only problem I run into is with the .erb files. With all the other
config files, the one the application uses is a direct symbolic link to
the one in dotfiles. This means if I make changes, both versions are
updated, and as long as I do a commit in dotfiles at some point, that
change then becomes enshrined on all boxes.

However, with .erb files, the application uses the result of _expanding_
the original version in dotfiles. If I change the application version of
the file (for example by editing `~/.gitconfig` and not
`.../dotfiles/git/gitconfig.erb`), then those changes will be local
only.

I'm thinking I should change my installer to make the installed config
file read-only if it's the result of an ERb expansion.


## dotfiles.rb

Here's the trivial library that the install scripts use:

~~~ ruby
require 'erb'
require 'fileutils'
include FileUtils::Verbose


OS =  case RbConfig::CONFIG['target_os']
      when /linux/i
        :linux
      when /mac|darwin/i
        :osx
      else
        fail "Unknown target OS: #{RbConfig::CONFIG['target_os']}"
      end

case OS
when :linux
  INSTALL_BIN = "/usr/bin"
  INSTALL_CMD = "sudo apt-get install"
when :osx
  INSTALL_BIN = "/usr/local/bin"
  INSTALL_CMD = "brew install"
end

def binary_exist?(name)
  File.file?(File.join(INSTALL_BIN, local_name(name)))
end

def install(package)
  cmd = "#{INSTALL_CMD} #{local_name(package)}"
  puts cmd
  system(cmd)
end

def maybe_install(package)
  package = local_name(package)
  install(package) unless binary_exist?(package)
end

def local_name(package)
  if package.kind_of?(Hash)
    package = package[OS]
  else
    package
  end
end

def link_file(original, dest)
  do_link(original, dest) do |full_original, full_dest|
    ln_s(full_original, full_dest) unless File.symlink?(full_dest)
  end
end

def expand_and_link_file(original, dest)
  do_link(original, dest) do |full_original, full_dest|
    expanded = expand_file(full_original)
    chmod File.stat(full_original).mode, expanded
    ln_s(expanded, full_dest, verbose: true) unless File.symlink?(full_dest)
  end
end

def do_link(original, dest)
  original = File.expand_path(original)
  dest     = File.expand_path(dest)

  if ok_to_link?(original, dest)
    yield(original, dest)
  end
end

def ok_to_link?(original, dest)
  return(true) unless File.exist?(dest)
  return(true) if File.symlink?(dest) && File.readlink(dest) == original

  puts "\nFile #{dest} already exists."
  print "Shall I replace it [yn]: "
  response = gets.strip
  unless response =~ /^y$/i
    puts "No changes made"
    exit 1
  end

  backup = "#{dest}.orig"
  mv dest, backup
  puts "Original file saved in #{backup}"
  true
end

def expand_file(original)
  unless original.end_with?(".erb")
    raise "#{original} is not an erb file, so I can't expand it"
  end
  target = original.sub(/\.erb$/, '')

  renderer = ERB.new(File.read(original))
  File.open(target, "w") do |f|
    f.puts(renderer.result())
  end
  target
end
~~~