defmodule ElixirCamApiWeb.NotifyUserTest do
  use ElixirCamApiWeb.ConnCase, async: true
  import Swoosh.TestAssertions
  alias ElixirCamApi.{Repo, User, Camera}

  setup do
    # Create a user with a Hikvision camera
    user =
      Repo.insert!(%User{
        name: "Test User",
        email: "test_user@example.com",
        deactivated_at: nil
      })

    Repo.insert_all(Camera, [
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
      }
    ])

    # Create another user with non-Hikvision cameras
    other_user =
      Repo.insert!(%User{
        name: "Another User",
        email: "other_user@example.com",
        deactivated_at: nil
      })

    Repo.insert!(%Camera{
      name: "Camera Three",
      brand: "Giga",
      is_active: true,
      user_id: other_user.id,
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      updated_at: DateTime.truncate(DateTime.utc_now(), :second)
    })

    {:ok, user: user, other_user: other_user}
  end

  test "POST /notify-users sends emails only to users with Hikvision cameras", %{conn: conn} do
    # Call the notify-users endpoint
    conn = post(conn, "/api/notify-users")

    # Assert the response
    assert json_response(conn, 200)["message"] ==
             "Notifications sent to users with Hikvision cameras."

    # Assert that an email was sent to the user with a Hikvision camera
    assert_email_sent(fn email ->
      assert email.to == [{"Test User", "test_user@example.com"}]
      assert email.subject == "Hikvision Camera Notification"
      assert email.html_body =~ "<li><strong>Name:</strong> Hikvision</li>"
    end)
  end
end
