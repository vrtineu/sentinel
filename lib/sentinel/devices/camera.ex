defmodule Sentinel.Devices.Camera do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sentinel.Accounts.User

  schema "cameras" do
    field :brand, :string
    field :is_active, :boolean, default: false
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(camera, attrs) do
    camera
    |> cast(attrs, [:brand, :is_active, :user_id])
    |> validate_required([:brand, :is_active, :user_id])
    |> foreign_key_constraint(:user_id)
  end

  @doc false
  def changeset_for_user(camera, attrs) do
    camera
    |> cast(attrs, [:brand, :is_active])
    |> validate_required([:brand, :is_active])
  end
end
