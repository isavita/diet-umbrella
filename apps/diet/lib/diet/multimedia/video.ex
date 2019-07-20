defmodule Diet.Multimedia.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Diet.Multimedia.Permalink, autogenerate: true}
  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :slug, :string
    field :published_at, :utc_datetime

    belongs_to :user, Diet.Accounts.User
    belongs_to :category, Diet.Multimedia.Category
    has_many :annotations, Diet.Multimedia.Annotation

    timestamps()
  end

  @url_error_message "Invalid format. Please make sure that the url is from youtube."
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:url, :title, :description, :category_id, :published_at])
    |> validate_required([:url, :title])
    |> validate_format(:url, ~r/youtu/i, message: @url_error_message)
    |> validate_length(:title, min: 3)
    |> assoc_constraint(:category)
    |> slugify_title()
  end

  defp slugify_title(changeset) do
    case fetch_change(changeset, :title) do
      {:ok, new_title} ->
        put_change(changeset, :slug, slugify(new_title))

      :error ->
        changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end
