defmodule SentinelWeb.Schema.DeviceTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc "The users' security camera"
  object :camera do
    field :id, :id
    field :brand, :string
    field :is_active, :boolean
    field :user, :user
  end
end
