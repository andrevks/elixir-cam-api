defmodule ElixirCamApi.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :deactivated_at, :utc_datetime

    has_many(:cameras, ElixirCamApi.Camera)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :deactivated_at])
    |> validate_required([:name, :email, :deactivated_at])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

end
