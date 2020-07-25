defmodule Kashup.Supervisor do
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

    children = Application.get_env(:kashup, :events)
    |> add_event_children
    |> Kernel.++([element_supervisor])

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
