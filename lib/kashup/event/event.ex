defmodule Kashup.Event do
  @moduledoc """
  Internal API for pushing events to the event manager.
  """
  alias Kashup.Event

  def start do
    Event.Manager.async_notify(:started)
  end
  
  def put(key, value, action) do
    Event.Manager.async_notify({:put, [key: key, value: value], action})
  end

  def get(key) do
    Event.Manager.async_notify({:get, [key: key]})
  end

  def delete(key) do
    Event.Manager.async_notify({:delete, [key: key]})
  end

  def expired(pid, value) do
    Event.Manager.async_notify({:expired, [pid: pid, value: value]})
  end
end
