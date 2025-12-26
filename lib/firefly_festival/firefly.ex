defmodule FireflyFestival.Firefly do
  @moduledoc "Individual firefly process with internal clock and state"

  defstruct [:id, :left_neighbor, :all_fireflies, :config, :state, :time_remaining,:display_pid]

  @doc "Starts a new firefly process with given id and configuration"
  def start_link(id, config) do
    spawn_link(fn -> init(id, config) end)
  end

  defp init(id, config) do
    initial_time = :rand.uniform() * config.off_duration

  state = %FireflyFestival.Firefly{
    id: id,
    config: config,
    state: :off,
    time_remaining: initial_time,
    left_neighbor: nil,
    all_fireflies: [],
    display_pid: nil
  }

    schedule_tick(config)
    loop(state)
  end

  defp loop(state) do
    receive do
      {:set_neighbors, left_neighbor, all_fireflies} ->
        loop(%{state | left_neighbor: left_neighbor, all_fireflies: all_fireflies})

      :tick ->
        new_state = handle_tick(state)
        schedule_tick(state.config)
        loop(new_state)

      {:blink, from_id} ->
        new_state = handle_blink_message(state, from_id)
        loop(new_state)

      # {:get_state, caller} ->
      #   send(caller, {:state, state.id, state.state})
      #   loop(state)

      {:update_display_pid,display_pid}->
        state=%{state | display_pid: display_pid}
        loop(state)

      :stop ->
        :ok

      _ ->
        loop(state)
    end
  end

  defp handle_tick(state) do
    tick_duration = 1.0 / state.config.clock_tick_rate
    new_time = state.time_remaining - tick_duration

    if new_time <= 0 do
      case state.state do
        :off ->
          broadcast_blink(state)
          send(state.display_pid,{:state, state.id,:on})
          %{state | state: :on, time_remaining: state.config.on_duration}

        :on ->
          send(state.display_pid,{:state, state.id,:off})
          %{state | state: :off, time_remaining: state.config.off_duration}
      end
    else
      %{state | time_remaining: new_time}
    end
  end

  defp handle_blink_message(state, from_id) do
    if from_id == state.left_neighbor and state.state == :off do
      adjustment = min(state.config.adjustment_delta, state.time_remaining)
      new_time = state.time_remaining - adjustment
      %{state | time_remaining: max(0, new_time)}
    else
      state
    end
  end

  defp broadcast_blink(state) do
    Enum.each(state.all_fireflies, fn {id, pid} ->
      if id != state.id do
        send(pid, {:blink, state.id})
      end
    end)
  end

  defp schedule_tick(config) do
    tick_interval = trunc(1000 / config.clock_tick_rate)
    Process.send_after(self(), :tick, tick_interval)
  end
end
