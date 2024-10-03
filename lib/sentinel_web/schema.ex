defmodule SentinelWeb.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(SentinelWeb.Schema.AccountTypes)
  import_types(SentinelWeb.Schema.DeviceTypes)

  alias SentinelWeb.Resolvers

  query do
    @desc "List users with active cameras"
    field :users_with_active_cameras, list_of(:user) do
      resolve(&Resolvers.Accounts.list_all_users_with_active_cameras/3)
    end
  end
end
