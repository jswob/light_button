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

  def handle_event("switch_per_page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    pagination_options = %{page: socket.assigns.options.page, per_page: per_page}
    vehicles = Vehicles.list_vehicles(paginate: pagination_options)

    socket =
      assign(socket,
        vehicles: vehicles,
        options: pagination_options
      )

    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: pagination_options[:page],
            per_page: pagination_options[:per_page]
          )
      )

    {:noreply, socket}
  end

  defp pagination_view(socket, text, page, per_page, class) do
    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          page: page,
          per_page: per_page
        ),
      class: class
    )
  end
end
