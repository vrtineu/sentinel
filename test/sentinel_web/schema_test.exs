defmodule SentinelWeb.SchemaTest do
  use SentinelWeb.ConnCase, async: false

  import Sentinel.AccountsFixtures
  import Swoosh.TestAssertions

  setup :set_swoosh_global
  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "query: usersWithActiveCameras" do
    setup [:create_user_with_cameras]

    test "get list of users with their active cameras", %{conn: conn} do
      conn =
        post(conn, "/api", %{
          "query" => users_with_active_cameras_query()
        })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "usersWithActiveCameras" => %{
                   "data" => [
                     %{
                       "cameras" => [
                         %{"brand" => "Hikvision", "isActive" => true, "name" => "some_name"}
                       ],
                       "isActive" => true,
                       "name" => "some name",
                       "deactivatedAt" => nil
                     }
                   ],
                   "pageNumber" => 1,
                   "pageSize" => 10,
                   "totalData" => 1,
                   "totalPages" => 1
                 }
               }
             }
    end

    test "get list of users with active cameras and deactivated_at unless user is active", %{
      conn: conn
    } do
      %{user: user} = create_inactive_user_with_cameras()

      conn =
        post(conn, "/api", %{
          "query" => users_with_active_cameras_query()
        })

      deactivated_at =
        user
        |> Map.get(:deactivated_at)
        |> DateTime.to_iso8601()

      assert json_response(conn, 200) == %{
               "data" => %{
                 "usersWithActiveCameras" => %{
                   "data" => [
                     %{
                       "cameras" => [
                         %{"brand" => "Hikvision", "isActive" => true, "name" => "some_name"}
                       ],
                       "deactivatedAt" => nil,
                       "isActive" => true,
                       "name" => "some name"
                     },
                     %{
                       "cameras" => [],
                       "isActive" => false,
                       "name" => "some name",
                       "deactivatedAt" => deactivated_at
                     }
                   ],
                   "pageNumber" => 1,
                   "pageSize" => 10,
                   "totalData" => 2,
                   "totalPages" => 1
                 }
               }
             }
    end

    defp users_with_active_cameras_query(cameraName \\ "") do
      """
      query {
        usersWithActiveCameras(cameraName: "#{cameraName}") {
          data {
            name
            isActive
            deactivatedAt
            cameras {
              name
              brand
              isActive
            }
          }
          pageNumber
          pageSize
          totalData
          totalPages
        }
      }
      """
    end
  end

  describe "mutation: notifyUsersWithCamerasFromBrand" do
    setup [:create_users_with_different_camera_brands]

    test "notifies users with cameras of a specific brand", %{conn: conn} do
      conn =
        post(conn, "/api", %{
          "query" => notify_users_mutation("HIKVISION")
        })

      assert json_response(conn, 200) == %{
        "data" => %{
          "notifyUsersWithCamerasFromBrand" => "Notification enqueued to 2 users with Hikvision cameras"
        }
      }
    end

    test "notifies only active users when only_active is true", %{conn: conn} do
      conn =
        post(conn, "/api", %{
          "query" => notify_users_mutation("INTELBRAS", true)
        })

      assert json_response(conn, 200) == %{
        "data" => %{
          "notifyUsersWithCamerasFromBrand" => "Notification enqueued to 1 user with Intelbras cameras"
        }
      }
    end

    test "returns appropriate message when no users have cameras of the specified brand", %{conn: conn} do
      conn =
        post(conn, "/api", %{
          "query" => notify_users_mutation("GIGA")
        })

      assert json_response(conn, 200) == %{
        "data" => %{
          "notifyUsersWithCamerasFromBrand" => "No users found with Giga cameras"
        }
      }
    end

    defp notify_users_mutation(brand, only_active \\ false) do
      """
      mutation {
        notifyUsersWithCamerasFromBrand(brand: #{brand}, onlyActive: #{only_active})
      }
      """
    end
  end

  defp create_user_with_cameras(_) do
    cameras = [
      %{brand: "Hikvision", is_active: true, name: "some_name"},
      %{brand: "Intelbras", is_active: false, name: "some name"}
    ]

    user = user_fixture(%{cameras: cameras})

    %{user: user}
  end

  defp create_inactive_user_with_cameras() do
    cameras = [
      %{brand: "Hikvision", is_active: false, name: "some_name"},
      %{brand: "Intelbras", is_active: false, name: "some_name"}
    ]

    user =
      user_fixture(%{
        cameras: cameras,
        is_active: false,
        deactivated_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })

    %{user: user}
  end

  defp create_users_with_different_camera_brands(_) do
    user1 = user_fixture(%{
      cameras: [%{brand: "Hikvision", is_active: true, name: "Cam1"}],
      is_active: true
    })

    user2 = user_fixture(%{
      cameras: [%{brand: "Hikvision", is_active: true, name: "Cam2"}],
      is_active: false
    })

    user3 = user_fixture(%{
      cameras: [%{brand: "Intelbras", is_active: true, name: "Cam3"}],
      is_active: true
    })

    %{users: [user1, user2, user3]}
  end
end
