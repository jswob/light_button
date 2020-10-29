defmodule LightButtonWeb.VolunteersLive do
  use LightButtonWeb, :live_view

  alias LightButton.Volunteers

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    socket =
      assign(socket,
        volunteers: volunteers
      )

    {:ok, socket}
  end
end
