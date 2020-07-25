defmodule Kashup.Element do
  use GenServer

  alias Kashup.Element.State

  defmodule State do
    defstruct [:value, :start_time, :expiration] 
  end

  def start_link(value, expiration) do
    GenServer.start_link(__MODULE__, [value, expiration], [])
  end

  def create(value, expiration) do
    Kashup.Element.Supervisor.start_child(value, expiration)
  end

  def create(value) do
    Kashup.Element.Supervisor.start_child(value, :infinity)
  end

  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

  def replace(pid, value) do
    GenServer.cast(pid, {:replace, value})
  end

  def delete(pid) do
    GenServer.cast(pid, :delete)
  end

  @impl true
  def init([value, expiration]) do
    start_time = DateTime.utc_now()
    {
      :ok, 
      %State{value: value, start_time: start_time, expiration: expiration},
      time_left(start_time, expiration)
    }
  end

  def time_left(_start_time, :infinity), do: :infinity
  
  def time_left(start_time, expiration) do
    elapsed = DateTime.utc_now |> DateTime.diff(start_time)
    case DateTime.diff(expiration, elapsed) do
      diff when diff <= 0 -> 0
      diff -> diff
    end
  end

  @impl true
  def handle_call(:fetch, _from, state) do
    time_left = time_left(state.start_time, state.expiration)
    {:reply, {:ok, state.value}, state, time_left}
  end

  @impl true
  def handle_cast({:replace, value}, state) do
    time_left = time_left(state.start_time, state.expiration)
    state = Map.put(state, :value, value)
    {:noreply, state, time_left}
  end

  @impl true
  def handle_cast(:delete, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(_reason, _state) do
    Kashup.Store.delete(self())
    :ok
  end
end
