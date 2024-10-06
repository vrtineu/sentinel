defmodule Sentinel.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Devices` context.
  """

  import Sentinel.AccountsFixtures

  @doc """
  Generate a camera.
  """
  def camera_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, camera} =
      attrs
      |> Enum.into(%{
        brand: "some brand",
        is_active: true,
        name: "some_name"
      })
      |> Map.put(:user_id, user.id)
      |> Sentinel.Devices.create_camera()

    camera
  end
end
