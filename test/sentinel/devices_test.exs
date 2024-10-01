defmodule Sentinel.DevicesTest do
  use Sentinel.DataCase

  alias Sentinel.Devices

  describe "cameras" do
    alias Sentinel.Devices.Camera

    import Sentinel.AccountsFixtures
    import Sentinel.DevicesFixtures

    @invalid_attrs %{brand: nil, is_active: nil, user_id: nil}

    test "list_cameras/0 returns all cameras" do
      camera = camera_fixture()
      assert Devices.list_cameras() == [camera]
    end

    test "get_camera!/1 returns the camera with given id" do
      camera = camera_fixture()
      assert Devices.get_camera!(camera.id) == camera
    end

    test "create_camera/1 with valid data creates a camera" do
      user = user_fixture()
      valid_attrs = %{brand: "some brand", is_active: true, user_id: user.id}

      assert {:ok, %Camera{} = camera} = Devices.create_camera(valid_attrs)
      assert camera.brand == "some brand"
      assert camera.is_active == true
    end

    test "create_camera/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_camera(@invalid_attrs)
    end

    test "update_camera/2 with valid data updates the camera" do
      camera = camera_fixture()
      update_attrs = %{brand: "some updated brand", is_active: false}

      assert {:ok, %Camera{} = camera} = Devices.update_camera(camera, update_attrs)
      assert camera.brand == "some updated brand"
      assert camera.is_active == false
    end

    test "update_camera/2 with invalid data returns error changeset" do
      camera = camera_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_camera(camera, @invalid_attrs)
      assert camera == Devices.get_camera!(camera.id)
    end

    test "delete_camera/1 deletes the camera" do
      camera = camera_fixture()
      assert {:ok, %Camera{}} = Devices.delete_camera(camera)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_camera!(camera.id) end
    end

    test "change_camera/1 returns a camera changeset" do
      camera = camera_fixture()
      assert %Ecto.Changeset{} = Devices.change_camera(camera)
    end
  end
end
