defmodule Diet.Multimedia.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field :reportable_id, :integer
    field :reportable_type, :string
    field :spam_or_abuse, :boolean
    field :not_interested, :boolean

    belongs_to :user, Diet.Accounts.User
    belongs_to :video, Diet.Multimedia.Video

    timestamps()
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:reportable_id, :reportable_type, :spam_or_abuse, :not_interested])
    |> unique_constraint(:user,
      name: :reports_user_id_video_id_index,
      message: "Report already submitted"
    )
  end
end
