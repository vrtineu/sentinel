defmodule Sentinel.Repo.Migrations.AddEmailFieldToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :string, null: false
    end
  end
end
