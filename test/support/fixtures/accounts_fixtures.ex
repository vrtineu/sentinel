defmodule Sentinel.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        is_active: true,
        name: "some name",
        email: "dummy@mail.com"
      })
      |> Sentinel.Accounts.create_user()

    user
  end
end
