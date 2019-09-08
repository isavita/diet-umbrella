defmodule Diet.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false

  alias Diet.Accounts.User
  alias Diet.Repo
  alias Diet.Multimedia.{Annotation, Article, Category, Like, Report, Tag, Video, YoutubeChannel}

  @popular_videos_count 20
  @popular_articles_count 10
  @list_query_limit 500

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Diet.PubSub, @topic)
  end

  def list_articles, do: Repo.all(Article)

  def list_user_articles(%User{} = user) do
    Article
    |> user_query(user)
    |> Repo.all()
  end

  def tag_by_name(name), do: Repo.get_by(Tag, name: name)

  def get_user_article!(%User{} = user, id) do
    Article
    |> user_query(user)
    |> Repo.get!(id)
  end

  def list_newest_articles(limit \\ 10) do
    Article
    |> reject_low_quality_query()
    |> published_query(limit: limit)
    |> order_by([a], desc: a.published_at)
    |> preload(:user)
    |> Repo.all()
  end

  def get_article!(id), do: Repo.get!(Article, id)

  def create_article(%User{} = user, attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:tags, list_tags(attrs), required: true)
    |> Repo.insert()
  end

  def update_article(%Article{} = article, attrs) do
    article
    |> Repo.preload(:tags)
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, list_tags(attrs), required: true)
    |> Repo.update()
  end

  def list_tags(%{tags: tag_ids}), do: do_list_tags(tag_ids)

  def list_tags(%{"tags" => tag_ids}), do: do_list_tags(tag_ids)

  def do_list_tags(tag_ids) do
    Repo.all(from(t in Tag, where: t.id in ^tag_ids))
  end

  def delete_article(%Article{} = article), do: Repo.delete(article)

  def supported_article_types do
    Article.supported_types()
  end

  def change_article(%Article{} = article) do
    Article.changeset(article, %{})
  end

  def list_videos, do: Repo.all(Video)

  def list_published_videos(opts \\ []) do
    Video
    |> published_query(opts)
    |> Repo.all()
  end

  def list_newest_videos(n \\ 5) do
    Video
    |> reject_low_quality_query()
    |> published_query(limit: n)
    |> order_by([v], desc: v.published_at)
    |> Repo.all()
  end

  def list_popular_videos do
    Video
    |> reject_low_quality_query()
    |> popular_query()
    |> published_query(limit: @popular_videos_count)
    |> preload(:user)
    |> Repo.all()
  end

  def list_videos_paginated(opts) do
    opts = Keyword.put_new(opts, :cursor_fields, [:published_at])

    Video
    |> reject_low_quality_query()
    |> published_query()
    |> order_by(desc: :published_at)
    |> preload(:user)
    |> Repo.paginate(opts)
  end

  defp reject_low_quality_query(queryable) do
    from(v in queryable, where: v.low_quality != true)
  end

  defp popular_query(queryable) do
    from(q in queryable,
      left_join: l in assoc(q, :likes),
      group_by: q.id,
      order_by: [desc: count(l.id)]
    )
  end

  defp published_query(queryable, opts \\ []) do
    limit = opts[:limit] || @list_query_limit

    from(q in queryable,
      where: not is_nil(q.published_at),
      limit: ^limit
    )
  end

  def list_user_videos(%User{} = user) do
    Video
    |> user_query(user)
    |> Repo.all()
  end

  def like_counts(likeable_ids, likeable_type) do
    Repo.all(
      from(l in Like,
        where: l.likeable_id in ^likeable_ids and l.likeable_type == ^likeable_type,
        group_by: l.likeable_id,
        select: {l.likeable_id, count(l.id)}
      )
    )
  end

  def user_likes?(user_id, likeable_id, likeable_type) do
    Repo.one(
      from(l in Like,
        where:
          l.likeable_id == ^likeable_id and l.likeable_type == ^likeable_type and
            l.user_id == ^user_id,
        select: l.id,
        limit: 1
      )
    ) != nil
  end

  def report(user_id, reportable_id, reportable_type, reasons) do
    %Report{user_id: user_id, reportable_id: reportable_id, reportable_type: reportable_type}
    |> Report.changeset(reasons)
    |> Repo.insert()
  end

  def mark_as_reported(reports_count) do
    mark_as_reported_videos(reports_count)
    mark_as_reported_articles(reports_count)
  end

  defp mark_as_reported_videos(reports_count) do
    video_ids = reported_query(reports_count, "Video") |> Repo.all()

    from(v in Video, where: v.id in ^video_ids)
    |> Repo.update_all(set: [low_quality: true])
  end

  defp mark_as_reported_articles(reports_count) do
    article_ids = reported_query(reports_count, "Article") |> Repo.all()

    from(a in Article, where: a.id in ^article_ids)
    |> Repo.update_all(set: [low_quality: true])
  end

  defp reported_query(reports_count, type) do
    from(v in "#{String.downcase(type)}s",
      join: r in Report,
      on: r.reportable_id == v.id and r.reportable_type == ^type,
      group_by: r.reportable_id,
      having: count(r.id) >= ^reports_count,
      select: r.reportable_id
    )
  end

  def get_video!(id), do: Repo.get!(Video, id)

  def get_user_video!(%User{} = user, id) do
    Video
    |> user_query(user)
    |> Repo.get!(id)
  end

  def create_video(%User{} = user, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:tags, list_tags(attrs), required: true)
    |> Repo.insert()
    |> notify_subscribers({:video, :created})
  end

  def update_video(%Video{} = video, attrs) do
    video
    |> Repo.preload(:tags)
    |> Video.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, list_tags(attrs), required: true)
    |> Repo.update()
    |> notify_subscribers({:video, :updated})
  end

  def delete_video(%Video{} = video), do: Repo.delete(video)

  def change_video(%Video{} = video) do
    Video.changeset(video, %{})
  end

  defp user_query(query, %User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  def list_ordered_tags do
    Tag
    |> Tag.alphabetical()
    |> Repo.all()
  end

  def annotate_video(%User{id: user_id}, video_id, attrs) do
    %Annotation{user_id: user_id, video_id: video_id}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  def like(user_id, likeable_id, likeable_type) do
    %Like{user_id: user_id, likeable_id: likeable_id, likeable_type: likeable_type}
    |> Like.changeset(%{})
    |> Repo.insert()
  end

  def unlike(user_id, likeable_id, likeable_type) do
    get_like!(user_id, likeable_id, likeable_type)
    |> Repo.delete()
  end

  def get_like!(user_id, likeable_id, likeable_type) do
    Repo.get_by!(Like, user_id: user_id, likeable_id: likeable_id, likeable_type: likeable_type)
  end

  def list_youtube_channel, do: Repo.all(YoutubeChannel)

  def list_active_youtube_channel do
    Repo.all(from(yc in YoutubeChannel, where: yc.active == true))
  end

  def get_youtube_channel(id) do
    Repo.get(YoutubeChannel, id)
  end

  def create_youtube_channel(attrs) do
    %YoutubeChannel{}
    |> YoutubeChannel.changeset(attrs)
    |> Repo.insert()
  end

  def update_youtube_channel(%YoutubeChannel{} = channel, attrs) do
    channel
    |> YoutubeChannel.changeset(attrs)
    |> Repo.update()
  end

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
