defmodule ElixirCamApi.Emails.UserEmail do
  import Swoosh.Email
  require EEx

  # Compile the HTML template
  @external_resource "lib/elixir_cam_api_web/templates/email/notify_email.html.eex"
  EEx.function_from_file(
    :defp,
    :render_html_template,
    "lib/elixir_cam_api_web/emails/notification/notify_email.html.heex",
    [:assigns]
  )

  def notify_user(user, camera) do
    new()
    |> to({user.name, user.email})
    |> from({"Cam Elixir App", "no-reply@camelixir.com"})
    |> subject("#{camera.brand} Camera Notification")
    |> html_body(render_email(user, camera))
  end

  defp render_email(user, camera) do
    assigns = %{user_name: user.name, camera_brand: camera.brand}
    render_html_template(assigns)
  end
end
