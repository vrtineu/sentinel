defmodule SentinelWeb.Schema.AccountTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc "A system user"
  object :user do
    field :id, :id
    field :name, :string
    field :is_active, :boolean
    field :deactivated_at, :datetime
    field :cameras, list_of(:camera)
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end
end
