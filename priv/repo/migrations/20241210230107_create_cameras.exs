defmodule ElixirCamApi.Repo.Migrations.CreateCameras do
  use Ecto.Migration

  def change do
    create table(:cameras) do
      add :name, :string, null: false
      add :brand, :string, null: false
      add :is_active, :boolean, default: false

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:cameras, [:user_id])
  end
end
