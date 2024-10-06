defmodule Sentinel.AccountsTest do
  use Sentinel.DataCase

  alias Sentinel.Accounts

  describe "users" do
    alias Sentinel.Accounts.User

    import Sentinel.AccountsFixtures

    @invalid_attrs %{name: nil, is_active: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "list_users_with_active_cameras/0 returns all users" do
      created_user =
        user_fixture(%{
          cameras: [
            %{brand: "Hikvision", is_active: true, name: "Active Camera"},
            %{brand: "Intelbras", is_active: false, name: "Inactive Camera"}
          ]
        })

      %{data: data} = Accounts.list_users_with_active_cameras()

      assert length(data) == 1
      [user] = data

      assert user.id == created_user.id
      assert length(user.cameras) == 1

      [camera] = user.cameras

      assert camera.brand == "Hikvision"
      assert camera.is_active == true
      assert camera.name == "Active Camera"
      refute Enum.any?(user.cameras, fn cam -> cam.brand == "Intelbras" end)
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", is_active: true}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.is_active == true
    end

    test "create_user/1 with valid data and associated cameras" do
      valid_attrs = %{
        name: "some name",
        is_active: true,
        cameras: [
          %{brand: "Hikvision", is_active: true, name: "some_name"},
          %{brand: "Intelbras", is_active: false, name: "some_name"}
        ]
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.is_active == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "some updated name", is_active: false}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.is_active == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
