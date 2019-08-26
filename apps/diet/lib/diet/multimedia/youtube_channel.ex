defmodule Diet.Multimedia.YoutubeChannel do
  use Ecto.Schema

  import Ecto.Changeset

  alias Diet.Multimedia.Embeds.YoutubeVideo

  schema "youtube_channels" do
    field :uid, :string
    field :name, :string
    field :active, :boolean
    embeds_many :videos, YoutubeVideo, on_replace: :delete

    timestamps()
  end

  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:uid, :name, :active])
    |> validate_required([:uid])
    |> cast_embed(:videos)
  end
end
