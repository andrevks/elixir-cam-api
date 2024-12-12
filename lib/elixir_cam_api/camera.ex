defmodule ElixirCamApi.Camera do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cameras" do
    field :brand, :string
    field :model, :string

    many_to_many(:users, ElixirCamApi.User, join_through: "user_cameras")

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(camera, attrs) do
    camera
    |> cast(attrs, [:brand, :model])
    |> validate_required([:brand, :model])
  end
end
