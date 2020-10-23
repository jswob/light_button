defmodule LightButtonWeb.FlightsLive do
  use LightButtonWeb, :live_view

  alias LightButton.Flights

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        number: "",
        flights: [],
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Flight</h1>
    <div id="search">

    <form phx-submit="flight-search">
      <input type="text" name="number" value="<%= @number %>"
            placeholder="Flight number"
            autofocus autocomplete="off"
            <%= if @loading, do: "readonly" %> />

      <button type="submit">
        <img src="images/search.svg">
      </button>
    </form>

      <%= if @loading do %>
        <div class="loader">Loading...</div>
      <% end %>

      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %> to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= format_time(flight.departure_time) %>
                </div>
                <div class="arrives">
                  Arrives: <%= format_time(flight.arrival_time) %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("flight-search", %{"number" => number}, socket) do
    send(self(), {:fligh_search_procedure, number})

    socket =
      assign(socket,
        number: number,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_info({:fligh_search_procedure, number}, socket) do
    case Flights.search_by_number(number) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "None flights were found for selected number")
          |> assign(
            flights: [],
            loading: false
          )

        {:noreply, socket}

      flights ->
        socket =
          socket
          |> clear_flash()
          |> assign(
            flights: flights,
            loading: false
          )

        {:noreply, socket}
    end
  end

  defp format_time(time) do
    Timex.format!(time, "%b %d at %H:%M", :strftime)
  end
end
