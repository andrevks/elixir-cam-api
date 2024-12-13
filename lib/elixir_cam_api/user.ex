defmodule ElixirCamApi.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias ElixirCamApi.{Repo, User}

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

  @doc """
  List users and their cameras with optional filtering and pagination.
  """
  def list_users_with_cameras(opts \\ []) do
    IO.inspect(opts, label: "Received Options")

    page = opts[:page] || 1
    per_page = opts[:per_page] || 10
    filters = Enum.reject(opts, fn {key, _} -> key in [:page, :per_page] end)

    IO.inspect(filters, label: "Filters After Rejecting Pagination Params")

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
      IO.inspect(filter, label: "Processing Filter")
      compose_query(filter, acc)
    end)
  end

  defp compose_query({:camera_name, name}, query) do
    IO.inspect(name, label: "Applying camera_name Filter")
    where(query, [u, c], ilike(c.name, ^"%#{name}%"))
  end

  defp compose_query({:camera_brand, brand}, query) do
    IO.inspect(brand, label: "Applying camera_brand Filter")
    where(query, [u, c], ilike(c.brand, ^"%#{brand}%"))
  end

  defp compose_query({:order_by, order_by}, query) do
    IO.inspect(order_by, label: "Applying order_by Filter")
    case order_by do
      "name" -> order_by(query, [u, c], asc: c.name)
      "brand" -> order_by(query, [u, c], asc: c.brand)
      _ -> query
    end
  end

  defp compose_query(_, query) do
    IO.puts("Unsupported Filter Ignored")
    query
  end
end
