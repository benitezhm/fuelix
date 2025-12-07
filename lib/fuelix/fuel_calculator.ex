defmodule Fuelix.FuelCalculator do
  @moduledoc """
  Calculates fuel requirements for spacecraft missions using the SuperPotato library.

  This module acts as an adapter between the LiveView application and the SuperPotato
  library, handling string-to-atom conversions and providing a user-friendly interface.
  """

  @planets %{
    "Earth" => 9.807,
    "Moon" => 1.62,
    "Mars" => 3.711
  }

  @doc """
  Returns the list of supported planets with their gravity values.

  ## Examples

      iex> Fuelix.FuelCalculator.planets()
      %{
        "Earth" => 9.807,
        "Moon" => 1. 62,
        "Mars" => 3.721,
        ...
      }
  """
  def planets, do: @planets

  @doc """
  Calculates total fuel required for a complete flight path using SuperPotato.

  ## Parameters
    - mass: The spacecraft mass in kg (positive integer)
    - flight_path: A list of steps, each step is a map with :action and :planet keys

  ## Examples

      iex> Fuelix.FuelCalculator.calculate_total_fuel(28801, [
      ...>   %{action: "launch", planet: "Earth"},
      ...>   %{action: "land", planet: "Moon"},
      ...>   %{action: "launch", planet: "Moon"},
      ...>   %{action: "land", planet: "Earth"}
      ...> ])
      51898

  """
  def calculate_total_fuel(mass, flight_path) when is_number(mass) and mass > 0 do
    with :ok <- validate_flight_path(flight_path),
         {:ok, converted_path} <- convert_flight_path(flight_path) do
      fuel = SuperPotato.calculate_required_fuel(mass, converted_path)

      {:ok, fuel}
    else
      {:error, reason} -> {:error, reason}
    end
  rescue
    e in ArgumentError ->
      {:error, Exception.message(e)}
  catch
    {:error, reason} -> {:error, reason}
  end

  def calculate_total_fuel(_mass, _flight_path) do
    {:error, "Mass must be a positive number"}
  end

  # Private Functions

  defp validate_flight_path([]), do: :ok

  defp validate_flight_path(flight_path) do
    Enum.reduce_while(flight_path, :ok, fn step, :ok ->
      with :ok <- validate_step_structure(step),
           :ok <- validate_planet(step.planet),
           :ok <- validate_action(step.action) do
        {:cont, :ok}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      :ok -> :ok
      {:error, reason} -> throw({:error, reason})
    end
  end

  defp validate_step_structure(%{action: _, planet: _}), do: :ok

  defp validate_step_structure(step) do
    {:error,
     "Invalid step structure.  Expected %{action: string, planet: string}, got: #{inspect(step)}"}
  end

  defp validate_planet(planet) do
    if valid_planet?(planet) do
      :ok
    else
      available = planets() |> Map.keys() |> Enum.join(", ")
      {:error, "Unknown planet: #{planet}. Available planets: #{available}"}
    end
  end

  defp validate_action(action) do
    if valid_action?(action) do
      :ok
    else
      {:error, "Invalid action: #{action}.  Must be 'launch' or 'land'"}
    end
  end

  defp valid_planet?(planet) do
    Map.has_key?(@planets, planet)
  end

  defp valid_action?(action) do
    action in ["launch", "land"]
  end

  defp convert_flight_path(flight_path) do
    converted =
      Enum.map(flight_path, fn %{action: action, planet: planet} ->
        gravity = Map.fetch!(@planets, planet)
        action_atom = string_to_action_atom(action)

        %{action: action_atom, gravity: gravity}
      end)

    {:ok, converted}
  end

  defp string_to_action_atom("launch"), do: :launch
  defp string_to_action_atom("land"), do: :land
end
