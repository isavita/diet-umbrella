defmodule Diet.Accounts do
  @moduledoc """
  Provide functionality for dealing with user accounts.
  """

  import Ecto.Query

  alias Diet.Accounts.User
  alias Diet.Repo

  def list_users, do: Repo.all(User)

  def list_users_by_ids(ids) do
    Repo.all(from(u in User, where: u.id in ^ids))
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def get_user_by(params), do: Repo.get_by(User, params)

  def user_by_username(username), do: Repo.get_by(User, username: username)

  def change_user(%User{} = user), do: User.changeset(user, %{})

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_registration(%User{} = user, params) do
    User.registration_changeset(user, params)
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_by_username_and_pass(username, given_password) do
    user = get_user_by(username: username)

    cond do
      user && Pbkdf2.verify_pass(given_password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        {:error, :not_found}
    end
  end

  def make_admin!(%User{} = user, admin \\ true) do
    user
    |> User.admin_changeset(%{admin: admin})
    |> Repo.update!()
  end
end
