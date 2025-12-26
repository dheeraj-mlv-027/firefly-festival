defmodule FireflyFestival.Display do
  @moduledoc "The process that displays the states of all fireflies"


  @doc "Start a new display process"
  def start_link(firefly_pids, config) do
    spawn_link(fn -> init(firefly_pids, config) end)
  end

  defp init(firefly_pids, config) do
    firefly_states=Enum.map(firefly_pids,fn {id,_pid}->{id,:off} end)
    schedule_display(config)
    loop(firefly_pids, config,firefly_states)
  end

  defp loop(firefly_pids, config,states_of_fireflies) do
    receive do
      :display ->
        new_states_of_fireflies=display_fireflies(firefly_pids,states_of_fireflies)
        schedule_display(config)
        loop(firefly_pids, config,new_states_of_fireflies)

      :stop ->
        :ok
      _ ->
        loop(firefly_pids, config,states_of_fireflies)
    end
  end

  defp display_fireflies(firefly_pids,states_of_fireflies) do
    # [(1,:off)....]

    states =Enum.map(firefly_pids,fn {id, _pid} ->
        receive do
          {:state, ^id, recieved_state} ->
            # IO.puts(recieved_state)
          {id, recieved_state}
        after
          5 -> Enum.at(states_of_fireflies,id-1)
        end
      end)
      sorted_states=Enum.sort_by(states,fn {id, _state} -> id end)
      final_states=Enum.map(sorted_states,fn {_id, state} -> state end)

    IO.write(IO.ANSI.clear() <> IO.ANSI.home())
    output =
      final_states
      |> Enum.map(fn state ->
        case state do
          :on -> "B"
          :off -> " "
        end
      end)
      |> Enum.join()

    IO.puts(output)
    sorted_states
  end


  defp schedule_display(config) do
    display_interval = trunc(1000 / config.output_frequency)
    Process.send_after(self(), :display, display_interval)
  end
end
