defmodule LightButtonWeb.FlightsLive do
  use LightButtonWeb, :live_view

  alias LightButton.Flights
  alias LightButton.Airports

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        number: "",
        airport: "",
        flights: [],
        matches: [],
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

    <form phx-submit="airport-search" phx-change="suggest-airport">
        <input type="text" name="airport" value="<%= @airport %>"
                placeholder="Airport name"
                autocomplete="off" list="matches"
                phx-debounce="1000"
                <%= if @loading, do: "readonly" %> />

                <datalist id="matches">
        <%= for match  <- @matches do %>
          <option value="<%= match %>">=<%= match %></option>
        <% end %>
      </datalist>

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

  def handle_event("suggest-airport", %{"airport" => prefix}, socket) do
    matches = Airports.suggest(prefix)

    socket = assign(socket, matches: matches)
    {:noreply, socket}
  end

  def handle_event("airport-search", %{"airport" => airport}, socket) do
    send(self(), {:airport_search_procedure, airport})

    socket =
      assign(socket,
        airport: airport,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_info({:airport_search_procedure, airport}, socket) do
    case Flights.search_by_airport(airport) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "None flights were found for selected airport")
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
