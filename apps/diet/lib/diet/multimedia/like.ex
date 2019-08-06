defmodule Diet.Multimedia.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    belongs_to :user, Diet.Accounts.User
    belongs_to :video, Diet.Multimedia.Video

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [])
  end
end
