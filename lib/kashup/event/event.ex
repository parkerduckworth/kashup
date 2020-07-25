defmodule Kashup.Event do
  @moduledoc """
  Internal API for pushing events to the event manager.
  """
  alias Kashup.Event

  def start do
    Event.Manager.async_notify(:started)
  end
  
  def put(key, value, action) do
    Event.Manager.async_notify({:put, key, value, action})
  end

  def get(key) do
    Event.Manager.async_notify({:get, key})
  end

  def delete(key) do
    Event.Manager.async_notify({:delete, key})
  end
end
