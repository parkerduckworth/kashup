defmodule Kashup.Event.Handler do
  use GenStage
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Kashup.Event.Manager]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      # TODO: provide behavior for ad hoc event handling
      Logger.info "#{inspect {self(), event}}"
    end
    {:noreply, [], state}
  end
end
