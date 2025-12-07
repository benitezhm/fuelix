# Fuelix - Quick Start Guide

Get the Spacecraft Fuel Calculator running in under 5 minutes! 🚀

## Prerequisites

- **Elixir** 1.15 or later ([Install Elixir](https://elixir-lang.org/install.html))
- **Erlang/OTP** 26 or later (usually installed with Elixir)
- **Node.js** 18+ for asset compilation

## Installation & Setup

```bash
# 1. Navigate to the project directory
cd fuelix

# 2. Install dependencies (Phoenix, LiveView, etc.)
mix deps.get

# 3. Setup assets (Tailwind CSS, esbuild)
mix assets.setup

# 4. Compile assets
mix assets.build

# 5. Start the Phoenix server
mix phx.server
```

## Access the Application

Open your browser and navigate to:
```
http://localhost:4000
```

You should see the Fuel Calculator interface! 🎉

## Quick Test

Try the Apollo 11 mission:

1. Enter **28801** in the "Spacecraft Mass" field
2. Click **"Add Step"** 4 times to create 4 steps
3. Configure the steps:
   - Step 1: **Launch** from **Earth**
   - Step 2: **Land** on **Moon**
   - Step 3: **Launch** from **Moon**
   - Step 4: **Land** on **Earth**
4. Watch the total fuel update to **51,898 kg** ✓

## Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/fuelix/fuel_calculator_test.exs

# Run with detailed output
mix test --trace
```

All tests should pass! ✅

## Development Commands

```bash
# Format code
mix format

# Run precommit checks (compile, format, test)
mix precommit

# Start server in IEx (interactive Elixir)
iex -S mix phx.server

# Check for compilation warnings
mix compile --warnings-as-errors
```

## Project Structure (Key Files)

```
fuelix/
├── lib/
│   ├── fuelix/
│   │   └── fuel_calculator.ex          # 💡 Core calculation logic with the help of [SuperPotato](https://github.com/benitezhm/super-potato) library
│   └── fuelix_web/
│       └── live/
│           └── fuel_calculator_live.ex # 💡 LiveView interface
├── test/
│   ├── fuelix/
│   │   └── fuel_calculator_test.exs   
│   └── fuelix_web/
│       └── live/
│           └── fuel_calculator_live_test.exs 
└── README.md                            # Full documentation
```

## Troubleshooting

### Port 4000 already in use
```bash
# Kill existing Phoenix process
lsof -ti:4000 | xargs kill -9

# Or use a different port
PORT=4001 mix phx.server
```

### Dependencies won't install
```bash
# Clean and reinstall
mix deps.clean --all
mix deps.get
```

### Assets not compiling
```bash
# Reinstall asset tools
mix assets.setup
mix assets.build
```

## Next Steps

- Read the full **README.md** for detailed documentation
- Check **PROJECT_SUMMARY.md** for implementation details
- Explore the code in `lib/fuelix/fuel_calculator.ex`
- Try modifying the UI in `lib/fuelix_web/live/fuel_calculator_live.ex`

## Example Missions to Try

### Mars Mission
- Mass: **14606 kg**
- Path: Launch Earth → Land Mars → Launch Mars → Land Earth
- Expected Fuel: **33427 kg**

### Passenger Ship
- Mass: **75432 kg**
- Path: Launch Earth → Land Moon → Launch Moon → Land Mars → Launch Mars → Land Earth
- Expected Fuel: **212418 kg**

## Key Features to Explore

✨ **Real-time calculation** - Watch fuel update as you type
🛠️ **Dynamic flight path** - Add, remove steps
🌍 **Multiple planets** - Earth, Moon, Mars supported
🎨 **Beautiful UI** - Modern design with smooth animations
🧪 **Comprehensive tests** 

## Support

If you encounter issues:
1. Check the error message in the terminal
2. Review the **README.md** for detailed information
3. Ensure all prerequisites are installed correctly
4. Try the troubleshooting steps above

Happy calculating! 🚀⛽
