defmodule LightButton.Repo.Migrations.CreateVolunteers do
  use Ecto.Migration

  def change do
    create table(:volunteers) do
      add :checked_out, :boolean, default: false, null: false
      add :name, :string
      add :phone, :string

      timestamps()
    end

  end
end
