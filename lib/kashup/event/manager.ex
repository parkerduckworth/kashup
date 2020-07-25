defmodule Kashup.Event.Manager do
  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def async_notify(event) do
    GenStage.cast(__MODULE__, {:notify, event})
  end

  @impl true
  def init(:ok) do
    {:producer, dispatcher: GenStage.BroadcastDispatcher}
  end

  @impl true
  def handle_cast({:notify, event}, state) do
    {:noreply, [event], state}
  end

  @impl true
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
