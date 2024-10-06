defmodule SentinelWeb.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(SentinelWeb.Schema.AccountTypes)
  import_types(SentinelWeb.Schema.CustomTypes)
  import_types(SentinelWeb.Schema.DeviceTypes)

  alias SentinelWeb.Resolvers

  query do
    @desc "List users with active cameras"
    field :users_with_active_cameras, :paginated_user do
      arg(:camera_name, :string)
      arg(:page, :integer, default_value: 1)
      arg(:limit, :integer, default_value: 10)
      arg(:sort_by, :pagination_sort, default_value: :asc)
      resolve(&Resolvers.Accounts.list_all_users_with_active_cameras/3)
    end
  end

  mutation do
    @desc "Send a notification to users that have cameras from a specific brand"
    field :notify_users_with_cameras_from_brand, :string do
      arg(:brand, :camera_brand)
      arg(:only_active, :boolean, default_value: false)
      resolve(&Resolvers.Accounts.notify_users_with_cameras_from_brand/3)
    end
  end
end
