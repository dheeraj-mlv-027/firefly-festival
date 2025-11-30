defmodule FireflyFestival.Display do
  @moduledoc "The process that displays the states of all fireflies"

  @doc "Start a new display process"
  def start_link(firefly_pids, config) do
    spawn_link(fn -> init(firefly_pids, config) end)
  end

  defp init(firefly_pids, config) do
    schedule_display(config)
    loop(firefly_pids, config)
  end

  defp loop(firefly_pids, config) do
    receive do
      :display ->
        display_fireflies(firefly_pids)
        schedule_display(config)
        loop(firefly_pids, config)

      :stop ->
        :ok
      _ ->
        loop(firefly_pids, config)
    end
  end

  defp display_fireflies(firefly_pids) do
    states =
      Enum.map(firefly_pids, fn {id, pid} ->
        send(pid, {:get_state, self()})
        {id, pid}
      end)
      |> Enum.map(fn {id, _pid} ->
        receive do
          {:state, ^id, state} -> {id, state}
        after
          100 -> {id, :off}
        end
      end)
      |> Enum.sort_by(fn {id, _state} -> id end)
      |> Enum.map(fn {_id, state} -> state end)

    IO.write(IO.ANSI.clear() <> IO.ANSI.home())

    output =
      states
      |> Enum.map(fn state ->
        case state do
          :on -> "B"
          :off -> " "
        end
      end)
      |> Enum.join()

    IO.puts(output)
  end

  defp schedule_display(config) do
    display_interval = trunc(1000 / config.output_frequency)
    Process.send_after(self(), :display, display_interval)
  end
end
