defmodule Diet.Multimedia.Embeds.YoutubeVideo do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :data, :map
    field :published, :boolean
  end

  def changeset(youtube_video, attrs) do
    youtube_video
    |> cast(attrs, [:data, :published])
    |> validate_required(:data)
  end
end
