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
    init()
    case Kashup.Supervisor.start_link([]) do
      {:ok, pid} -> 
        Kashup.Event.start()
        {:ok, pid}
      other -> 
        other
    end
  end

  defp init() do
    # Sync with other nodes
    :ok = join_cluster()

    # Locate sibling nodes' kashup instances
    Disco.add_local_capability(Kashup, Node.self())
    Disco.add_target_capability_tag(Kashup)
    Disco.swap_capabilities()

    Application.get_env(:kashup, :resource_wait_time, 2500)
    |> :timer.sleep()

    # Init storage engine. This must come last
    Kashup.Store.init()
  end

  defp join_cluster() do
    case Application.get_env(:kashup, :anchor_nodes) do
      nil -> {:error, :no_anchor_nodes_available}
      anchor_nodes -> join_cluster(anchor_nodes)
    end
  end

  defp join_cluster(anchor_nodes) do
    siblings = Enum.filter(anchor_nodes, fn node -> Node.ping(node) == :pong end)
    case siblings do
      [] -> 
        {:error, :no_anchor_nodes_available}
      _ ->
        # Give the cluster some time to sync up
        wait_time = Application.get_env(:kashup, :join_wait_time, 5000)
        :timer.sleep(wait_time)
        :ok
    end
  end
end
