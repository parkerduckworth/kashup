defmodule Kashup.Event do
  alias Kashup.Event

  def start do
    Event.Manager.async_notify(:started)
  end
  
  def create(key, value) do
    Event.Manager.async_notify({:create, key, value})
  end

  def replace(key, value) do
    Event.Manager.async_notify({:replace, key, value})
  end

  def lookup(key) do
    Event.Manager.async_notify({:lookup, key})
  end

  def delete(key) do
    Event.Manager.async_notify({:delete, key})
  end
end
