defmodule LightButtonWeb.SortLive do
  use LightButtonWeb, :live_view

  alias LightButton.Donations

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  @permitted_sort_bys ~w(id item quantity days_until_expires)
  @permitted_sort_orders ~w(asc desc)
  def handle_params(params, _url, socket) do
    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 20)

    sort_by =
      params
      |> param_or_first_permitted("sort_by", @permitted_sort_bys)
      |> String.to_atom()

    sort_order =
      params
      |> param_or_first_permitted("sort_order", @permitted_sort_orders)
      |> String.to_atom()

    paginate_options = %{page: page, per_page: per_page}
    sort_options = %{sort_by: sort_by, sort_order: sort_order}

    donations =
      Donations.list_donations(
        paginate: paginate_options,
        sort: sort_options
      )

    socket =
      assign(socket,
        options: Map.merge(paginate_options, sort_options),
        donations: donations
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = param_to_integer(per_page, 1)

    paginate_options = %{page: socket.assigns.options.page, per_page: per_page}

    sort_options = %{
      sort_by: socket.assigns.options.sort_by,
      sort_order: socket.assigns.options.sort_order
    }

    donations =
      Donations.list_donations(
        paginate: paginate_options,
        sort: sort_options
      )

    socket =
      assign(socket,
        options: Map.merge(paginate_options, sort_options),
        donations: donations
      )

    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page,
            sort_by: socket.assigns.options.sort_by,
            sort_order: socket.assigns.options.sort_order
          )
      )

    {:noreply, socket}
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "eat-now", else: "fresh"
  end

  defp pagination_link(socket, text, page, options, class) do
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

  defp sort_link(socket, text, sort_by, options) do
    text =
      if sort_by == options.sort_by do
        text <> emoji(options.sort_order)
      else
        text
      end

    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          sort_by: sort_by,
          sort_order: toggle_sort_order(options.sort_order),
          page: options.page,
          per_page: options.per_page
        )
    )
  end

  defp param_to_integer(nil, default_value), do: default_value

  defp param_to_integer(param, default_value) do
    case Integer.parse(param) do
      {number, _} ->
        number

      :error ->
        default_value
    end
  end

  defp param_or_first_permitted(params, key, permitted) do
    value = params[key]
    if value in permitted, do: value, else: hd(permitted)
  end

  defp toggle_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp emoji(:asc), do: "👇"
  defp emoji(:desc), do: "☝"
end
