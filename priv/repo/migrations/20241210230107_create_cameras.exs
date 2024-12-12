defmodule ElixirCamApi.Repo.Migrations.CreateCameras do
  use Ecto.Migration

  def change do
    create table(:cameras) do
      add :brand, :string, null: false
      add :model, :string


      timestamps(type: :utc_datetime)
    end
  end
end
