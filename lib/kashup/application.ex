defmodule Kashup.Application do
  @moduledoc false

  use Application

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
