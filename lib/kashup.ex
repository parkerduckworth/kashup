defmodule Kashup do
  @moduledoc """
  Documentation for `Kashup`.
  """

  def put(key, value) do
    case Kashup.Store.get(key) do
      {:ok, pid} ->
        Kashup.Event.put(key, value, :replace)
        Kashup.Element.replace(pid, value)
      {:error, _} ->
        # TODO: Find ergonomic way to introduce expirations 
        {:ok, pid} = Kashup.Element.create(value)
        Kashup.Event.put(key, value, :create)
        Kashup.Store.put(key, pid) 
    end
  end

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

  def delete(key) do
    case Kashup.Store.get(key) do
      {:ok, pid} -> Kashup.Element.delete(pid)
      _ -> :ok
    end
  end
end
