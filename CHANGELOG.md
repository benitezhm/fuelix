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

#### Documentation
- `README.md` - Comprehensive project documentation
- `PROJECT_SUMMARY.md` - Detailed implementation overview
- `QUICKSTART.md` - Quick start guide for developers
- `CHANGELOG.md` - This file
- Inline code documentation with `@doc` annotations
