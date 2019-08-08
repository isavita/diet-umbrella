defmodule Diet.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false

  alias Diet.Accounts.User
  alias Diet.Repo
  alias Diet.Multimedia.{Annotation, Category, Like, Video}

  @popular_videos_count 20
  @list_query_limit 500

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Diet.PubSub, @topic)
  end

  def list_videos, do: Repo.all(Video)

  def list_published_videos(opts \\ []) do
    Video
    |> published_query(opts)
    |> Repo.all()
  end

  def list_popular_videos do
    Video
    |> published_query(limit: @popular_videos_count)
    |> Repo.all()
  end

  defp published_query(queryable, opts \\ []) do
    limit = opts[:limit] || @list_query_limit

    from(q in queryable,
      where: not is_nil(q.published_at),
      order_by: [desc: :id],
      limit: ^limit
    )
  end

  def list_user_videos(%User{} = user) do
    Video
    |> user_videos_query(user)
    |> Repo.all()
  end

  def videos_like_counts(video_ids) do
    Repo.all(
      from(l in Like,
        where: l.video_id in ^video_ids,
        group_by: l.video_id,
        select: {l.video_id, count(l.id)}
      )
    )
  end

  def user_likes_video?(user_id, video_id) do
    Repo.one(
      from(l in Like,
        where: l.video_id == ^video_id and l.user_id == ^user_id,
        select: l.id,
        limit: 1
      )
    ) != nil
  end

  def video_likes_count(video_id) do
    Repo.one(from(l in Like, where: l.video_id == ^video_id, select: count(l.id)))
  end

  def get_video!(id), do: Repo.get!(Video, id)

  def get_user_video!(%User{} = user, id) do
    Video
    |> user_videos_query(user)
    |> Repo.get!(id)
  end

  def create_video(%User{} = user, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
    |> notify_subscribers({:video, :created})
  end

  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers({:video, :updated})
  end

  def delete_video(%Video{} = video), do: Repo.delete(video)

  def change_video(%Video{} = video) do
    Video.changeset(video, %{})
  end

  defp user_videos_query(query, %User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  def list_categories, do: Repo.all(Category)

  def list_ordered_categories do
    Category
    |> Category.position()
    |> Category.alphabetical()
    |> Repo.all()
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category!(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert!(on_conflict: {:replace, [:name, :position]}, conflict_target: :name)
  end

  def annotate_video(%User{id: user_id}, video_id, attrs) do
    %Annotation{user_id: user_id, video_id: video_id}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  def like_video(user_id, video_id) do
    %Like{user_id: user_id, video_id: video_id}
    |> Like.changeset(%{})
    |> Repo.insert()
  end

  def unlike_video(user_id, video_id) do
    get_like!(user_id, video_id) |> Repo.delete()
  end

  def get_like!(user_id, video_id), do: Repo.get_by!(Like, user_id: user_id, video_id: video_id)

  def list_annotations(%Video{} = video, since_id \\ 0) do
    Repo.all(
      from(
        a in Ecto.assoc(video, :annotations),
        where: a.id > ^since_id,
        order_by: [asc: a.at, asc: a.id],
        preload: :user,
        limit: 500
      )
    )
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Diet.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  defp notify_subscribers(error, _event), do: error
end
