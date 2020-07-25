defmodule Kashup do
  @moduledoc """
  Documentation for `Kashup`.
  """

  def insert(key, value) do
    case Kashup.Store.lookup(key) do
      {:ok, pid} ->
        Kashup.Event.replace(key, value)
        Kashup.Element.replace(pid, value)
      {:error, _} ->
        # TODO: Find ergonomic way to introduce expirations 
        {:ok, pid} = Kashup.Element.create(value)
        Kashup.Event.create(key, value)
        Kashup.Store.insert(key, pid) 
    end
  end

  def lookup(key) do
    Kashup.Event.lookup(key)
    try do
      {:ok, pid} = Kashup.Store.lookup(key)
      {:ok, value} = Kashup.Element.fetch(pid)
      {:ok, value}
    rescue 
      _ in MatchError -> {:error, :not_found}
    catch
      :exit, _ -> {:error, :not_found}
    end
  end

  def delete(key) do
    case Kashup.Store.lookup(key) do
      {:ok, pid} -> Kashup.Element.delete(pid)
      _ -> :ok
    end
  end
end
