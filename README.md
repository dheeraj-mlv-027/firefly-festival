# Firefly Festival Simulation - Edge Assignment

## Clone the repo 
```
git clone https://github.com/dheeraj-mlv-027/firefly-festival.git

cd firefly-festival

```

## Installation 

```bash
brew update 
brew install elixir
```

## 1. Compile the Code

```bash
cd firefly_festival
mix compile
```

## 2. Run the Simulation

Start the interactive Elixir shell:

```bash
iex -S mix
```

Run the simulation (runs indefinitely until Ctrl+C):

```elixir
FireflyFestival.start()
```


## 3. Configure Variables

```
FireflyFestival.start(
  no_of_fireflies,      # Number of fireflies (default: 50)
  off_duration,         # Time firefly stays off in seconds (default: 2.0)
  on_duration,          # Time firefly stays on in seconds (default: 0.5)
  adjustment_delta,     # Time adjustment when influenced by neighbor (default: 1.0)
  output_frequency,     # Display refresh rate per second (default: 30)
  clock_tick_rate       # Internal clock ticks per second (default: 10)
)
```

**Parameter descriptions:**
- **`no_of_fireflies`**: The number of firefly processes to spawn
- **`off_duration`**: The time for which the firefly remains off
- **`on_duration`**: The time for which the firefly remains on
- **`adjustment_delta`**:Time reduced if the left neighbour blinks
- **`output_frequency`**:The number of times per second the display updates
- **`clock_tick_rate`**: The number of ticks per second


## 3.LLM Usage
Utilized LLMs for the following tasks 

1.For learning the fundementals of functional programming 
2.Data Types and Control 
3.Process and Concurrency 
4.Broadcasting,Mailbox,pattern matching



