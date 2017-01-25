---
title:  Emacs Term Buffers—A Fix for the Modified Bit
layout: post
tag:    programming
---

I do 90% of my coding in Emacs. In the old days, I used to run iTerm
on a separate desktop and Alt-Tab between them. But the lack of
integration bugged me, so I kept trying Emacs `term-mode`. It took a
while, but I finally got a really nice setup, with
mouseless-navigation, fish shell integration, and so on.

One thing always niggled. Emacs keeps track of changes to buffers.
When you run a potentially destructive command (such as quitting
Emacs, installing packages, or running Magit), Emacs warns you about
each modified buffer in turn, asking you to decide what you want to
do. I appreciate this for regular files, but for buffers containing
terminal sessions it is a total PITA.

I've been meaning to fix it for months, but finally got around to it
today. I have the following in my customization file for multiterm:

~~~ elisp
(defun ignore-changes-in-term-buffers ()
  (add-hook 'after-change-functions
            (lambda (a b c)
              (set-buffer-modified-p nil))
            nil
            t))

(add-hook 'term-mode-hook
          'ignore-changes-in-term-buffers
          nil
          t)
~~~

When term-mode is turned on for a buffer, it triggers the
`ignore-changes...` function. That in turn intercepts every buffer
change event, and immediately resets the buffer-modified flag.

It feels like a total hack, so I'd love someone to tell me how silly I
am and give me a proper fix.

