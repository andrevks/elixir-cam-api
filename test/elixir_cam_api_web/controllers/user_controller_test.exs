defmodule ElixirCamApiWeb.UserControllerTest do
  use ElixirCamApiWeb.ConnCase, async: true
  alias ElixirCamApi.{Repo, User, Camera}

  setup do
    user =
      Repo.insert!(%User{
        name: "Test User",
        email: "test_user@example.com",
        deactivated_at: nil
      })

    cameras = [
      %{
        name: "Camera One",
        brand: "Hikvision",
        is_active: true,
        user_id: user.id,
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        name: "Camera Two",
        brand: "Giga",
        is_active: false,
        user_id: user.id,
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        name: "Camera Three",
        brand: "Intelbras",
        is_active: true,
        user_id: user.id,
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      }
    ]

    Repo.insert_all(Camera, cameras)

    {:ok, user: user}
  end

  test "GET /api/cameras returns paginated results", %{conn: conn} do
    conn = get(conn, "/api/cameras", %{"page" => "1", "per_page" => "2"})

    assert json_response(conn, 200)["meta"]["per_page"] == 2
    assert json_response(conn, 200)["meta"]["page"] == 1

    data = json_response(conn, 200)["data"]
    assert length(data) == 1  # Since only one user exists in the setup

    cameras = data |> hd() |> Map.get("cameras")
    assert length(cameras) == 2
  end

  test "GET /api/cameras filters by camera_brand", %{conn: conn} do
    conn = get(conn, "/api/cameras", %{"camera_brand" => "Hikvision"})

    data = json_response(conn, 200)["data"]
    assert length(data) == 1  # Only one user

    cameras = data |> hd() |> Map.get("cameras")
    assert length(cameras) == 1
    assert Enum.all?(cameras, fn camera -> camera["brand"] == "Hikvision" end)
  end

  test "GET /api/cameras filters by camera_name", %{conn: conn} do
    conn = get(conn, "/api/cameras", %{"camera_name" => "One"})

    data = json_response(conn, 200)["data"]
    assert length(data) == 1

    cameras = data |> hd() |> Map.get("cameras")
    assert length(cameras) == 1
    assert Enum.all?(cameras, fn camera -> camera["name"] == "Camera One" end)
  end

  test "GET /api/cameras filters by both camera_brand and camera_name", %{conn: conn} do
    conn = get(conn, "/api/cameras", %{"camera_brand" => "Hikvision", "camera_name" => "One"})

    data = json_response(conn, 200)["data"]
    assert length(data) == 1

    cameras = data |> hd() |> Map.get("cameras")
    assert length(cameras) == 1
    assert Enum.all?(cameras, fn camera ->
             camera["brand"] == "Hikvision" and camera["name"] == "Camera One"
           end)
  end

  test "GET /api/cameras returns results ordered by brand", %{conn: conn} do
    conn = get(conn, "/api/cameras", %{"order_by" => "brand"})

    data = json_response(conn, 200)["data"]
    cameras = data |> hd() |> Map.get("cameras")
    camera_brands = Enum.map(cameras, fn camera -> camera["brand"] end)

    assert camera_brands == Enum.sort(camera_brands)
  end

  test "GET /api/cameras ignores unsupported filters gracefully", %{conn: conn} do
    conn = get(conn, "/api/cameras", %{"unsupported_filter" => "value"})

    assert json_response(conn, 200)
  end

  test "GET /api/cameras handles large per_page values", %{conn: conn} do
    conn = get(conn, "/api/cameras", %{"page" => "1", "per_page" => "1000"})

    data = json_response(conn, 200)["data"]
    cameras = data |> hd() |> Map.get("cameras")

    assert length(cameras) <= 1000
  end

  test "GET /api/cameras handles invalid pagination gracefully", %{conn: conn} do
    conn = get(conn, "/api/cameras", %{"page" => "-1", "per_page" => "-10"})

    assert json_response(conn, 200)["meta"]["page"] == 1
    assert length(json_response(conn, 200)["data"]) > 0
  end
end
