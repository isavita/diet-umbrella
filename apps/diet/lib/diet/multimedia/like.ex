defmodule Diet.Multimedia.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    field :likeable_id, :integer
    field :likeable_type, :string

    belongs_to :user, Diet.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:likeable_id, :likeable_type])
  end
end
