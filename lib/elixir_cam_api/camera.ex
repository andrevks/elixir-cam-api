defmodule ElixirCamApi.Camera do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cameras" do
    field :name, :string
    field :brand, :string
    field :is_active, :boolean, default: false

    belongs_to(:user, ElixirCamApi.User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(camera, attrs) do
    camera
    |> cast(attrs, [:brand, :name, :is_active, :user_id])
    |> validate_required([:brand, :name, :is_active, :user_id])
  end
end
