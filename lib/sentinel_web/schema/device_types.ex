defmodule SentinelWeb.Schema.DeviceTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc "The users' security camera"
  object :camera do
    field :id, :id
    field :name, :string
    field :brand, :string
    field :is_active, :boolean
    field :user, :user
  end

  enum :camera_brand do
    value(:hikvision, as: "Hikvision")
    value(:intelbras, as: "Intelbras")
    value(:giga, as: "Giga")
    value(:vivotek, as: "Vivotek")
  end
end
