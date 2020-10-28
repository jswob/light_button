defmodule LightButtonWeb.VehiclesLive do
  use LightButtonWeb, :live_view

  alias LightButton.Vehicles

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [vehicles: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")

    sort_by = String.to_atom(params["sort_by"] || "id")
    sort_order = String.to_atom(params["sort_order"] || "asc")

    pagination_options = %{page: page, per_page: per_page}
    sorting_options = %{sort_by: sort_by, sort_order: sort_order}

    vehicles = Vehicles.list_vehicles(paginate: pagination_options, sort: sorting_options)

    socket =
      assign(socket,
        vehicles: vehicles,
        options: Map.merge(pagination_options, sorting_options)
      )

    {:noreply, socket}
  end

  def handle_event("switch_per_page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    options = socket.assigns.options

    pagination_options = %{page: options.page, per_page: per_page}
    sorting_options = %{sort_by: options.sort_by, sort_order: options.sort_order}
    vehicles = Vehicles.list_vehicles(paginate: pagination_options, sort: sorting_options)

    socket =
      assign(socket,
        vehicles: vehicles,
        options: Map.merge(pagination_options, sorting_options)
      )

    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: pagination_options[:page],
            per_page: pagination_options[:per_page],
            sort_by: sorting_options[:sort_by],
            sort_order: sorting_options[:sort_order]
          )
      )

    {:noreply, socket}
  end

  defp pagination_view(socket, text, page, options, class) do
    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          page: page,
          per_page: options.per_page,
          sort_by: options.sort_by,
          sort_order: options.sort_order
        ),
      class: class
    )
  end

  defp sorting_view(socket, text, sort_by, options) do
    text =
      if sort_by == options.sort_by do
        text <> emoji(options.sort_order)
      else
        text
      end

    sort_order =
      if sort_by == options.sort_by do
        toggle_sort_order(options.sort_order)
      else
        :asc
      end

    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          page: options.page,
          per_page: options.per_page,
          sort_by: sort_by,
          sort_order: sort_order
        )
    )
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc

  defp emoji(:asc), do: "👇"
  defp emoji(:desc), do: "☝"
end
