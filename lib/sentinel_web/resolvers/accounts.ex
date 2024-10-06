defmodule SentinelWeb.Resolvers.Accounts do
  @moduledoc """
  The module where keeps the graphql resolvers for the Accounts context.
  """

  alias Sentinel.Accounts

  def list_all_users_with_active_cameras(_parent, args, _resolution) do
    {:ok, Accounts.list_users_with_active_cameras(args)}
  end
end
