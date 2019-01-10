---
title:    Dynamic Processes and State
layout:   post
comments: true
tags:     programming elixir
---

# Where Does State Live?

Several people have questioned my description of when you should use
dynamic components:

> Does your component maintain state across multiple calls, and do you
> need multiple versions of that state? For example, are you
> representing a user session, or the state of games being played? If
> so, use a dynamic component, where each component maintains state for
> the session/game/....

Their objection is that I need to add the word _shared_, so that yopu
only need dynamic components to share data.

It's an interesting point of view, and it took me a while to work out
their reasoning. Now that I understand it, I'm still sticking my my
statement, but I'd like to explain both points of view.

## Recap: Dynamic Components

A dynamic component represents a server factory. You ask the factory for
a new server, and then use that server until you're done with it. Being
a server, it can maintain its own state.

## Let's Use Hangman as an Example

Say you're implementing a game of hangman.

We'll agree up front to make the game a separate component: that is,
we'll do

~~~
$ mix new game
~~~

and write the game logic in this new directory tree.

We'll write various clients for the game (a command line line, a Phoenix
client, and so on).

The game itself has state (the word to be guessed, letters guessed so
far, and so on). It also has an API that reveals an external version of
that state.

Each game being played needs its own state.

The debate is about where that state should be held.

## Their Perspective on This

Some folks argue that each client has exactly one game. Although the
client will be a process, there's no need for the game to be one: the
client can hold the game's state, passing it in on each call to the game
API and updating it on each return from the API. The client code might look
something like this:

~~~ elixir
def play_game() do
  game = %Hangman.State{} |> Hangman.choose_word_to_guess
  accept_guess(game)
end

def accept_guess(game) do
  IO.puts "The word so far: #{game.word_so_far}"
  IO.puts "Letters used: #{game.letters_guessed |> Enum.join(",")}"
  guess = get_next_letter()
  game  = Hangman.score_guess(game, guess)
  cond do
   game.won || game.lost ->
    handle_end_of_game(game)
   game.good_guess ->
    handle_good_guess(game, guess)
   else
    handle_bad_guess(game, guess)
   end
end
~~~

Spiffing!

## My Perspective

I'm really nervous about the client having unfettered
access to the state of the game. I'm not worried about cheating. I'm
concerned because the state is really to do with the _implementation_ of
the game. And the implementation of a module should be no ones business
but the module's.

In the code above, the client assumes that the game state contains a
string, `word_so_far` representing the current state of the guess, and
that it contains an enumerable, `letters_guessed` of the guesses so far.

Maybe when we first wrote it, both were true.

But maybe things changed in the game. We decided to change the
way we record guesses—say we use a bitmap instead. And maybe we no
longer keep a version of the word so far: we can always reconstruct it
from the target word and the guesses.

Both of these things are internal implementation issues, but both
changes break the client.

This is coupling, and on a larger scale this is a major reason changing
code is difficult,

If processes in Elixir were expensive, I would 100% agree with this
approach. But they're not. Instead, developer time is a significant
cost, and in particular the time spend maintaining and changing code. So
I'm prepared to take the hit of having an extra process lying around if
it makes the life of future-me easier.

So my approach would be to turn the game from being as library into
being a server. It keeps its game state totally hidden from the outside
world: all the rest of the world gets to see is a PID and an API.

The client might look something like this:


~~~ elixir
alias Hangman, as: H  # 'cos I'm lazy

def play_game() do
  game = H.create()
  accept_guess(game)
end

def accept_guess(game) do
  IO.puts "The word so far: #{H.word_so_far(game)}"
  IO.puts "Letters used: #{H.letters_guessed(game) |> Enum.join(",")}"
  guess = get_next_letter()
  result = Hangman.score_guess(game)
  cond do
   result.won || result.lost ->
    handle_end_of_game(game)
   result.good_guess ->
    handle_good_guess(game, guess)
   else
    handle_bad_guess(game, guess)
   end
end
~~~

Not much different, really. But now the internal state is opaque, and
it's only made available via API calls. If we change the internal
implementation, we can keep the same API, and therefore not break
anything.

So, because of this, I'm a big fan of encapsulating state inside
processes, even if it isn't technically necessary.

And that's what I use Dynamic components for.

As always, I'm looking forward to some interesting comments and perspectives.