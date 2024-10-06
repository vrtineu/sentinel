defmodule Sentinel.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Sentinel.Repo

  alias Sentinel.Accounts.User
  alias Sentinel.Devices.Camera

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns the paginated list of users with active cameras.

  ## Examples

      iex> list_users_with_active_cameras()
      %{
        data: [%User{}, ...],
        page_number: 1,
        page_size: 10,
        total_pages: 1,
        total_data: 1
      }

      iex> list_users_with_active_cameras(%{page: 2, limit: 5, camera_name: "XPTO", sort_by: :desc})
      %{
        data: [%User{}, ...],
        page_number: 2,
        page_size: 5,
        total_pages: 1,
        total_data: 1
      }
  """
  def list_users_with_active_cameras(args \\ %{}) do
    page = Map.get(args, :page, 1)
    limit = Map.get(args, :limit, 10)
    camera_name_filter = Map.get(args, :camera_name, "")
    sort_direction = Map.get(args, :sort_by, :asc)

    query =
      from u in User,
        left_join: c in assoc(u, :cameras),
        on: c.is_active == true,
        distinct: u.id

    active_cameras_query =
      from c in Camera, where: c.is_active == true and ilike(c.name, ^"#{camera_name_filter}%")

    total_data = Repo.aggregate(query, :count, :id)
    total_pages = ceil(total_data / limit)

    users =
      query
      |> limit(^limit)
      |> offset(^((page - 1) * limit))
      |> Repo.all()
      |> Repo.preload(cameras: active_cameras_query)
      |> Enum.map(fn user ->
        %{user | cameras: Enum.sort_by(user.cameras, & &1.name, sort_direction)}
      end)

    %{
      data: users,
      page_number: page,
      page_size: limit,
      total_pages: total_pages,
      total_data: total_data
    }
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
