defmodule Kashup.Store do
  @moduledoc """
  Internal API for the underlying storage mechanism.

  `Kashup.Store` maps provided keys to a `pid()` whose process, if alive, contains the value 
  associated with the key.

  Kashup ships with [ets](https://erlang.org/doc/man/ets.html) as the default storage. 
  You can read more about ets and Elixir [here](https://elixir-lang.org/getting-started/mix-otp/ets.html).
  """

  @doc """
  Initialize the storage mechanism.
  """
  def init() do
    :ets.new(__MODULE__, [:public, :named_table])
  end

  @doc """
  Add a key/pid() entry.
  """
  def put(key, pid) do
    :ets.insert(__MODULE__, {key, pid})
    :ok
  end

  @doc """
  Get a pid() with a provided key.
  """
  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{_key, pid}] -> {:ok, pid}
      [] -> {:error, :not_found}
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
    :ets.match_delete(__MODULE__, {'_', pid})
  end
end
