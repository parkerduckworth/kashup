defmodule Kashup.Application do
  @moduledoc """
  Application callback to start any global services.

  This will initialize the `Kashup.Store` and start the application
  root supervisor.
  """
  use Application

  @doc """
  Starts the root supervisor for Kashup.
  """
  def start(_type, _args) do
    Kashup.Store.init()
    case Kashup.Supervisor.start_link([]) do
      {:ok, pid} -> 
        Kashup.Event.start()
        {:ok, pid}
      other -> 
        other
    end
  end
end
