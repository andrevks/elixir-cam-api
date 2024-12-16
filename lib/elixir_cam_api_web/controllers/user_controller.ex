defmodule ElixirCamApiWeb.UserController do
  use ElixirCamApiWeb, :controller

  alias ElixirCamApi.UserContext, as: Users
  alias ElixirCamApi.Users.Formatter

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

    paginated_users = Users.list_users_with_cameras(options)

    json(conn, %{
      data: Formatter.format_users(paginated_users.entries),
      meta: %{
        page: paginated_users.page_number,
        per_page: paginated_users.page_size,
        total_pages: paginated_users.total_pages,
        total_entries: paginated_users.total_entries
      }
    })
  end

  @doc """
  Notify all users with active Hikvision cameras.
  """
  def notify(conn, _params) do
    Users.notify_users()

    json(conn, %{message: "Notifications sent to users with Hikvision cameras."})
  end
end
