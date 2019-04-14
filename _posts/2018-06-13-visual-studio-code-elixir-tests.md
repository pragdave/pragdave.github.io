---
title:    Running Elixir Tests in Visual Studio Code/ElixirLS
layout:   post
comments: true
tags:     programming elixir
---

> My configuration for running Elixir project tests with a keystroke.

I'm halfway through my self-imposed year-or-doing-things-differently.
I've switched from Mac to Linux, and Emacs to VS Code. Of the two, I
know I'm unlikely to switch back to Emacs (which surprises me).

One of the reasons is the Jake Becker's vscode-elixir-ls and ElixirLS
packages. Things such as automated running of Dialyzer turn out to be
incredibly useful: I'm coding away and a wavy green line turns up
signalling I swapped two values in a tuple.

One thing I'd like is to be able to run tests easily. I don't want to do
it on every save: I regularly break things while refactoring, but I
want to make it easy from the keyboard so the muscle memory can kick in.

I'm documenting it here mostly as a noe to my future self.

First, my `tasks.json`:

~~~ json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "mix test",
      "type": "shell",
      "command": "mix",
      "args": ["test", "--color", "--trace"],
      "options": {
        "cwd": "${workspaceRoot}",
        "requireFiles": [
          "test/**/test_helper.exs",
          "test/**/*_test.exs"
        ],
      },
      "problemMatcher": "$mixTestFailure"
    }
  ]
}
~~~

Then in `keybindings.json`:

~~~ json
  {
    "key": "alt+t",
    "command": "workbench.action.tasks.runTask",
    "args": "mix test"
  }
~~~

Now, I can just hit `Alt+T` and the tests run:

{% asset tests-in-vscode.png class=img-fluid %}