---
title:    Using Components to Build a Real World Elixir Assembly
layout:   post
comments: true
tags:     programming elixir components logger bunyan
---

> In which I find out whether my ideas about using components have any
> merit.

For a while now I've been [complaining](https://youtu.be/6U7cLUygMeI) that the conventions that Eliir
adopted from Erlang tend to lead people to write monolithic
applications.

In order to test these ideas and others) I've been building a system
which supports the creation and deployment of lots of decoupled
components. It's going fairly well, but I got slightly derailed when I
came to integrate a centralized logger into the mix. After all, if you deploy 50
separate components, you really don't want to be grovelling through 50
separate log files to find out what's going on.

I know there are lots of good SaaS solutions, but I felt that I needed
something simpler and under my control if I was to assert that this
approach works.

I had a look at modifying the built-in Elixir logger, but it wasn't
really amenable to the changes I wanted. I looked at some other
solutions, but they all lacked one thing or another.

So, I decided to honor the well-established traditions
of our field and write my own. The decider for me was the thought that I
could put my effort where my mouth is and write this as an assembly of
components.

This post is a kind of experience report on the lessons learned.

> tldr; the approach works really well, but would benefit greatly from a
> little tooling support. I will write everything this way going
> forward.

## The Bunyan Logger

[Bunyan](https://github.com/bunyan-logger/bunyan) is a distributed,
extensable logger. I currently consists of nine separate components,
averaging about 200 lines of code each.

Each component is a separate mix project, and each is a separate github
project.

The overall architecture looks something like this:

<pre><code>         SOURCES                    CORE                     WRITERS
         ‾‾‾‾‾‾‾                    ‾‾‾‾                     ‾‾‾‾‾‾‾
    ╭──────────────╮                                    ╭────────────────╮
    │ Programmatic │ \                             ---->│ Write to stdout│
    │     API      │  \                           /     │ files, etc     │
    ╰──────────────╯   \                         /      ╰────────────────╯
                        \      ╭──────────────╮ /
    ╭──────────────╮     ----> │   Collect    │/        ╭────────────────╮
    │ Erlang error │ ╌╌╌╌╌╌╌╌> │      &       │╌╌╌╌╌╌╌> │   Write to     │
    │   logger     │     ----> │ Distribute   │\        │  remote node   │
    ╰──────────────╯    /      ╰──────────────╯ \       ╰────────────────╯
                       /                         \
    ╭──────────────╮  /                           \     ╭────────────────╮
    │    Remote    │ /                             \    │     etc        │
    │    reader    │                                --->│                |
    ╰──────────────╯                                    ╰────────────────╯
</code></pre>

Each of the boxes is a component. In addition there are two background
components, a formatter for log messages and a set of shared utility
functions.

### Structure of a Component

I played with many different options, but settled on something really
quite simple.

Each component has the same overall structure. A component named
`device`, which writes log messages to devices, would have a lib directory tree like this:

~~~
lib/
├── device
│   ├── application.ex
│   ├── impl.ex
│   ├── server.ex
│   └── state.ex
└── device.ex
~~~

Each module has a specific purpose:

* `lib/device.ex`

  is the API for the component. It declared all the externally callable
  functions, delegating them to the server. It also contains the
  child_spec that kicks that server off. In the case of Bunyan, I
  removed duplication between components with a simple macro. This means
  the top level code of the `device` component is:

  ~~~ elixir
  defmodule Bunyan.Writer.Device do
    @server __MODULE__.Server

    use Bunyan.Shared.Writable, server_module: @server

    alias Bunyan.Shared.LogMsg

    @type name :: atom()   | pid()
    @type t    :: binary() | name()

    @spec write_log_message(device :: atom() | name, msg :: LogMsg.t) :: any
    def write_log_message(device, message) do
      GenServer.cast(device, { :log_message, message })
    end

    @spec update_configuration(name :: name, new_config :: keyword()) :: any()

    def update_configuration(name \\ @server, new_config) do
      GenServer.call(name, { :update_configuration, new_config })
    end

    @spec set_log_device(name :: name, device :: t) :: any()
    def set_log_device(name \\ @server, device) do
      GenServer.call(name, { :set_log_device, device })
    end

    @spec bounce_log_file(name :: name) :: :ok
    def bounce_log_file(name \\ @server) when is_atom(name) or is_pid(name) do
      GenServer.call(name, { :bounce_log_file })
    end

  end
  ~~~

  (I've removed comments and documentation for clarity).

  There's a little trickery here: when you `use Bunyan.Shared.Writable`,
  it defines the child spec for you, and also creates a helper function
  that handles configuration. More on that later.

* `device/application.ex`

  Is totally standard. It passes the top-level module to
  `Supervisor.start_link`, as that top-level module contains the child
  spec.

  ~~~elixir
  defmodule Bunyan.Writer.Device.Application do

    use Application

    def start(_type, _args) do
      children = [
        { Bunyan.Writer.Device, [] },
      ]

      opts = [strategy: :one_for_one, name: Bunyan.Writer.Device.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end
  ~~~

* `device/server.ex`

  This is a straightforward GenServer. It contains a minimal amount of
  application logic, delegating that work to the `Impl` module. I'd
  remove some boring repetition from the code here:

  ~~~ elixir
  defmodule Bunyan.Writer.Device.Server do
    use GenServer
    alias Bunyan.Writer.Device.{ Impl, State }

    def start_link(options) do
      GenServer.start_link(__MODULE__, options, name: __MODULE__)
    end

    def init(options) do
      { :ok, options }
    end

    def handle_cast({ :log_message, msg}, options) do
      Impl.write_to_device(options, msg)
      { :noreply, options }
    end

    def handle_call({ :set_log_device, device }, _, options) do
      flush_pending()
      options = Impl.set_log_device(options, device)
      { :reply, :ok, options }
    end

    def handle_call({ :update_configuration, new_config }, _, config) do
      flush_pending()
      new_config = State.from(new_config, config)
      { :reply, :ok,  new_config }
    end

    def handle_call({ :bounce_log_file }, _, config ) do
      { :reply, :ok, Impl.bounce_log_file(config) }
    end

    def terminate(_, options) do
      Impl.close_log_device(options)
      :ignored_return_value
    end

    defp flush_pending() do
      # ..
    end
  end
  ~~~

* `device/impl.ex`

  This module contains the actual implementation of the component.

  ~~~ elixir
  defmodule Bunyan.Writer.Device.Impl do

    alias Bunyan.Writer.Device.SignalHandler

    def write_to_device(options, msg) do
      IO.write(options.device_pid, options.format_function.(msg) |> List.flatten |> Enum.join)
    end

    @spec set_log_device(config :: map, device :: Bunyan.Writer.Device.t) :: map
    def set_log_device(config, device) do
      pid_or_process_name = maybe_open_file(device)

      config
      |> maybe_close_existing_file()
      |> setup_new_device(pid_or_process_name, device)
      |> maybe_setup_signal_handler()
      |> maybe_enable_color_logging()
    end

    def close_log_device(options) do
      maybe_close_existing_file(options)
    end

    @spec bounce_log_file(map()) :: map()
    def bounce_log_file(options = %{ device: device }) when is_binary(device) do
      options = maybe_close_existing_file(options)
      pid = open_log_file(device)
      setup_new_device(options, pid, device)
    end

    # and the private helper functions ...
  end
  ~~~

* `device/state.ex`

  And finally there's the `State` module. Because this is somthing of a
  big deal, it gets its own section...

### State and Configuration

It became apparent very early in the development that managing
configuration was critical. It was also something that the Erlang config
model couldn't help with (but that's a separate rant).

My current solution is simple, but seems to work well.

Every component has an internal representation of its state. This is
defined as a struct in the `State` module.

The state contains two main sections, working state and configuration.

The working state consists of the values that the server needs to
generate and pass around to make the component function.

The configuration part of the state is the internal representation of
this component's configuration.

#### The Configuration/State Boundary

The configuration of a component is given to it when that component is
started. This configuration is expressed in terms that make sense to the
user of the component.

The configuration section of the state is a representation of this
external representation. It's held in a form that makes most sense to
the implementation of a component.

For example, Bunyan supports log levels such as `:info`, `:warn`, and
`:error`. These are the external representations. Internally we often
need to compare these log levels against a threshold level, so for
convenience we convert the atoms (the external form) into integers (the
internal form).

The convention I adopted is to have a state module define both the
structure representing the internal representation and a function
(imaginatively called `from`) that maps the external form into this
structure. Yes, indeed, this is a constructor. Shoot me.

Here's a cut-down version of the state module for the Device component:

~~~ elixir
defmodule Bunyan.Writer.Device.State do

  alias Bunyan.Shared.{ Level, Options }
  alias Bunyan.{ Formatter, Writer.Device.Impl }

  @debug Level.of(:debug)
  @info  Level.of(:info)
  @warn  Level.of(:warn)
  @error Level.of(:error)

  import IO.ANSI

  defstruct(
    name:          Bunyan.Writer.Device,

    device:        :user,      # a pid, a named process (eg :user), or a filename
    device_pid:    :user,      # the opened device

    pid_file_name: nil,

    main_format_string:        "$time [$level] $message_first_line",
    additional_format_string:  "$message_rest\n$extra",

    format_function:           nil,

    level_colors:   %{
      @debug => faint(),
      @info  => green(),
      @warn  => yellow(),
      @error => light_red() <> bright()
    },
    message_colors: %{
      @debug => faint(),
      @info  => green(),
      @warn  => yellow(),
      @error => light_red()
    },

    timestamp_color: faint(),
    extra_color:     italic() <> faint(),

    user_wants_color?: true,      # this is the user option
    use_ansi_color?:   true       # and this is (user_wants_color? && device supports it)
  )

  def from(user_options, base \\ %__MODULE__{}) do
    import Options, only: [ maybe_add: 3,  maybe_add: 4]

    options = base
              |> maybe_add(user_options, :name)
              |> maybe_add(user_options, :device)
              |> maybe_add(user_options, :pid_file_name)
              |> maybe_add(user_options, :main_format_string)
              |> maybe_add(user_options, :additional_format_string)
              |> maybe_add(user_options, :timestamp_color)
              |> maybe_add(user_options, :extra_color)
              |> maybe_add(user_options, :use_ansi_color?, :user_wants_color?)
              |> maybe_update_colors(user_options, :level_colors)
              |> maybe_update_colors(user_options, :message_colors)

    Impl.set_log_device(options, options.device)
    |> precompile_format_function()
  end

  # ... private helper functions ...
end
~~~

The structure at the top of the module is fairly complex for this component as we have to deal
with all the color configuration. Notice how it defines the default
configuration values.

The `from` function that follows it is passed the external configuration
options. It uses these to update the state. The `maybe_add` function is
a shared helper that overwrites a value in the state struct only if it
occurs in the external options.

#### Convention IS Configuration

This all comes together when a component is created.

We typically create instances of components dynamically. In the case of
Bunyan, the overall configuration will list the readers and writers that
we want to run. For each writer, we add a child to a supervisor, and
pass that child its external configuration as its `start_link`
parameters. And that's where the child spec generated for the top-level
module comes into play.

Remember that our top-level component started with:

  ~~~ elixir
  defmodule Bunyan.Writer.Device do
    @server __MODULE__.Server
    use Bunyan.Shared.Writable, server_module: @server

    # ...
  end
  ~~~

  Let's have a look at that macro:

  ~~~ elixir
  defmodule Bunyan.Shared.Writable do

    @callback update_configuration(name :: atom(), new_config :: keyword()) :: any()
    @callback start(config :: map()) :: any()


    defmacro __using__(args \\ []) do
      caller = __CALLER__.module
      state_module  = args[:state_module]  || Module.concat(caller,  State)
      server_module = args[:server_module] || Module.concat(caller,  Server)

      quote do
        def child_spec(config) do
          Supervisor.child_spec({
            unquote(server_module),
            state_from_config(config)
          }, [])
        end
        defoverridable child_spec: 1

        def state_from_config(config) do
          unquote(state_module).from(config)
        end
      end
    end
  end
  ~~~

  Its main purpose is to define a child spec for the component, which is
  basically an MFA tuple. And the `A`rgument part of that tuple is
  created from the `state_from_config` function, which in turn calls the
  component's `State.from` function.

  The result is that the component is automatically started with a
  defined state that includes configuration.


  ## But Does This Structure Work?

  The simple answer is that it works really well. It took me a month's
  worth of throwing more complex stuff away until I got to this point,
  but I stopped when I got here because it made the actual development
  of Bunyan really simple.