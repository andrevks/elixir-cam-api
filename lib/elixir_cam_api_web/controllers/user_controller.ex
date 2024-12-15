defmodule ElixirCamApiWeb.UserController do
  use ElixirCamApiWeb, :controller

  alias ElixirCamApi.User

  @doc """
  Endpoint to list users and their active cameras.
  Supports optional filtering and sorting.
  """
  def index(conn, params) do
    options = %{
      camera_name: Map.get(params, "camera_name"),
      camera_brand: Map.get(params, "camera_brand"),
      page: String.to_integer(Map.get(params, "page", "1")),
      per_page: String.to_integer(Map.get(params, "per_page", "10")),
      order_by: Map.get(params, "order_by", "brand")
    }

    users_with_cameras =
      User.list_users_with_cameras(options)

    json(conn, %{
      data: users_with_cameras.entries,
      meta: %{
        page: users_with_cameras.page_number,
        per_page: users_with_cameras.page_size,
        total_pages: users_with_cameras.total_pages,
        total_entries: users_with_cameras.total_entries
      }
    })
  end

  @doc """
  Notify all users with active Hikvision cameras.
  """
  def notify(conn, _params) do
    User.notify_users()

    json(conn, %{message: "Notifications sent to users with Hikvision cameras."})
  end
end
