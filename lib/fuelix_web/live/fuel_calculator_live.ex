defmodule FuelixWeb.FuelCalculatorLive do
  use FuelixWeb, :live_view

  alias Fuelix.FuelCalculator

  defp format_number(nil), do: 0

  defp format_number(number) when is_number(number) do
    number
    |> trunc()
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:mass, "")
     |> assign(:flight_path, [])
     |> assign(:total_fuel, 0)
     |> assign(:error, nil)
     |> assign(:form, to_form(%{"mass" => ""}))}
  end

  @impl true
  def handle_event("validate", %{"mass" => mass}, socket) do
    {:noreply,
     socket
     |> assign(:mass, mass)
     |> assign(:form, to_form(%{"mass" => mass}))
     |> calculate_fuel()}
  end

  @impl true
  def handle_event("add_step", _params, socket) do
    new_step = %{
      id: System.unique_integer([:positive]),
      action: "launch",
      planet: "Earth"
    }

    {:noreply,
     socket
     |> assign(:flight_path, socket.assigns.flight_path ++ [new_step])
     |> calculate_fuel()}
  end

  @impl true
  def handle_event("remove_step", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)

    {:noreply,
     socket
     |> assign(:flight_path, List.delete_at(socket.assigns.flight_path, index))
     |> calculate_fuel()}
  end

  @impl true
  def handle_event(
        "update_step",
        %{"index" => index} = params,
        socket
      ) do
    index = String.to_integer(index)
    flight_path = socket.assigns.flight_path
    current_step = Enum.at(flight_path, index)

    updated_step =
      params
      |> Map.drop(["index"])
      |> Enum.reduce(current_step, fn {key, value}, step ->
        Map.put(step, String.to_atom(key), value)
      end)

    updated_path = List.replace_at(flight_path, index, updated_step)

    {:noreply,
     socket
     |> assign(:flight_path, updated_path)
     |> calculate_fuel()}
  end

  @impl true
  def handle_event("clear_error", _params, socket) do
    {:noreply,
     socket
     |> assign(:error, nil)
     |> clear_flash()}
  end

  defp calculate_fuel(socket) do
    socket.assigns.mass
    |> parse_mass()
    |> case do
      {:ok, mass} ->
        FuelCalculator.calculate_total_fuel(mass, socket.assigns.flight_path)
        |> case do
          {:ok, fuel} ->
            assign(socket, :total_fuel, fuel)

          {:error, reason} ->
            assign(socket, :total_fuel, nil)
            |> assign(:error, reason)
            |> put_flash(:error, reason)
        end

      {:error, reason} ->
        assign(socket, :total_fuel, nil)
        |> assign(:error, reason)
        |> put_flash(:error, reason)
    end
  end

  defp parse_mass(mass) when is_binary(mass) do
    case Float.parse(mass) do
      {num, _} when num > 0 ->
        {:ok, num}

      {_mass, ""} ->
        {:error, "Mass must be greater than 0"}

      _ ->
        {:error, "Invalid mass value.  Please enter a valid number"}
    end
  end

  defp parse_mass(_), do: 0

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <div class="container mx-auto px-4 py-8 max-w-4xl">
        <%!-- Header --%>
        <div class="text-center mb-12">
          <h1 class="text-5xl font-bold text-white mb-3 tracking-tight">
            🚀 Fuel Calculator
          </h1>

          <p class="text-purple-200 text-lg">
            Calculate fuel requirements for your space mission
          </p>
        </div>

        <%!-- Error Display --%>
        <%= if @error do %>
          <div
            class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4"
            role="alert"
          >
            <strong class="font-bold">Error!</strong>
            <span class="block sm:inline">{@error}</span>
            <button
              phx-click="clear_error"
              class="absolute top-0 bottom-0 right-0 px-4 py-3"
              type="button"
            >
              <span class="text-2xl">&times;</span>
            </button>
          </div>
        <% end %>

        <%!-- Main Card --%>
        <div class="bg-white/10 backdrop-blur-lg rounded-2xl shadow-2xl border border-white/20 p-8 mb-8">
          <%!-- Mass Input Section --%>
          <div class="mb-8">
            <label class="block text-white text-sm font-semibold mb-3">
              Spacecraft Mass (kg)
            </label>
            <.form for={@form} id="mass-form" phx-change="validate">
              <.input
                field={@form[:mass]}
                type="number"
                placeholder="Enter spacecraft mass..."
                class="w-full bg-white/20 border-white/30 text-white placeholder-purple-200 focus:border-purple-400 focus:ring-purple-400 input"
                min="0"
                step="0.01"
              />
            </.form>
          </div>

          <%!-- Flight Path Section --%>
          <div class="mb-8">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-white text-xl font-semibold">Flight Path</h2>
              <button
                phx-click="add_step"
                class={[
                  "px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg",
                  "font-medium transition-all duration-200 shadow-lg hover:shadow-xl",
                  "transform hover:scale-105 active:scale-95"
                ]}
              >
                <.icon name="hero-plus" class="w-5 h-5 inline-block mr-1" /> Add Step
              </button>
            </div>

            <%= if @flight_path == [] do %>
              <div class="bg-white/5 border-2 border-dashed border-white/20 rounded-xl p-12 text-center">
                <.icon name="hero-rocket-launch" class="w-16 h-16 text-purple-300 mx-auto mb-4" />
                <p class="text-purple-200 text-lg mb-2">No flight path defined</p>
                <p class="text-purple-300 text-sm">Click "Add Step" to start building your mission</p>
              </div>
            <% else %>
              <div class="space-y-3">
                <%= for {step, index} <- Enum.with_index(@flight_path) do %>
                  <div class={[
                    "bg-white/10 border border-white/20 rounded-xl p-4",
                    "transition-all duration-200 hover:bg-white/15"
                  ]}>
                    <div class="flex items-center gap-4">
                      <%!-- Step Number --%>
                      <div class="flex-shrink-0 w-10 h-10 bg-purple-600 rounded-full flex items-center justify-center font-bold text-white">
                        {index + 1}
                      </div>

                      <.form
                        for={%{}}
                        phx-change="update_step"
                        phx-value-index={index}
                        phx-value-field="action"
                        class="flex flex-1 gap-4"
                      >
                        <%!-- Action Select --%>
                        <div class="flex-1">
                          <select
                            name="action"
                            phx-change="update_step"
                            phx-value-index={index}
                            phx-value-field="action"
                            class="w-full bg-white/20 border-white/30 text-white rounded-lg px-3 py-2 focus:border-purple-400 focus:ring-purple-400"
                          >
                            <option value="launch" selected={step.action == "launch"}>Launch</option>
                            <option value="land" selected={step.action == "land"}>Land</option>
                          </select>
                        </div>

                        <%!-- Planet Select --%>
                        <div class="flex-1">
                          <select
                            name="planet"
                            phx-change="update_step"
                            phx-value-index={index}
                            phx-value-field="planet"
                            class="w-full bg-white/20 border-white/30 text-white rounded-lg px-3 py-2 focus:border-purple-400 focus:ring-purple-400"
                          >
                            <%= for {planet, _gravity} <- FuelCalculator.planets() do %>
                              <option value={planet} selected={step.planet == planet}>
                                {planet}
                              </option>
                            <% end %>
                          </select>
                        </div>
                      </.form>

                      <%!-- Remove Button --%>
                      <button
                        phx-click="remove_step"
                        phx-value-index={index}
                        class={[
                          "flex-shrink-0 w-10 h-10 bg-red-600 hover:bg-red-700",
                          "rounded-lg flex items-center justify-center",
                          "transition-all duration-200 transform hover:scale-110 active:scale-95"
                        ]}
                        title="Remove step"
                      >
                        <.icon name="hero-trash" class="w-5 h-5 text-white" />
                      </button>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <%!-- Results Section --%>
          <div class={[
            "bg-gradient-to-r from-purple-600 to-pink-600 rounded-xl p-6",
            "border-2 border-white/30 shadow-xl"
          ]}>
            <div class="flex items-center justify-between">
              <div>
                <p class="text-purple-100 text-sm font-medium mb-1">Total Fuel Required</p>
                <p class="text-white text-4xl font-bold">
                  <%= if @total_fuel > 0 do %>
                    {format_number(@total_fuel)}
                    <span class="text-2xl font-normal">kg</span>
                  <% else %>
                    <span class="text-2xl font-normal text-purple-200">
                      Enter mass and flight path
                    </span>
                  <% end %>
                </p>
              </div>
              <div class="text-6xl">
                ⛽
              </div>
            </div>
          </div>
        </div>

        <%!-- Example Scenarios --%>
        <div class="bg-white/5 backdrop-blur rounded-xl border border-white/20 p-6">
          <h3 class="text-white text-lg font-semibold mb-4">Example Scenarios</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="bg-white/5 rounded-lg p-4 border border-white/10">
              <h4 class="text-purple-300 font-semibold mb-2">Apollo 11 Mission</h4>
              <p class="text-purple-200 text-sm mb-2">Mass: 28,801 kg</p>
              <p class="text-purple-200 text-sm mb-2">
                Path: Launch Earth → Land Moon → Launch Moon → Land Earth
              </p>

              <p class="text-white font-bold">Fuel: 51,898 kg</p>
            </div>
            <div class="bg-white/5 rounded-lg p-4 border border-white/10">
              <h4 class="text-purple-300 font-semibold mb-2">Mars Mission</h4>
              <p class="text-purple-200 text-sm mb-2">Mass: 14,606 kg</p>
              <p class="text-purple-200 text-sm mb-2">
                Path: Launch Earth → Land Mars → Launch Mars → Land Earth
              </p>

              <p class="text-white font-bold">Fuel: 33,388 kg</p>
            </div>
            <div class="bg-white/5 rounded-lg p-4 border border-white/10">
              <h4 class="text-purple-300 font-semibold mb-2">Passenger Ship</h4>
              <p class="text-purple-200 text-sm mb-2">Mass: 75,432 kg</p>
              <p class="text-purple-200 text-sm mb-2">Path: Earth → Moon → Mars → Earth</p>
              <p class="text-white font-bold">Fuel: 212,161 kg</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
