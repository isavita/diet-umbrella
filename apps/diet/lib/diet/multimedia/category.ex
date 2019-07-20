defmodule Diet.Multimedia.Category do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "categories" do
    field :name, :string
    field :position, :integer, default: 1

    timestamps()
  end

  @doc false
  def alphabetical(query) do
    from(q in query, order_by: [asc: :name])
  end

  @doc false
  def position(query) do
    from(q in query, order_by: [desc: :position])
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :position])
    |> validate_required([:name])
  end
end
