defmodule LightButtonWeb.LightLive do
  use LightButtonWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        brightness: 10,
        temp: 4000
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
      <h1>Front Porch Light</h1>
      <div id="light">
        <div class="meter">
          <span style="width: <%= @brightness %>%; background-color: <%= temp_color(@temp) %>">
            <%= @brightness %>
          </span>
        </div>

        <button phx-click="off">
          <img src="images/light-off.svg">
        </button>

        <button phx-click="down">
          <img src="images/down.svg">
        </button>

        <button phx-click="on">
          <img src="images/light-on.svg">
        </button>

        <button phx-click="up">
          <img src="images/up.svg">
        </button>

        <button phx-click="random">
          <img src="images/random.svg">
        </button>

        <form phx-change="update">
          <input type="range" min="0" max="100"
                name="brightness" value="<%= @brightness %>" />
        </form>

        <form phx-change="switch-color">
          <input type="radio" id="3000" name="temp" value="3000"
            <%= if 3000 == @temp, do: "checked" %> />
          <label for="3000">3000</label>

          <input type="radio" id="4000" name="temp" value="4000"
              <%= if 4000 == @temp, do: "checked" %> />
          <label for="4000">4000</label>

          <input type="radio"id="5000" name="temp" value="5000"
              <%= if 5000 == @temp, do: "checked" %> />
          <label for="5000">5000</label>
        </form>

      </div>
    """
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, 100)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, 0)
    {:noreply, socket}
  end

  def handle_event("random", _, socket) do
    socket = assign(socket, :brightness, :rand.uniform(100))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("update", %{"brightness" => brightness}, socket) do
    {brightness, _} = Integer.parse(brightness)
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end

  def handle_event("switch-color", %{"temp" => temp}, socket) do
    {temp, _} = Integer.parse(temp)
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"
end
