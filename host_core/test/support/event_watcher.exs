defmodule HostCoreTest.EventWatcher do
  require Gnat
  require Logger

  use GenServer

  defmodule State do
    defstruct [
      :topic,
      :sub,
      :events
    ]
  end

  @impl true
  def init(prefix) do
    topic = "wasmbus.evt.#{prefix}"
    {:ok, sub} = Gnat.sub(:control_nats, self(), topic)

    {:ok, %State{topic: topic, sub: sub, events: []}}
  end

  @impl true
  # Receives events from wasmbus.evt.prefix and stores them for later processing
  def handle_info({:msg, %{body: body}}, state) do
    evt = Jason.decode!(body)
    events = [evt | state.events]

    {:noreply, %State{events: events}}
  end

  @impl true
  def terminate(_reason, state) do
    Gnat.unsub(:control_nats, state.sub)
  end

  @impl true
  def handle_call(:events, _from, state) do
    {:reply, state.events, state}
  end

  def events_for_type(pid, type) do
    GenServer.call(pid, :events)
    |> Enum.filter(fn evt -> evt["type"] == type end)
  end

  # Determines if an event with specified type and data parameters has occurred
  def assert_received?(pid, event_type, event_data) do
    events_for_type(pid, event_type)
    |> find_matching_events(event_data)
    |> Enum.count() => 0
  end

  # Finds all events matching the specified data parameters
  defp find_matching_events(events, data) do
    Enum.filter(events, fn evt -> data_matches?(evt["data"], data) end)
  end

  # Compares two sets of data, returning true if the event contains all matching data parameters
  defp data_matches?(event_data, data) do
    data
    |> Enum.map(fn {key, value} ->
      Map.get(event_data, key) == value
    end)
    |> Enum.all?()
  end

  def actor_started?(pid, public_key) do
    events_for_type(
      pid,
      "com.wasmcloud.lattice.actor_started"
    )
    |> Enum.reduce_while(false, fn evt, _started ->
      data = evt["data"]

      if data["public_key"] == public_key do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end

  def provider_started?(pid, contract_id, link_name, public_key) do
    events_for_type(
      pid,
      "com.wasmcloud.lattice.provider_started"
    )
    |> Enum.reduce_while(false, fn evt, _started ->
      data = evt["data"]

      if data["contract_id"] == contract_id &&
           data["link_name"] == link_name &&
           data["public_key"] == public_key do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end

  def wait_for_actor_start(pid, public_key, timeout \\ 30_000) do
    cond do
      timeout <= 0 ->
        {:error, :timeout}

      actor_started?(pid, public_key) ->
        :ok

      true ->
        Logger.debug("Actor started event not received yet, retrying in 1 second")
        Process.sleep(1_000)
        wait_for_actor_start(pid, public_key, timeout - 1_000)
    end
  end

  def wait_for_provider_start(pid, contract_id, link_name, public_key, timeout \\ 30_000) do
    cond do
      timeout <= 0 ->
        {:error, :timeout}

      provider_started?(pid, contract_id, link_name, public_key) ->
        :ok

      true ->
        Logger.debug("Provider started event not received yet, retrying in 1 second")
        Process.sleep(1_000)
        wait_for_provider_start(pid, contract_id, link_name, public_key, timeout - 1_000)
    end
  end
end
