defmodule Kashup.Store do
  @moduledoc """
  Internal API for the underlying storage mechanism.

  `Kashup.Store` maps provided keys to a `pid()` whose process, if alive, contains the value 
  associated with the key.

  Kashup ships with [mnesia](https://erlang.org/doc/man/mnesia.html) as the default storage. 
  You can read more about mnesia and Elixir [here](https://elixirschool.com/en/lessons/specifics/mnesia/).
  """

  alias :mnesia, as: Mnesia

  @doc """
  Initialize the storage mechanism.
  """
  def init() do
    Mnesia.stop()
    Mnesia.delete_schema([Node.self()])
    Mnesia.start()

    Disco.fetch_capabilities(Kashup)
    |> List.delete(Node.self())
    |> sync_db()
  end

  @doc """
  Add a key/pid() entry.
  """
  def put(key, pid) do
    Mnesia.dirty_write({KeyToPid, key, pid})
  end

  @doc """
  Get a pid() with a provided key.
  """
  def get(key) do
    with [{KeyToPid, _key, pid}] <- Mnesia.dirty_read({KeyToPid, key}),
         true <- pid_alive?(pid)
    do
      {:ok, pid}
    else
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Remove an entry based on its value, a pid().

  This function is called from a `Keshup.Element` instance, as a cleanup operation to be performed 
  during its termination. A `Keshup.Element` does not have access to the client's provided key, so 
  it instead passes `self()` to this function, removing its reference from the store after a value 
  is removed.
  """
  def delete(pid) do
    case Mnesia.dirty_index_read(KeyToPid, pid, :pid) do
      [record] -> Mnesia.dirty_delete_object(record)
      _ -> :ok
    end
  end

  defp sync_db([]) do
    Mnesia.create_table(KeyToPid, [attributes: [:key, :pid]])
    Mnesia.add_table_index(KeyToPid, :pid)
  end

  defp sync_db(kashup_nodes), do: add_kashup_nodes(kashup_nodes)

  defp add_kashup_nodes([node | tail]) do
    case Mnesia.change_config(:extra_db_nodes, [node]) do
      {:ok, [_node]} ->
        Mnesia.add_table_copy(:schema, Node.self(), :ram_copies)
        Mnesia.add_table_copy(KeyToPid, Node.self(), :ram_copies)
        Mnesia.system_info(:tables)
        |> Mnesia.wait_for_tables(5000)
      _ -> add_kashup_nodes(tail)
    end
  end

  defp pid_alive?(pid) when node(pid) == node() do
    Process.alive?(pid)
  end

  defp pid_alive?(pid) do
    member? = Enum.member?(Node.list(), node(pid))

    alive? = Task.Supervisor.async({Kashup.TaskSupervisor, node(pid)}, Process, :alive?, [pid])
    |> Task.await()

    member? and alive?
  end
end
