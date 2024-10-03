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
                     "name" => "some name"
                   }
                 ]
               }
             }
    end
  end

  defp create_user_with_cameras(_) do
    cameras = [%{brand: "Hikvision", is_active: true}, %{brand: "Intelbras", is_active: false}]
    user = user_fixture(%{cameras: cameras})

    %{user: user}
  end
end
