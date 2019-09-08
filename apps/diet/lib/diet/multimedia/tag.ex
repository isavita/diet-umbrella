defmodule Diet.Multimedia.Tag do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  schema "tags" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc false
  def alphabetical(query) do
    from(q in query, order_by: [asc: :name])
  end
end
