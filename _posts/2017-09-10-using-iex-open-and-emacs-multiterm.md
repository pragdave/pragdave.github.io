---
title: Using iex's open() command with Emacs multiterm
layout: post
comments: true
tags: programming elixir emacs
---

(tldr; I can now open Elixir source files from inside iex, and have
them pop up in an Emacs buffer alongside my terminal buffer.)

<iframe
src="https://player.vimeo.com/video/233162999?title=0&byline=0&portrait=0"
width="640" height="360" frameborder="0" webkitallowfullscreen
mozallowfullscreen allowfullscreen>
</iframe>
<p>
<a href="https://vimeo.com/233162999">Multiterm with iex open</a>
from <a href="https://vimeo.com/user50998191">Dave Thomas</a> on 
<a href="https://vimeo.com">Vimeo</a>.
</p>

## Background

My name is Dave Thomas and I use Emacs.

There, I've said it.

And when I switched from an 17" to a 13" laptop, I got into trouble,
because I couldn't easily manage terminal windows and Emacs windows
side-by-side.[^fn1]

[^fn1]: I use the GUI version of Emacs because it gives me better OS X
    integration.
    
So I investigated ways of using terminals inside Emacs. It took a
surprisingly long time to get a setup that worked the way I wanted,
but now I use it pretty much exclusively. When I'm coding, I have an
Emacs frame full screen, with editor buffers and terminal windows
opened (and managed inside it).

My setup uses `term-mode` inside Emacs, and some fish shell config on
the outside to bind things nicely together. For example, I have an `e`
shell function which takes a file name and an optional line number,
and it opens an Emacs buffer on that file and line.

## Integrate with IEx

IEx 1.5 comes with a new `open` function. You give it a module (with
an optional function name) and it opens an editor on the file that
contains it. This can be easily customized: Chris McCord has
[written](https://dockyard.com/blog/2017/08/24/elixir-open-command-with-terminal-emacs)
about his setup with Emacs. However, he uses a terminal-based Emacs,
and I wanted to use windowing.

So here's what I did.

## Create A Simple Shell Function

When you all "open Fred.func" in IEx, it looks for the source file that
contains the `Fred` module, then opens an external editor, setting the
cursor to the line containing the start of `func1`.

It finds the name of the editor program by reading the environment
variable `ELIXIR_EDITOR`. It then invokes the editor, passing the name
of the file, colon, and the line number.

Normally, you'd set `ELIXIR_EDITOR` to `vi`, or `atom`, or whatever.
In my case, through, I needed IEx not to run a program. Instead I
wanted it to tell Emacs to open the file in a new window.

To do this, I defined `ELIXIR_EDITOR` to be a simple `echo` command
that simple wrote the name of the file to be edited,
prepended by a magic escape sequence. The convention
used by term-mode is to start the sequence `\eAnSiT`, so I wrote:

~~~
set -gx ELIXIR_EDITOR 'echo "\033A\nSiTe"'
~~~

## Intercept This Sequence in Emacs

term-mode provides a hook that lets you intercept ANSI escape
sequences. This is normally used to track and display the directory
name in the buffer containing the terminal. However, in my Emacs
initialization I have:

~~~ 
  (defun term-handle-ansi-terminal-messages (message)
    (while (string-match "\eAnSiT.+\n" message)

      ;; Extract the command code and the argument.
      (let* ((start (match-beginning 0))
             (command-code (aref message (+ start 6)))
             (argument
              (save-match-data
                (substring message
                           (+ start 8)
                           (string-match "\r?\n" message
                                         (+ start 8))))))
        ;; Delete this command from MESSAGE.
        (setq message (replace-match "" t t message))

        (cond ((= command-code ?c)
               (setq term-ansi-at-dir argument))
              ((= command-code ?h)
               (setq term-ansi-at-host argument))
              ((= command-code ?u)
               (setq term-ansi-at-user argument))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; this is the code that handles the edit function ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

              ((= command-code ?e)
               (save-excursion
                 (dt-find-file-with-line argument))))))
    
    (when (and term-ansi-at-host term-ansi-at-dir term-ansi-at-user)
      (setq buffer-file-name
            (format "%s@%s:%s" term-ansi-at-user term-ansi-at-host term-ansi-at-dir))
      (set-buffer-modified-p nil)
      (setq default-directory (if (string= term-ansi-at-host (system-name))
                                  (concatenate 'string term-ansi-at-dir "/")
                                (format "/%s@%s:%s/" term-ansi-at-user term-ansi-at-host term-ansi-at-dir)))
      (setq truncated-dir-name (truncate-dir-name default-directory)))
    
    message))
~~~

The three lines of code look for the `e` at the end of the ANSI escape
sequence, then call `dt-find-file-with-line` passing the file name and
line number.

~~~ 
(defun dt-find-file-with-line (file-line-string)
  (let* ((dt-file-line (split-string file-line-string ":"))
         (dt-file      (car dt-file-line))
         (dt-line      (or (cadr dt-file-line) "1"))
         (dt-buffer    (find-file-other-window dt-file)))

    (switch-to-buffer dt-buffer)
    (goto-char (point-min))
    (forward-line (- (string-to-int dt-line) 1))
    (run-with-idle-timer 0
                         nil
                         (lambda (buffer)
                                 (switch-to-buffer-other-window buffer))
                         dt-buffer))
  )
~~~

This function simply splits the argument into a file name and line
number, loads the file into a buffer, and sets the cursor to the start
of that line in the buffer.

One problem is that term-mode expects to be in its own buffer when we
return from processing the escape sequence, so I add an idle timer
which switches to the new buffer once term-mode has finished doing its
stuff.


