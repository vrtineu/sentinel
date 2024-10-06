defmodule SentinelWeb.SchemaTest do
  use SentinelWeb.ConnCase, async: true

  import Sentinel.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "query: usersWithActiveCameras" do
    setup [:create_user_with_cameras]

    @users_with_active_cameras_query """
    query {
      usersWithActiveCameras {
        name
        isActive
        deactivatedAt
        cameras {
          brand
          isActive
        }
      }
    }
    """

    test "get list of users with their active cameras", %{conn: conn} do
      conn =
        post(conn, "/api", %{
          "query" => @users_with_active_cameras_query
        })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "usersWithActiveCameras" => [
                   %{
                     "cameras" => [%{"brand" => "Hikvision", "isActive" => true}],
                     "isActive" => true,
                     "deactivatedAt" => nil,
                     "name" => "some name"
                   }
                 ]
               }
             }
    end

    test "get list of users with active cameras and deactivated_at unless user is active", %{
      conn: conn
    } do
      %{user: user} = create_inactive_user_with_cameras()

      conn =
        post(conn, "/api", %{
          "query" => @users_with_active_cameras_query
        })

      deactivated_at =
        user
        |> Map.get(:deactivated_at)
        |> DateTime.to_iso8601()

      assert json_response(conn, 200) == %{
               "data" => %{
                 "usersWithActiveCameras" => [
                   %{
                     "cameras" => [%{"brand" => "Hikvision", "isActive" => true}],
                     "deactivatedAt" => nil,
                     "isActive" => true,
                     "name" => "some name"
                   },
                   %{
                     "cameras" => [],
                     "deactivatedAt" => deactivated_at,
                     "isActive" => false,
                     "name" => "some name"
                   }
                 ]
               }
             }
    end
  end

  defp create_user_with_cameras(_) do
    cameras = [%{brand: "Hikvision", is_active: true, name: "some_name"}, %{brand: "Intelbras", is_active: false, name: "some name"}]
    user = user_fixture(%{cameras: cameras})

    %{user: user}
  end

  defp create_inactive_user_with_cameras() do
    cameras = [%{brand: "Hikvision", is_active: false, name: "some_name"}, %{brand: "Intelbras", is_active: false, name: "some_name"}]

    user =
      user_fixture(%{
        cameras: cameras,
        is_active: false,
        deactivated_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })

    %{user: user}
  end
end
