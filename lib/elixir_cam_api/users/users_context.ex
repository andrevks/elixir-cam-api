defmodule ElixirCamApi.UserContext do
  import Ecto.Query
  alias ElixirCamApi.Emails.UserEmail
  alias ElixirCamApi.{Repo, User}
  alias ElixirCamApi.Mailer

  @doc """
    Notify all users with active Hikvision cameras asynchronously.
    This method fetches users with active Hikvision cameras and sends notifications.
  """
  def notify_users do
    users_with_cameras()
    |> Enum.each(fn {user, cameras} ->
      Enum.each(cameras, fn camera ->
        send_email_async(user, camera)
      end)
    end)
  end

  defp users_with_cameras(camera_name \\ "Hikvision") do
    from(u in User,
      join: c in assoc(u, :cameras),
      where: c.brand == ^camera_name and c.is_active == true,
      select: {u, c}
    )
    |> Repo.all()
    |> Enum.group_by(fn {user, _camera} -> user end, fn {_user, camera} -> camera end)
  end

  defp send_email_async(user, camera) do
    if Mix.env() == :test do
      # Deliver email synchronously during testing
      user
      |> UserEmail.notify_user(camera)
      |> Mailer.deliver()
    else
      # Use async delivery in non-test environments
      Task.Supervisor.start_child(ElixirCamApi.TaskSupervisor, fn ->
        user
        |> UserEmail.notify_user(camera)
        |> Mailer.deliver()
      end)
    end
  end

  @doc """
  List users and their cameras with optional filtering and pagination.
  """
  def list_users_with_cameras(opts \\ []) do
    page = opts[:page] || 1
    per_page = opts[:per_page] || 10
    filters = Enum.reject(opts, fn {key, _} -> key in [:page, :per_page] end)

    base_query()
    |> build_query(filters)
    |> Repo.paginate(page: page, page_size: per_page)
  end

  defp base_query do
    from u in User,
      join: c in assoc(u, :cameras),
      where: is_nil(u.deactivated_at) or u.deactivated_at > ^DateTime.utc_now(),
      where: c.is_active == true,
      select: %{
        user_name: u.name,
        user_email: u.email,
        deactivated_at: u.deactivated_at,
        camera_name: c.name,
        camera_brand: c.brand
      }
  end

  defp build_query(query, criteria) do
    Enum.reduce(criteria, query, fn filter, acc ->
      compose_query(filter, acc)
    end)
  end

  defp compose_query({:camera_name, name}, query) do
    where(query, [u, c], ilike(c.name, ^"%#{name}%"))
  end

  defp compose_query({:camera_brand, brand}, query) do
    where(query, [u, c], ilike(c.brand, ^"%#{brand}%"))
  end

  defp compose_query({:order_by, order_by}, query) do
    case order_by do
      "name" -> order_by(query, [u, c], asc: c.name)
      "brand" -> order_by(query, [u, c], asc: c.brand)
      _ -> query
    end
  end

  defp compose_query(_, query) do
    query
  end
end
