defmodule Kashup.Store do
  def init() do
    :ets.new(__MODULE__, [:public, :named_table])
  end

  def insert(key, pid) do
    :ets.insert(__MODULE__, {key, pid})
    :ok
  end

  def lookup(key) do
    case :ets.lookup(__MODULE__, key) do
      [{_key, pid}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def delete(pid) do
    :ets.match_delete(__MODULE__, {'_', pid})
  end
end
