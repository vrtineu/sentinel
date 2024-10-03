# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sentinel.Repo.insert!(%Sentinel.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Sentinel.Repo
alias Sentinel.Accounts.User
alias Sentinel.Devices.Camera

user_names = ~w(Vinicius Livia Lucas Rodrigo Vitória Ricardo Esther Felipe)
camera_brands = ~w(Intelbras Hikvision Giga Vivotek)

generate_users = fn size ->
  utc_now = DateTime.utc_now() |> DateTime.truncate(:second)
  default_data = %{name: Enum.random(user_names), inserted_at: utc_now, updated_at: utc_now}

  users =
    Enum.map(1..(size - 1), fn _ ->
      is_active = Enum.random([true, false])
      deactivated_at = unless is_active, do: utc_now, else: nil
      Map.merge(default_data, %{is_active: is_active, deactivated_at: deactivated_at})
    end)

  # ensure at least one user is active
  control_record = Map.merge(default_data, %{is_active: true})

  [control_record | users]
end

camera_data = fn %User{} = user ->
  utc_now = DateTime.utc_now() |> DateTime.truncate(:second)
  default_data = %{user_id: user.id, inserted_at: utc_now, updated_at: utc_now}

  cameras =
    Enum.map(1..49, fn _ ->
      camera_status = if user.is_active, do: Enum.random([true, false]), else: false
      Map.merge(default_data, %{brand: Enum.random(camera_brands), is_active: camera_status})
    end)

  # ensure at least one camera is active if user is also active
  control_record =
    Map.merge(default_data, %{brand: Enum.random(camera_brands), is_active: user.is_active})

  [control_record | cameras]
end

generate_cameras = fn users -> Enum.flat_map(users, fn user -> camera_data.(user) end) end

total_users = 1000
batch_size = 100

Repo.transaction(fn ->
  1..total_users
  |> Stream.chunk_every(batch_size)
  |> Enum.each(fn chunk ->
    users = generate_users.(length(chunk))
    {_, recorded_users} = Repo.insert_all(User, users, returning: [:id, :is_active])

    cameras = generate_cameras.(recorded_users)
    Repo.insert_all(Camera, cameras)
  end)
end)
