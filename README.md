# Fuelix - Spacecraft Fuel Calculator

A Phoenix LiveView application for calculating fuel requirements for spacecraft missions based on mass, gravity, and flight path.

![Demo](./demo.gif)

## Overview

This application calculates the required fuel for spacecraft missions considering:
- Launch and landing operations
- Different planetary gravities (Earth, Moon, Mars)
- Recursive fuel calculation (fuel for the fuel) with helo of [SuperPotato](https://github.com/benitezhm/super-potato) library

## Features

- **Real-time Calculations**: Instant fuel requirement updates using Phoenix LiveView
- **Dynamic Flight Path Builder**: Add/remove mission steps dynamically
- **Multiple Planet Support**: Earth, Moon, and Mars with accurate gravity constants
- **Beautiful UI**: Modern, responsive interface with Tailwind CSS
- **Comprehensive Tests**: Full test coverage for calculation logic and UI interactions

## Installation

### Prerequisites

- Elixir 1.15 or later
- Erlang/OTP 26 or later
- Node.js 18+ (for asset compilation)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd fuelix
```

2. Install dependencies:
```bash
mix setup
```

3. Start the Phoenix server:
```bash
mix phx.server
```

4. Visit [`localhost:4000`](http://localhost:4000) in your browser.

## Usage

1. **Enter Spacecraft Mass**: Input the spacecraft mass in kilograms
2. **Build Flight Path**: Click "Add Step" to add launch/land operations
3. **Configure Steps**: Select the action (launch/land) and planet for each step
4. **View Results**: The total fuel requirement updates in real-time

### Example: Apollo 11 Mission

- **Mass**: 28801 kg
- **Flight Path**:
  1. Launch from Earth
  2. Land on Moon
  3. Launch from Moon
  4. Land on Earth
- **Total Fuel Required**: 51898 kg

## Fuel Calculation Formula

### Base Fuel Calculation

- **Launch**: `mass × gravity × 0.042 - 33` (rounded down)
- **Landing**: `mass × gravity × 0.033 - 42` (rounded down)

### Recursive Fuel Calculation

The fuel itself adds weight, requiring additional fuel. The calculation continues recursively until additional fuel needed is 0 or negative. Check [Project Summary](./PROJECT_SUMMARY.md#example-calculation-flow) for calculation examples

### Gravity Constants

- **Earth**: 9.807 m/s²
- **Moon**: 1.62 m/s²
- **Mars**: 3.711 m/s²

## Architecture

Fuelix follows a **layered architecture** pattern, separating concerns between the UI, business logic adapter, and core calculation engine:

```
┌─────────────────────────────────────┐
│   Phoenix LiveView (Presentation)   │
│   - User interface                  │
│   - Real-time updates               │
│   - Form handling                   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Adapter Layer (Business Logic)    │
│   - Input validation                │
│   - Error handling                  │
│   - String ↔ Atom conversion        │
│   - User-friendly error messages    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   SuperPotato (Calculation Engine)  │
│   - Pure fuel calculations          │
│   - Gravity-based algorithms        │
│   - Recursive fuel computation      │
└─────────────────────────────────────┘
```

### Backend (`lib/fuelix/`)
#### **`fuel_calculator.ex`** - Adapter Layer

Acts as a bridge between the Phoenix LiveView UI and the SuperPotato calculation library. 

**Key Responsibilities:**
- Validates user input (mass, planets, actions)
- Converts strings to atoms for SuperPotato compatibility
- Maps planet names to gravity values
- Provides user-friendly error messages
- Returns `{:ok, result}` or `{:error, reason}` tuples

**Main Functions:**

- **`calculate_total_fuel/2`**
  
  Validates and calculates total fuel for a complete flight path.  Converts string-based steps to SuperPotato format and returns error tuples for invalid inputs. 
  
  ```elixir
  @spec calculate_total_fuel(number(), [%{action: String. t(), planet: String.t()}]) ::
    {:ok, non_neg_integer()} | {:error, String.t()}
  
  # Example:
  Fuelix.FuelCalculator.calculate_total_fuel(28_801, [
    %{action: "launch", planet: "Earth"},
    %{action: "land", planet: "Moon"}
  ])
  # => {:ok, 22380}
  ```

- **`planets/0`**
  
  Returns map of supported planets with their gravity values. Used for UI dropdowns and validation.
  
  ```elixir
  %{
    "Earth" => 9.807,
    "Moon" => 1.62,
    "Mars" => 3.721
  }
  ```

**Private Helper Functions:**
- `validate_flight_path/1` - Ensures valid list structure
- `validate_planet/1` - Checks planet exists in known list
- `validate_action/1` - Verifies action is "launch" or "land"
- `convert_flight_path/1` - Transforms strings to SuperPotato format
- `string_to_action_atom/1` - Converts "launch"/"land" to atoms

### External Dependency

#### **SuperPotato Library** - Core Calculation Engine

External library that handles all fuel calculation logic. 

**Installation:**
```elixir
# mix.exs
{:super_potato, git: "https://github.com/benitezhm/super-potato.git", branch: "master"}
```

**API:**
```elixir
SuperPotato.calculate_required_fuel(mass, flight_path)

# Parameters:
# - mass: integer() - spacecraft mass in kg
# - flight_path: [%{action: :launch | :land, gravity: float()}]
#
# Returns: non_neg_integer() - required fuel in kg
```

**Features:**
- Implements rocket equation with recursive fuel calculation
- Processes flight paths in reverse order
- Accounts for fuel's own weight
- Flexible gravity-based system (works with any planetary body)
- Comprehensive test coverage
- Available at [SuperPotato](https://github.com/benitezhm/super-potato)

**Example:**
```elixir
SuperPotato.calculate_required_fuel(28_801, [
  %{action: :launch, gravity: 9.807},  # Earth launch
  %{action: :land, gravity: 1.62}      # Moon landing
])
# => 22380
```

### Frontend (`lib/fuelix_web/`)

- **`live/fuel_calculator_live.ex`**: LiveView module
  - Real-time updates on mass/flight path changes
  - Dynamic step management (add/remove/update)
  - Instant fuel calculation display

## Testing

Run all tests:
```bash
mix test
```

Run specific test file:
```bash
mix test test/fuelix/fuel_calculator_test.exs
```

Run with coverage:
```bash
mix test --cover
```

### Test Coverage

- **Backend Logic**: Comprehensive tests for all calculation functions
- **LiveView Integration**: Tests for user interactions and real-time updates
- **Example Scenarios**: Validation against known mission profiles
```
60 tests, 0 failures
----------------
COV    FILE                                        LINES RELEVANT   MISSED
  0.0% lib/fuelix.ex                                   9        0        0
 80.0% lib/fuelix/application.ex                      33        5        1
 93.7% lib/fuelix/fuel_calculator.ex                 134       32        2
  0.0% lib/fuelix/mailer.ex                            3        0        0
100.0% lib/fuelix_web.ex                             114        2        0
 15.5% lib/fuelix_web/components/core_component      498      116       98
  0.0% lib/fuelix_web/components/layouts.ex          154       23       23
100.0% lib/fuelix_web/controllers/error_html.ex       24        1        0
100.0% lib/fuelix_web/controllers/error_json.ex       21        1        0
  0.0% lib/fuelix_web/controllers/page_controll        7        1        1
  0.0% lib/fuelix_web/controllers/page_html.ex        10        0        0
  0.0% lib/fuelix_web/endpoint.ex                     54        0        0
  0.0% lib/fuelix_web/gettext.ex                      25        0        0
 94.2% lib/fuelix_web/live/fuel_calculator_live      341       52        3
 66.6% lib/fuelix_web/router.ex                       44        3        1
 80.0% lib/fuelix_web/telemetry.ex                    70        5        1
100.0% test/support/conn_case.ex                      37        2        0
[TOTAL]  46.5%
----------------
```
## Precommit Checks

Run the full precommit suite:
```bash
mix precommit
```

This runs:
- Compilation with warnings as errors
- Dependency cleanup
- Code formatting
- All tests

## Project Structure

```
fuelix/
├── lib/
│   ├── fuelix/
│   │   └── fuel_calculator.ex          # calculation adapter
│   └── fuelix_web/
│       ├── live/
│       │   └── fuel_calculator_live.ex # LiveView interface
│       ├── components/
│       │   └── core_components.ex      # Reusable UI components
│       └── router.ex                   # Route definitions
├── test/
│   ├── fuelix/
│   │   └── fuel_calculator_test.exs    # Logic tests
│   └── fuelix_web/
│       └── live/
│           └── fuel_calculator_live_test.exs # LiveView tests
└── assets/                             # Frontend assets
```

## Development

### Code Style

- Follow Elixir style guide
- Use `mix format` and `mix credo` before committing
- Maintain test coverage for new features

### Adding New Planets

1. Update `@planets` map in `fuel_calculator.ex`
2. Add corresponding tests
3. Update documentation

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `mix precommit` to ensure quality
5. Submit a pull request

## Technology Stack

- **Phoenix Framework**: v1.8.2
- **Phoenix LiveView**: v1.1.0
- **Elixir**: v1.15+
- **Tailwind CSS**: v3+
- **Heroicons**: v2.2.0

## License
MIT
