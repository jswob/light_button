defmodule LightButton.Volunteers.Volunteer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "volunteers" do
    field :checked_out, :boolean, default: false
    field :name, :string
    field :phone, :string

    timestamps()
  end

  @phone ~r/^\d{3}[\s-.]?\d{3}[\s-.]?\d{4}$/

  @doc false
  def changeset(volunteer, attrs) do
    volunteer
    |> cast(attrs, [:checked_out, :name, :phone])
    |> validate_required([:name, :phone])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_format(:phone, @phone, message: "must be a valid phone number")
  end
end
