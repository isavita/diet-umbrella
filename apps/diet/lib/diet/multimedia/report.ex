defmodule Diet.Multimedia.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field :spam_or_abuse, :boolean
    field :not_interested, :boolean

    belongs_to :user, Diet.Accounts.User
    belongs_to :video, Diet.Multimedia.Video

    timestamps()
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:spam_or_abuse, :not_interested])
    |> unique_constraint(:user,
      name: :user_video_unique_index,
      message: "Report already submitted"
    )
  end
end
