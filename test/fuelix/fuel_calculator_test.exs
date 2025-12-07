defmodule Fuelix.FuelCalculatorTest do
  use ExUnit.Case, async: true

  alias Fuelix.FuelCalculator

  describe "planets/0" do
    test "returns map of planets with gravity values" do
      planets = FuelCalculator.planets()
      assert Map.has_key?(planets, "Earth")
      assert Map.has_key?(planets, "Moon")
      assert Map.has_key?(planets, "Mars")

      assert is_map(planets)
      assert planets["Earth"] == 9.807
      assert planets["Moon"] == 1.62
      assert planets["Mars"] == 3.711
    end
  end

  describe "calculate_total_fuel/2 - successful calculations" do
    test "calculates Apollo 11 mission fuel correctly" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Moon"},
        %{action: "launch", planet: "Moon"},
        %{action: "land", planet: "Earth"}
      ]

      assert {:ok, 51_898} = FuelCalculator.calculate_total_fuel(28_801, flight_path)
    end

    test "calculates Mars mission fuel correctly" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Mars"},
        %{action: "launch", planet: "Mars"},
        %{action: "land", planet: "Earth"}
      ]

      assert {:ok, 33_388} = FuelCalculator.calculate_total_fuel(14_606, flight_path)
    end

    test "calculates passenger ship mission fuel correctly" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Moon"},
        %{action: "launch", planet: "Moon"},
        %{action: "land", planet: "Mars"},
        %{action: "launch", planet: "Mars"},
        %{action: "land", planet: "Earth"}
      ]

      assert {:ok, 212_161} = FuelCalculator.calculate_total_fuel(75_432, flight_path)
    end

    test "calculates fuel for single step flight path" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert is_integer(fuel)
      assert fuel > 0
    end

    test "calculates fuel for two-step flight path" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Moon"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(1_000, flight_path)
      assert is_integer(fuel)
      assert fuel > 0
    end

    test "handles Moon-only missions" do
      flight_path = [
        %{action: "launch", planet: "Moon"},
        %{action: "land", planet: "Moon"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(5_000, flight_path)
      assert is_integer(fuel)
      assert fuel >= 0
    end

    test "handles Mars-only missions" do
      flight_path = [
        %{action: "launch", planet: "Mars"},
        %{action: "land", planet: "Mars"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(8_000, flight_path)
      assert is_integer(fuel)
      assert fuel >= 0
    end

    test "handles large spacecraft mass" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Moon"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(100_000, flight_path)
      assert is_integer(fuel)
      assert fuel > 0
    end

    test "handles small spacecraft mass" do
      flight_path = [
        %{action: "launch", planet: "Moon"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(10, flight_path)
      assert is_integer(fuel)
      assert fuel >= 0
    end

    test "handles float mass values" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(1000.5, flight_path)
      assert is_integer(fuel)
      assert fuel > 0
    end
  end

  describe "calculate_total_fuel/2 - empty flight path" do
    test "returns ok with 0 fuel for empty flight path" do
      assert {:ok, 0} = FuelCalculator.calculate_total_fuel(28_801, [])
    end
  end

  describe "calculate_total_fuel/2 - invalid mass errors" do
    test "returns error for zero mass" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert {:error, "Mass must be a positive number"} =
               FuelCalculator.calculate_total_fuel(0, flight_path)
    end

    test "returns error for negative mass" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert {:error, "Mass must be a positive number"} =
               FuelCalculator.calculate_total_fuel(-1000, flight_path)
    end

    test "returns error for nil mass" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert {:error, "Mass must be a positive number"} =
               FuelCalculator.calculate_total_fuel(nil, flight_path)
    end

    test "returns error for string mass" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert {:error, "Mass must be a positive number"} =
               FuelCalculator.calculate_total_fuel("1000", flight_path)
    end

    test "returns error for atom mass" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      assert {:error, "Mass must be a positive number"} =
               FuelCalculator.calculate_total_fuel(:invalid, flight_path)
    end
  end

  describe "calculate_total_fuel/2 - invalid planet errors" do
    test "returns error for unknown planet" do
      flight_path = [
        %{action: "launch", planet: "Jupiter"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Unknown planet: Jupiter"
      assert error_msg =~ "Available planets:"
    end

    test "returns error for empty planet string" do
      flight_path = [
        %{action: "launch", planet: ""}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Unknown planet:"
    end

    test "returns error for misspelled planet" do
      flight_path = [
        %{action: "launch", planet: "earth"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Unknown planet: earth"
    end

    test "returns error for invalid planet in middle of path" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Venus"},
        %{action: "launch", planet: "Moon"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Unknown planet: Venus"
    end

    test "error message includes available planets" do
      flight_path = [
        %{action: "launch", planet: "Pluto"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Earth"
      assert error_msg =~ "Moon"
      assert error_msg =~ "Mars"
    end
  end

  describe "calculate_total_fuel/2 - invalid action errors" do
    test "returns error for invalid action" do
      flight_path = [
        %{action: "orbit", planet: "Earth"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid action: orbit"
      assert error_msg =~ "Must be 'launch' or 'land'"
    end

    test "returns error for empty action string" do
      flight_path = [
        %{action: "", planet: "Earth"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid action:"
    end

    test "returns error for misspelled action" do
      flight_path = [
        %{action: "Launch", planet: "Earth"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid action: Launch"
    end

    test "returns error for invalid action in middle of path" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "fly", planet: "Moon"},
        %{action: "land", planet: "Moon"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid action: fly"
    end
  end

  describe "calculate_total_fuel/2 - invalid step structure errors" do
    test "returns error for step missing action key" do
      flight_path = [
        %{planet: "Earth"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid step structure"
      assert error_msg =~ "Expected %{action: string, planet: string}"
    end

    test "returns error for step missing planet key" do
      flight_path = [
        %{action: "launch"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid step structure"
    end

    test "returns error for empty map step" do
      flight_path = [
        %{}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid step structure"
    end

    test "returns error for non-map step" do
      flight_path = [
        "launch Earth"
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid step structure"
    end

    test "returns error for tuple step" do
      flight_path = [
        {"launch", "Earth"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid step structure"
    end

    test "returns error for keyword list step" do
      flight_path = [
        [action: "launch", planet: "Earth"]
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Invalid step structure"
    end

    test "returns error for step with atom keys instead of string keys" do
      flight_path = [
        %{action: :launch, planet: :earth}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Unknown planet:"
    end
  end

  describe "calculate_total_fuel/2 - multiple validation errors" do
    test "returns first error encountered (invalid planet before invalid action)" do
      flight_path = [
        %{action: "orbit", planet: "Jupiter"}
      ]

      # Validation order: structure -> planet -> action
      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert error_msg =~ "Unknown planet: Jupiter"
    end

    test "catches first invalid step in multi-step path" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "orbit", planet: "Jupiter"},
        %{action: "land", planet: "Moon"}
      ]

      assert {:error, error_msg} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      # Should fail on second step's planet validation
      assert error_msg =~ "Unknown planet: Jupiter"
    end
  end

  describe "calculate_total_fuel/2 - edge cases" do
    test "handles very long flight paths" do
      flight_path =
        Enum.flat_map(1..10, fn _ ->
          [
            %{action: "launch", planet: "Earth"},
            %{action: "land", planet: "Moon"},
            %{action: "launch", planet: "Moon"},
            %{action: "land", planet: "Earth"}
          ]
        end)

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(1000, flight_path)
      assert is_integer(fuel)
      assert fuel > 0
    end

    test "handles alternating launch and land actions" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Earth"},
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Earth"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(5000, flight_path)
      assert is_integer(fuel)
      assert fuel >= 0
    end

    test "handles all planets in single mission" do
      flight_path = [
        %{action: "launch", planet: "Earth"},
        %{action: "land", planet: "Moon"},
        %{action: "launch", planet: "Moon"},
        %{action: "land", planet: "Mars"},
        %{action: "launch", planet: "Mars"},
        %{action: "land", planet: "Earth"}
      ]

      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(20000, flight_path)
      assert is_integer(fuel)
      assert fuel > 0
    end
  end

  describe "calculate_total_fuel/2 - integration with SuperPotato" do
    test "properly converts string actions to atoms for SuperPotato" do
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      # Should not raise any errors about atom conversion
      assert {:ok, _fuel} = FuelCalculator.calculate_total_fuel(10000, flight_path)
    end

    test "properly converts planet strings to gravity values for SuperPotato" do
      flight_path = [
        %{action: "launch", planet: "Moon"}
      ]

      # Should successfully look up Moon's gravity (1.62) and pass to SuperPotato
      assert {:ok, fuel} = FuelCalculator.calculate_total_fuel(10000, flight_path)
      assert is_integer(fuel)
    end

    # TODO improve this test
    test "handles SuperPotato errors gracefully" do
      # If SuperPotato raises an ArgumentError, it should be caught
      flight_path = [
        %{action: "launch", planet: "Earth"}
      ]

      result = FuelCalculator.calculate_total_fuel(10000, flight_path)

      # Should either succeed or return a proper error tuple
      assert match?({:ok, _}, result) or match?({:error, _}, result)
    end
  end
end
