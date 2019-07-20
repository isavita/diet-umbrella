defmodule Diet.AccountsTest do
  use Diet.DataCase, async: true

  alias Diet.Accounts
  alias Diet.Accounts.User

  describe "register_user/1" do
    @valid_attrs %{
      name: "Jane Doe",
      username: "janedoe",
      password: "nosecret"
    }

    @invalid_attrs %{}

    test "with valid data inserts user" do
      assert {:ok, %User{id: id} = user} = Accounts.register_user(@valid_attrs)
      assert user.name == @valid_attrs.name
      assert user.username == @valid_attrs.username
      assert Accounts.get_user!(id)
    end

    test "with invalid data does not inserts user" do
      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(@invalid_attrs)
      assert Accounts.list_users() == []
    end

    test "enforces unique username" do
      assert {:ok, %User{id: id}} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.register_user(@valid_attrs)
      assert %{username: ["has already been taken"]} = errors_on(changeset)
      assert Accounts.get_user!(id)
    end

    test "does not accept short username" do
      attrs = Map.put(@valid_attrs, :username, "ab")

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "should be at least 3 character(s)" in errors_on(changeset).username
      assert Accounts.list_users() == []
    end

    test "does not accept long username" do
      attrs = Map.put(@valid_attrs, :username, "really long, long, long username")

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "should be at most 25 character(s)" in errors_on(changeset).username
      assert Accounts.list_users() == []
    end

    test "requires password to be at least 6 chars long" do
      attrs = Map.put(@valid_attrs, :password, "short")

      assert {:error, changeset} = Accounts.register_user(attrs)
      assert "should be at least 6 character(s)" in errors_on(changeset).password
      assert Accounts.list_users() == []
    end
  end

  describe "authenticate_by_username_and_pass/2" do
    @password "123456"

    setup do
      {:ok, user: Factory.create_user(%{password: @password})}
    end

    test "returns user with correct password", %{user: user} do
      assert {:ok, %User{} = auth_user} =
               Accounts.authenticate_by_username_and_pass(user.username, @password)

      assert auth_user.id == user.id
    end

    test "returns unauthorized error with invalid password", %{user: user} do
      assert {:error, :unauthorized} =
               Accounts.authenticate_by_username_and_pass(user.username, "wrong")
    end

    test "returns not found error with no matching username", %{user: _user} do
      assert {:error, :not_found} =
               Accounts.authenticate_by_username_and_pass("unknown", @password)
    end
  end

  describe "make_admin!/2" do
    setup do
      {:ok, user: Factory.create_user()}
    end

    test "makes user admin", %{user: user} do
      assert %User{id: id, admin: true} = Accounts.make_admin!(user)
      assert %User{admin: true} = Accounts.get_user!(id)
    end

    test "sets admin to false when second argument false", %{user: user} do
      assert %User{id: id, admin: false} = Accounts.make_admin!(user, false)
      assert %User{admin: false} = Accounts.get_user!(id)
    end
  end
end
