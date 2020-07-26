defmodule Kashup.Element.Supervisor do
  @moduledoc """
  Supervisor for zero or more `Kashup.Element` processes.

  Because each key in the store has a corresponding `Kashup.Element` process, The number of
  `Kashup.Element.Supervisor`'s children is equivalent to the number of keys in the store.
  """
  use DynamicSupervisor

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Add a new `Kashup.Element` process to the element supervision tree.

  This function is called by `Kashup.Element.create`, when `Kashup.put/2` is invoked.
  """
  def start_child(value, expiration) do
    spec = %{
      id: Kashup.Element, 
      start: {Kashup.Element, :start_link, [value, expiration]},
      restart: :temporary,
      shutdown: :brutal_kill
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
