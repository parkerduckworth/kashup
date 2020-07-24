defmodule Kashup.Supervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(value, expiration) do
    spec = %{
      id: Kashup.Element, 
      start: {Kashup.Element, :start_link, [value, expiration]},
      restart: :temporary,
      shutdown: :brutal_kill,
      type: :worker
    }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(args) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: args
    )
  end
end
