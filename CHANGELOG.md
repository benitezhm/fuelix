# Changelog
<!-- next-header -->

## [Unreleased] - ReleaseDate
### Added

#### Core Features
* **Spacecraft Fuel Calculator**: Complete implementation of fuel calculation logic
  - leveraging SuperPotato library for recursive fuel calculation
  - Support for three planets: Earth (9.807 m/s²), Moon (1.62 m/s²), Mars (3.711 m/s²)

#### Backend (`lib/fuelix/`)
* `FuelCalculator` module adapter with the following public functions:
  - `calculate_total_fuel/2` - Calculate total fuel for complete mission
  - `planets/0` - Get supported planets and gravity values

#### Frontend (`lib/fuelix_web/`)
* `FuelCalculatorLive` LiveView module with:
  - Real-time fuel calculation updates
  - Dynamic flight path builder (add/remove/update steps)
  - Mass input with live validation
  - Formatted number display (e.g., 51,898 kg)
  - Example scenarios showcase
  - Modern UI with Tailwind CSS and Heroicons

#### UI/UX Features
- Beautiful gradient space-themed interface
- Real-time calculation updates (no submit button needed)
- Interactive flight path builder
- Step numbering and visual indicators
- Dropdown selectors for actions (launch/land) and planets
- Remove button for each step
- Empty state messaging
- Example missions (Apollo 11, Mars Mission, Passenger Ship)

#### Testing
- ** backend tests** in `test/fuelix/fuel_calculator_test.exs`:
  - Base fuel calculation tests
  - Complete mission scenario tests (Apollo 11, Mars, Passenger Ship)
  - Edge case tests (zero mass, empty path, negative values)
  - Validation tests
- ** LiveView tests** in `test/fuelix_web/live/fuel_calculator_live_test.exs`:
  - Page rendering tests
  - User interaction tests (add/remove/update steps)
  - Real-time calculation tests
  - State management tests
- All 60 tests passing ✅

#### Documentation
- `README.md` - Comprehensive project documentation
- `PROJECT_SUMMARY.md` - Detailed implementation overview
- `QUICKSTART.md` - Quick start guide for developers
- `CHANGELOG.md` - This file
- Inline code documentation with `@doc` annotations

#### Verified Calculations
All example scenarios tested and verified:
- **Apollo 11 Mission**: 28,801 kg mass → 51,898 kg fuel ✓
- **Mars Mission**: 14,606 kg mass → 33,388 kg fuel ✓
- **Passenger Ship**: 75,432 kg mass → 212,161 kg fuel ✓

### Technical Stack
- Phoenix Framework 1.8.2
- Phoenix LiveView 1.1.0
- Elixir 1.15+
- Tailwind CSS v4 (via @import)
- Heroicons v2.2.0
- ExUnit for testing
- Phoenix.LiveViewTest for LiveView testing
- LazyHTML for test assertions

### Development Tools
- `mix precommit` - Run compilation, format, and tests
- `mix test` - Run all tests
- `mix format` - Format code
- `mix credo` - Code quality analysis with Credo
- `mix coveralls` Code coverage reporting with ExUnit
- `mix dialyzer` Static analysis tool for detecting bugs and performance issues

### Project Structure
```
fuelix/
├── lib/
│   ├── fuelix/
│   │   └── fuel_calculator.ex          # Core calculation logic (100% coverage)
│   └── fuelix_web/
│       └── live/
│           └── fuel_calculator_live.ex # LiveView interface (97.73% coverage)
├── test/
│   ├── fuelix/
│   │   └── fuel_calculator_test.exs
│   └── fuelix_web/
│       └── live/
│           └── fuel_calculator_live_test.exs
├── README.md
├── PROJECT_SUMMARY.md
├── QUICKSTART.md
└── CHANGELOG.md
```
