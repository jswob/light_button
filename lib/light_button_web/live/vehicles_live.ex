defmodule LightButtonWeb.VehiclesLive do
  use LightButtonWeb, :live_view

  alias LightButton.Vehicles

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [vehicles: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")

    pagination_options = %{page: page, per_page: per_page}
    vehicles = Vehicles.list_vehicles(paginate: pagination_options)

    socket =
      assign(socket,
        vehicles: vehicles,
        options: pagination_options
      )

    {:noreply, socket}
  end
end
