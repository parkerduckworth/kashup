defmodule Kashup.Element do
  @moduledoc """
  GenServer callback that is responsible for managing the state of a key's value.

  Afforded by the use of one GenServer process per key, Kashup is capable of storing very large
  values of arbitrary type.  Additionally, an expiration can be assigned to `Kashup.Element`'s by
  providing an integer representing the number of seconds a key/value pair should be valid for to
  the Application's configuration.

  ## Example Configuration

  Valid for one day:
  ```
  config :kashup,
    expiration: 60 * 60 * 24
  ```

  To set a key/value pair to never expire, either omit the `expiration` field from the config
  block, or set the field to `:infinity`:

  ```
  config :kashup,
    expiration: :infinity
  ```
  """
  use GenServer

  alias Kashup.Element.State

  defmodule State do
    @moduledoc """
    Container for attributes describing the state of the `Kashup.Element`
    """
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

  def time_left(_start_time, :infinity), do: :infinity
  
  @doc """
  Calculate the amount of time remaining before an element expires.
  """
  def time_left(start_time, expiration) do
    elapsed = DateTime.utc_now |> DateTime.diff(start_time)
    case DateTime.diff(expiration, elapsed) do
      diff when diff <= 0 -> 0
      diff -> diff
    end
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

  @impl true
  def handle_call(:fetch, _from, %State{} = state) do
    time_left = time_left(state.start_time, state.expiration)
    {:reply, {:ok, state.value}, state, time_left}
  end

  @impl true
  def handle_cast({:replace, value}, %State{} = state) do
    time_left = time_left(state.start_time, state.expiration)
    state = Map.put(state, :value, value)
    {:noreply, state, time_left}
  end

  @impl true
  def handle_cast(:delete, %State{} = state) do
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
