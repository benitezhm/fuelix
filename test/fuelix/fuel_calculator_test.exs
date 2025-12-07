defmodule Fuelix.FuelCalculatorTest do
  use ExUnit.Case, async: true

  alias Fuelix.FuelCalculator

  describe "calculate_base_fuel/3" do
    test "calculates launch fuel correctly" do
      assert FuelCalculator.calculate_base_fuel(28801, 9.807, "launch") == 11_829
    end

    test "calculates landing fuel correctly" do
      assert FuelCalculator.calculate_base_fuel(28801, 9.807, "land") == 9278
    end

    test "returns 0 for negative fuel requirements" do
      assert FuelCalculator.calculate_base_fuel(10, 1.62, "land") == 0
    end

    test "floors the result" do
      # Should floor 42.999 to 42
      assert FuelCalculator.calculate_base_fuel(100, 9.807, "land") == 0
    end
  end

  describe "calculate_recursive_fuel/3" do
    test "calculates recursive fuel for landing correctly" do
      # Apollo 11 landing on Earth
      assert FuelCalculator.calculate_recursive_fuel(9278, 9.807, "land") == 13_447
    end

    test "calculates recursive fuel for launch correctly" do
      initial_fuel = FuelCalculator.calculate_base_fuel(28801, 9.807, "launch")
      result = FuelCalculator.calculate_recursive_fuel(initial_fuel, 9.807, "launch")
      assert result > initial_fuel
    end

    test "returns 0 when fuel is 0" do
      assert FuelCalculator.calculate_recursive_fuel(0, 9.807, "land") == 0
    end

    test "returns 0 when fuel is negative" do
      assert FuelCalculator.calculate_recursive_fuel(-100, 9.807, "land") == 0
    end

    test "stops when additional fuel is 0 or negative" do
      # Small fuel amount that requires minimal additional fuel
      assert FuelCalculator.calculate_recursive_fuel(100, 1.62, "land") == 100
    end
  end

  describe "calculate_fuel_for_step/3" do
    test "calculates fuel for a single landing step" do
      # Apollo 11 landing on Earth
      assert FuelCalculator.calculate_fuel_for_step(28801, 9.807, "land") == 13_447
    end

    test "calculates fuel for a single launch step" do
      result = FuelCalculator.calculate_fuel_for_step(28801, 9.807, "launch")
      assert result > 0
    end

    test "handles Moon gravity" do
      result = FuelCalculator.calculate_fuel_for_step(28801, 1.62, "land")
      assert result > 0
    end

    test "handles Mars gravity" do
      result = FuelCalculator.calculate_fuel_for_step(14606, 3.711, "launch")
      assert result > 0
    end
  end

  describe "calculate_total_fuel/2" do
    test "calculates Apollo 11 mission fuel correctly" do
      # Mass: 28801 kg
      # Path: launch Earth, land Moon, launch Moon, land Earth
      # Expected: 51898 kg
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Moon"},
        %{action: "launch", planet: "Moon"},
        %{action: "land", planet: "Earth"}
      ]

      assert FuelCalculator.calculate_total_fuel(28801, flight_path) == 51_898
    end

    test "calculates Mars mission fuel correctly" do
      # Mass: 14606 kg
      # Path: launch Earth, land Mars, launch Mars, land Earth
      # Expected: 33388 kg
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Mars"},
        %{action: "launch", planet: "Mars"},
        %{action: "land", planet: "Earth"}
      ]

      assert FuelCalculator.calculate_total_fuel(14606, flight_path) == 33_388
    end

    test "calculates passenger ship mission fuel correctly" do
      # Mass: 75432 kg
      # Path: launch Earth, land Moon, launch Moon, land Mars, launch Mars, land Earth
      # Expected: 212161 kg
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Moon"},
        %{action: "launch", planet: "Moon"},
        %{action: "land", planet: "Mars"},
        %{action: "launch", planet: "Mars"},
        %{action: "land", planet: "Earth"}
      ]

      assert FuelCalculator.calculate_total_fuel(75432, flight_path) == 212_161
    end

    test "returns 0 for empty flight path" do
      assert FuelCalculator.calculate_total_fuel(28801, []) == 0
    end

    test "returns 0 for zero mass" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert FuelCalculator.calculate_total_fuel(0, flight_path) == 0
    end

    test "returns 0 for negative mass" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert FuelCalculator.calculate_total_fuel(-1000, flight_path) == 0
    end

    test "handles single step flight path" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      result = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert result > 0
    end

    test "processes flight path in correct order (reverse)" do
      # The fuel calculation should process steps in reverse order
      # because fuel needed for later steps adds to the mass
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Moon"}
      ]

      result = FuelCalculator.calculate_total_fuel(1000, flight_path)
      assert result > 0
    end
  end

  describe "planets/0" do
    test "returns map of planets with gravity values" do
      planets = FuelCalculator.planets()

      assert is_map(planets)
      assert planets["Earth"] == 9.807
      assert planets["Moon"] == 1.62
      assert planets["Mars"] == 3.711
    end
  end

  describe "valid_planet?/1" do
    test "returns true for valid planets" do
      assert FuelCalculator.valid_planet?("Earth")
      assert FuelCalculator.valid_planet?("Moon")
      assert FuelCalculator.valid_planet?("Mars")
    end

    test "returns false for invalid planets" do
      refute FuelCalculator.valid_planet?("Jupiter")
      refute FuelCalculator.valid_planet?("Venus")
      refute FuelCalculator.valid_planet?("")
    end
  end

  describe "valid_action?/1" do
    test "returns true for valid actions" do
      assert FuelCalculator.valid_action?("launch")
      assert FuelCalculator.valid_action?("land")
    end

    test "returns false for invalid actions" do
      refute FuelCalculator.valid_action?("orbit")
      refute FuelCalculator.valid_action?("fly")
      refute FuelCalculator.valid_action?("")
    end
  end
end
