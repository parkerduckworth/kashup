defmodule Kashup do
  @moduledoc """
  Documentation for the Kashup package, a distributed in-memory key/value store.

  For usage information, see the [documentation](http://hexdocs.pm/kashup), which includes guides,
  API information for important modules, and links to useful resources.
  """

  @doc """
  Add a key/value pair to the store.

  ## Example

  ```
  iex(node@net)1> Kashup.put(:joe, :armstrong)
  :ok
  ```
  """
  @spec put(any(), any()) :: :ok
  def put(key, value) do
    case Kashup.Store.get(key) do
      {:ok, pid} ->
        Kashup.Event.put(key, value, :replace)
        Kashup.Element.replace(pid, value)
      {:error, _} ->
        expiration = Application.get_env(:kashup, :expiration)
        {:ok, pid} = Kashup.Element.create(value, expiration)
        Kashup.Event.put(key, value, :create)
        Kashup.Store.put(key, pid) 
    end
  end

  @doc """
  Get a value from the store with a provided key.

  ## Examples

  Hit
  ```
  iex(node@net)1> Kashup.get(:joe)
  :armstrong
  ```

  Miss
  ```
  iex(node@net)1> Kashup.get(:static_typing)
  {:error, :not_found}
  ```
  """
  @spec get(any()) :: {:ok, any()} | {:error, :not_found}
  def get(key) do
    Kashup.Event.get(key)
    try do
      {:ok, pid} = Kashup.Store.get(key)
      {:ok, value} = Kashup.Element.fetch(pid)
      {:ok, value}
    rescue 
      _ in MatchError -> {:error, :not_found}
    catch
      :exit, _ -> {:error, :not_found}
    end
  end

  @doc """
  Delete a key/value pair from the store.

  Returns `:ok` regardless of whether or not key is in the store.

  ## Example
  ```
  iex(node@net)1> Kashup.delete(:static_typing)
  :ok
  ```
  """
  @spec delete(any()) :: :ok
  def delete(key) do
    Kashup.Event.delete(key)
    case Kashup.Store.get(key) do
      {:ok, pid} -> Kashup.Element.delete(pid)
      _ -> :ok
    end
  end
end
