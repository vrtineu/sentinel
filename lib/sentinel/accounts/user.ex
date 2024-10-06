defmodule Sentinel.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sentinel.Devices.Camera

  schema "users" do
    field :name, :string
    field :email, :string
    field :is_active, :boolean, default: false
    field :deactivated_at, :utc_datetime, default: nil
    has_many :cameras, Camera

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :is_active, :deactivated_at])
    |> validate_required([:name, :email, :is_active])
    |> cast_assoc(:cameras, with: &Camera.changeset_for_user/2)
  end
end
