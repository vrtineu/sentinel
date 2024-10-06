defmodule SentinelWeb.Resolvers.Accounts do
  @moduledoc """
  The module where keeps the graphql resolvers for the Accounts context.
  """

  alias Sentinel.Accounts
  alias Sentinel.Accounts.{User, UserNotification}
  alias Sentinel.Notifications.Email

  def list_all_users_with_active_cameras(_parent, args, _resolution) do
    {:ok, Accounts.list_users_with_active_cameras(args)}
  end

  def notify_users_with_cameras_from_brand(
        _parent,
        %{brand: brand, only_active: only_active},
        _resolution
      ) do
    users = Accounts.list_users_by_camera_brand(brand, only_active: only_active)

    case Enum.empty?(users) do
      true ->
        {:ok, "No users found with #{brand} cameras"}

      false ->
        users
        |> Enum.map(fn %User{name: name, email: email} ->
          UserNotification.email_by_camera_brand(%{name: name, email: email, brand: brand})
        end)
        |> Email.send_bulk_emails()

        {:ok, format_notification_message(length(users), brand)}
    end
  end

  defp format_notification_message(1, brand), do: "Notification enqueued to 1 user with #{brand} cameras"
  defp format_notification_message(n, brand), do: "Notification enqueued to #{n} users with #{brand} cameras"
end
