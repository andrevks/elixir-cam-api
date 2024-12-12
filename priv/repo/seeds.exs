alias ElixirCamApi.Repo
alias ElixirCamApi.User
alias ElixirCamApi.Camera
alias ElixirCamApi.UserCamera

defmodule SeedScript do
  def run do
    {time, _result} = :timer.tc(fn -> seed_database() end)
    IO.puts("Seeding completed in #{time / 1_000_000} seconds")
  end

  defp seed_database do
    brands = ["Intelbras", "Hikvision", "Giga", "Vivotek"]

    # Pre-generate cameras (50 unique cameras)
    cameras =
      Enum.map(1..50, fn _ ->
        %{
          brand: Enum.random(brands),
          model: "Model #{Ecto.UUID.generate()}",
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
          updated_at: DateTime.truncate(DateTime.utc_now(), :second)
        }
      end)

    # Insert all cameras in batches
    camera_ids = batch_insert(cameras, Camera)

    # Generate 1,000 users and their user-camera associations
    users =
      Enum.map(1..1000, fn i ->
        %{
          name: "User Test #{i}",
          email: "user_test#{i}_#{Ecto.UUID.generate()}@example.com",
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
          updated_at: DateTime.truncate(DateTime.utc_now(), :second)
        }
      end)

    # Insert users in batches
    user_ids = batch_insert(users, User)

    # Generate user-camera associations
    user_cameras =
      Enum.flat_map(user_ids, fn user_id ->
        Enum.map(Enum.take_random(camera_ids, 10), fn camera_id ->
          %{
            user_id: user_id,
            camera_id: camera_id,
            serial_number: unique_serial_number(user_id, camera_id),
            is_active: Enum.random([true, false]),
            inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
            updated_at: DateTime.truncate(DateTime.utc_now(), :second)
          }
        end)
      end)

    # Insert user-camera associations in batches
    batch_insert(user_cameras, UserCamera)
  end

  defp unique_serial_number(user_id, camera_id) do
    "SN-#{user_id}-#{camera_id}-#{Ecto.UUID.generate()}"
  end

  # Helper function to insert data in batches
  defp batch_insert(data, schema_module, batch_size \\ 1000) do
    Enum.chunk_every(data, batch_size)
    |> Enum.flat_map(fn batch ->
      {:ok, ids} =
        Repo.transaction(fn ->
          Repo.insert_all(schema_module, batch, returning: [:id])
          |> case do
            {_, ids} -> Enum.map(ids, & &1.id)
          end
        end)

      ids
    end)
  end
end

SeedScript.run()
