defmodule ElixirCamApi.UserCamera do
  use Ecto.Schema
  import Ecto.Changeset


  schema "user_cameras" do
    field :serial_number, :string
    field :is_active, :boolean, default: false

    belongs_to(:user, ElixirCamApi.User)
    belongs_to(:camera, ElixirCamApi.Camera)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_camera, attrs) do
    user_camera
    |> cast(attrs, [:serial_number, :is_active, :user_id, :camera_id])
    |> validate_required([:serial_number, :is_active, :user_id, :camera_id])
    |> unique_constraint(:serial_number)
  end


end
