defmodule Diet.Multimedia.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :description, :string
    field :low_quality, :boolean, default: false
    field :published_at, :utc_datetime
    field :type, :string
    field :title, :string
    field :url, :string

    belongs_to :user, Diet.Accounts.User
    belongs_to :category, Diet.Multimedia.Category

    has_many :likes, Diet.Multimedia.Like,
      foreign_key: :likeable_id,
      where: [likable_type: "Article"]

    has_many :reports, Diet.Multimedia.Report,
      foreign_key: :reportable_id,
      where: [reportable_type: "Article"]

    many_to_many :tags, Diet.Multimedia.Tag, join_through: "articles_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:category_id, :description, :title, :url, :type, :low_quality, :published_at])
    |> validate_required([:title, :url, :type])
    |> validate_inclusion(:type, supported_types())
    |> assoc_constraint(:category)
  end

  @doc false
  def supported_types do
    ~w(text/html application/pdf)
  end
end
