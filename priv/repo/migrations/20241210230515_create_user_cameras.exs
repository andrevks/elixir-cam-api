defmodule ElixirCamApi.Repo.Migrations.CreateUserCameras do
  use Ecto.Migration

  def change do
    create table(:user_cameras) do
      add :serial_number, :string, null: false
      add :is_active, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :camera_id, references(:cameras, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_cameras, [:serial_number])
  end
end
