defmodule ElixirCamApi.Users.Formatter do
  @moduledoc """
  Responsible for formatting user data for API responses.
  """

  @doc """
  Formats a list of users with their associated cameras into the desired structure.
  """
  def format_users(users) do
    users
    |> Enum.group_by(fn %{user_email: email} -> email end)
    |> Enum.map(fn {email, records} ->
      %{
        name: records |> hd() |> Map.get(:user_name),
        email: email,
        deactivated_at: records |> hd() |> Map.get(:deactivated_at),
        cameras: Enum.map(records, fn record ->
          %{
            name: record.camera_name,
            brand: record.camera_brand
          }
        end)
      }
    end)
  end
end
