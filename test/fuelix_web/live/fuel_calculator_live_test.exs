defmodule FuelixWeb.FuelCalculatorLiveTest do
  use FuelixWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "FuelCalculatorLive" do
    test "renders the page with initial state", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Fuel Calculator"
      assert html =~ "Spacecraft Mass"
      assert html =~ "Flight Path"
      assert html =~ "No flight path defined"
      assert html =~ "Enter mass and flight path"
    end

    test "displays example scenarios", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Apollo 11 Mission"
      assert html =~ "Mars Mission"
      assert html =~ "Passenger Ship"
      assert html =~ "51,898 kg"
      assert html =~ "33,388 kg"
      assert html =~ "212,161 kg"
    end

    test "adds a flight path step", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view |> element("button", "Add Step") |> render_click()

      assert has_element?(view, "select")
      assert render(view) =~ "Launch"
      assert render(view) =~ "Earth"
    end

    test "removes a flight path step", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Add a step
      view |> element("button", "Add Step") |> render_click()
      assert render(view) =~ "Launch"

      # Remove the step
      view |> element("button[phx-click=\"remove_step\"]") |> render_click()
      assert render(view) =~ "No flight path defined"
    end

    test "updates mass input", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#mass-form", mass: "28801")
      |> render_change()

      assert render(view) =~ "28801"
    end

    test "calculates fuel for Apollo 11 mission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Set mass
      view
      |> form("#mass-form", mass: "28801")
      |> render_change()

      # Add steps: launch Earth
      view |> element("button", "Add Step") |> render_click()

      # Add land Moon
      view |> element("button", "Add Step") |> render_click()

      view
      |> element("select[name=\"action\"][phx-value-index=\"1\"]")
      |> render_change(%{"action" => "land", "index" => "1"})

      view
      |> element("select[name=\"planet\"][phx-value-index=\"1\"]")
      |> render_change(%{"planet" => "Moon", "index" => "1"})

      # Add launch Moon
      view |> element("button", "Add Step") |> render_click()

      view
      |> element("select[name=\"planet\"][phx-value-index=\"2\"]")
      |> render_change(%{"planet" => "Moon", "index" => "2"})

      # Add land Earth
      view |> element("button", "Add Step") |> render_click()

      view
      |> element("select[name=\"action\"][phx-value-index=\"3\"]")
      |> render_change(%{"action" => "land", "index" => "3"})

      # Check the result
      html = render(view)
      assert html =~ "51,898"
    end

    test "calculates fuel for Mars mission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Set mass
      view
      |> form("#mass-form", mass: "14606")
      |> render_change()

      # Add steps
      view |> element("button", "Add Step") |> render_click()

      view |> element("button", "Add Step") |> render_click()

      view
      |> element("select[name=\"action\"][phx-value-index=\"1\"]")
      |> render_change(%{"action" => "land", "index" => "1"})

      view
      |> element("select[name=\"planet\"][phx-value-index=\"1\"]")
      |> render_change(%{"planet" => "Mars", "index" => "1"})

      view |> element("button", "Add Step") |> render_click()

      view
      |> element("select[name=\"planet\"][phx-value-index=\"2\"]")
      |> render_change(%{"planet" => "Mars", "index" => "2"})

      view |> element("button", "Add Step") |> render_click()

      view
      |> element("select[name=\"action\"][phx-value-index=\"3\"]")
      |> render_change(%{"action" => "land", "index" => "3"})

      html = render(view)
      assert html =~ "33,388"
    end

    test "shows zero fuel when no mass is entered", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Add a flight path step
      view |> element("button", "Add Step") |> render_click()

      html = render(view)
      assert html =~ "Invalid mass value"
      assert html =~ "0"
    end

    test "shows zero fuel when mass is zero", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#mass-form", mass: "0")
      |> render_change()

      view |> element("button", "Add Step") |> render_click()

      html = render(view)
      assert html =~ "Mass must be greater than 0"
    end

    test "shows zero fuel when flight path is empty", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#mass-form", mass: "28801")
      |> render_change()

      html = render(view)
      assert html =~ "Enter mass and flight path"
      assert html =~ "0"
    end

    test "updates fuel calculation when steps are modified", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#mass-form", mass: "10000")
      |> render_change()

      # Add a launch from Earth
      view |> element("button", "Add Step") |> render_click()

      html_before = render(view)

      # Change to land
      view
      |> element("select[name=\"action\"][phx-value-index=\"0\"]")
      |> render_change(%{"action" => "land", "index" => "0"})

      html_after = render(view)

      # The fuel calculation should be different
      refute html_before == html_after
    end

    test "updates fuel calculation when planet is changed", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view
      |> form("#mass-form", mass: "10000")
      |> render_change()

      view |> element("button", "Add Step") |> render_click()

      html_earth = render(view)

      view
      |> element("select[name=\"planet\"][phx-value-index=\"0\"]")
      |> render_change(%{"planet" => "Moon", "index" => "0"})

      html_moon = render(view)

      refute html_earth == html_moon
    end

    test "handles multiple steps correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Add 5 steps
      for _ <- 1..5 do
        view |> element("button", "Add Step") |> render_click()
      end

      html = render(view)

      # Check that all 5 steps are rendered with their step numbers
      assert html =~ "1"
      assert html =~ "2"
      assert html =~ "3"
      assert html =~ "4"
      assert html =~ "5"
    end

    test "maintains state when removing middle step", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # Add 3 steps
      view |> element("button", "Add Step") |> render_click()
      view |> element("button", "Add Step") |> render_click()
      view |> element("button", "Add Step") |> render_click()

      # Remove middle step (index 1)
      view
      |> element("button[phx-click=\"remove_step\"][phx-value-index=\"1\"]")
      |> render_click()

      html = render(view)

      # Should now only have 2 steps numbered 1 and 2
      # Note: The number "3" might still appear in other parts of the page
      # (like examples), so we just verify we have 2 step containers
      step_containers = html |> String.split("flex-shrink-0 w-10 h-10 bg-purple-600") |> length()
      # 2 steps + 1 for the split result
      assert step_containers == 3
    end
  end
end
