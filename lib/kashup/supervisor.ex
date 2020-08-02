defmodule Kashup.Supervisor do
  @moduledoc """
  Supervisor callback that serves as Kashup's root supervisor.

  The `Kashup.Element.Supervisor` is always added to the supervision tree at appliction start, and
  `Kashup.Event.Manager` and `Kashup.Event.Handler` are added as well depending on application
  configuration.

  ## Example Configuration

  ```
  config :kashup,
    events: true
  ```

  To silence events, either set `events: false`, or omit this field from your application
  config entirely.
  """
  use Supervisor

  import Supervisor.Spec

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end  

  @impl true
  def init([]) do
    element_supervisor = %{
      id: Kashup.Element.Supervisor,
      start: {Kashup.Element.Supervisor, :start_link, []},
      shutdown: 2_000,
      type: :supervisor      
    }

    task_supervisor = {Task.Supervisor, name: Kashup.TaskSupervisor}

    children = Application.get_env(:kashup, :events)
    |> add_event_children
    |> Kernel.++([element_supervisor, task_supervisor])

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp add_event_children(true) do
    event_manager = %{
      id: Kashup.Event.Manager,
      start: {Kashup.Event.Manager, :start_link, []},
      shutdown: 2_000,
    }

    event_handler = worker(Kashup.Event.Handler, [], id: Kashup.Event.Handler) 

    [event_manager, event_handler]
  end

  defp add_event_children(_), do: []
end
