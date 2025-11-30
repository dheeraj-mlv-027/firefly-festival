defmodule FireflyFestival.Config do
  @moduledoc "Struct containing the configuration for FireFly Festival"

  defstruct [
    :no_of_fireflies,
    :off_duration,
    :on_duration,
    :adjustment_delta,
    :output_frequency,
    :clock_tick_rate
  ]
end
