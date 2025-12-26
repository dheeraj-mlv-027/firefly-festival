defmodule FireflyFestival do
  @moduledoc "Firefly synchronization simulation"

  @doc "Starts the Firefly simulation"
  def start(
        no_of_fireflies \\ 50,
        off_duration \\ 2.0,
        on_duration \\ 0.5,
        adjustment_delta \\ 1.0,
        output_frequency \\ 30,
        clock_tick_rate \\ 10
      ) do
    config = %FireflyFestival.Config{
      no_of_fireflies: no_of_fireflies,
      off_duration: off_duration,
      on_duration: on_duration,
      adjustment_delta: adjustment_delta,
      output_frequency: output_frequency,
      clock_tick_rate: clock_tick_rate
  }
    firefly_pids = start_fireflies(config)
    setup_neighbors(firefly_pids, config)
    display_pid=FireflyFestival.Display.start_link(firefly_pids, config)
    update_display_pid(firefly_pids,display_pid)
    Process.sleep(:infinity)
  end

  @doc "Runs the simulation for the parameter duration_seconds"
  def run_for(
        duration_seconds,
        no_of_fireflies \\ 50,
        off_duration \\ 2.0,
        on_duration \\ 0.5,
        adjustment_delta \\ 1.0,
        output_frequency \\ 30,
        clock_tick_rate \\ 10
      ) do
    config = %FireflyFestival.Config{
      no_of_fireflies: no_of_fireflies,
      off_duration: off_duration,
      on_duration: on_duration,
      adjustment_delta: adjustment_delta,
      output_frequency: output_frequency,
      clock_tick_rate: clock_tick_rate
    }
    firefly_pids = start_fireflies(config)
    setup_neighbors(firefly_pids, config)
    display_pid = FireflyFestival.Display.start_link(firefly_pids, config)

    Process.sleep(duration_seconds * 1000)

    send(display_pid, :stop)
    Enum.each(firefly_pids, fn {_id, pid} -> send(pid, :stop) end)
  end

  defp start_fireflies(config) do
    1..config.no_of_fireflies
    |> Enum.map(fn id ->
      pid = FireflyFestival.Firefly.start_link(id, config)
      {id, pid}
    end)
  end


  defp setup_neighbors(firefly_pids, config) do
    Enum.each(firefly_pids, fn {id, pid} ->
      left_neighbor_id = if id == 1, do: config.no_of_fireflies, else: id - 1
      send(pid, {:set_neighbors, left_neighbor_id, firefly_pids})
    end)
  end

  defp update_display_pid(firefly_pids,display_pid) do
    Enum.each(firefly_pids,fn {_id,pid}->
      send(pid,{:update_display_pid,display_pid})
    end)
  end

end
