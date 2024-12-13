alias ElixirCamApi.Repo
alias ElixirCamApi.User
alias ElixirCamApi.Camera

defmodule SeedScript do
  def run do
    {time, _result} = :timer.tc(fn -> seed_database() end)
    IO.puts("Seeding completed in #{time / 1_000_000} seconds")
  end

  defp seed_database do
    brands = ["Intelbras", "Hikvision", "Giga", "Vivotek"]

    # Generate 1,000 users
    users =
      Enum.map(1..1000, fn i ->
        %{
          name: "User Test #{i}",
          email: "user_test#{i}_#{Ecto.UUID.generate()}@example.com",
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
          updated_at: DateTime.truncate(DateTime.utc_now(), :second)
        }
      end)

    # Insert users in batches and retrieve their IDs
    user_ids = batch_insert(users, User)

    # Generate cameras for users
    Task.async_stream(
      user_ids,
      fn user_id ->
        cameras =
          Enum.map(1..50, fn _ ->
            %{
              name: "Camera #{Ecto.UUID.generate()}",
              brand: Enum.random(brands),
              is_active: Enum.random([true, false]),
              user_id: user_id,
              inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
              updated_at: DateTime.truncate(DateTime.utc_now(), :second)
            }
          end)

        Repo.insert_all(Camera, cameras)
      end,
      max_concurrency: System.schedulers_online()
    )
    |> Stream.run()
  end

  # Helper function to insert data in batches and retrieve inserted IDs
  defp batch_insert(data, schema_module, batch_size \\ 1000) do
    Enum.chunk_every(data, batch_size)
    |> Enum.flat_map(fn batch ->
      Repo.insert_all(schema_module, batch, returning: [:id])
      |> case do
        {_, rows} -> Enum.map(rows, & &1.id)
      end
    end)
  end
end

SeedScript.run()
