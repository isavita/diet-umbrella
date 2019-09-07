defmodule Diet.MultimediaTest do
  use Diet.DataCase, async: true

  alias Diet.Multimedia

  describe "categories" do
    test "list_ordered_categories/0" do
      for attrs <- [
            %{name: "Entertainment", position: 1},
            %{name: "Music", position: 2},
            %{name: "Education", position: 1}
          ] do
        Multimedia.create_category!(attrs)
      end

      ordered_names = Multimedia.list_ordered_categories() |> Enum.map(& &1.name)

      assert ordered_names == ~w(Music Education Entertainment)
    end
  end

  describe "videos" do
    alias Diet.Multimedia.Video

    @valid_attrs %{description: "description", title: "title", url: "http://youtube.com"}

    @invalid_attrs %{description: nil, title: nil, url: nil}

    test "list_videos/0 returns all videos" do
      owner = Factory.create_user()
      video1 = Factory.create_video(@valid_attrs, owner)
      another_owner = Factory.create_user()
      video2 = Factory.create_video(@valid_attrs, another_owner)

      video_ids = Multimedia.list_videos() |> Enum.map(& &1.id)
      assert Enum.member?(video_ids, video1.id)
      assert Enum.member?(video_ids, video2.id)
    end

    test "list_popular_videos/0 do not return low_quality videos" do
      video = Factory.create_video(%{published_at: DateTime.utc_now()})

      video_ids = Enum.map(Multimedia.list_popular_videos(), & &1.id)
      assert Enum.member?(video_ids, video.id)

      Multimedia.update_video(video, %{low_quality: true})

      assert Multimedia.list_popular_videos() == []
    end

    test "list_user_videos/0 returns all user's videos" do
      owner = Factory.create_user()
      video1 = Factory.create_video(@valid_attrs, owner)
      another_owner = Factory.create_user()
      video2 = Factory.create_video(@valid_attrs, another_owner)

      video_ids = Multimedia.list_user_videos(owner) |> Enum.map(& &1.id)
      assert Enum.member?(video_ids, video1.id)
      refute Enum.member?(video_ids, video2.id)
    end

    test "get_video!/1 returns the video with given id" do
      %Video{id: id} = Factory.create_video()
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "create_video/2 with valid data creates a video" do
      owner = Factory.create_user()
      assert {:ok, %Video{} = video} = Multimedia.create_video(owner, @valid_attrs)

      assert video.description == "description"
      assert video.title == "title"
      assert video.url == "http://youtube.com"
    end

    test "create_video/2 with invalid data returns error changeset" do
      owner = Factory.create_user()
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_video(owner, @invalid_attrs)
    end

    test "create_video/2 with not youtube's url returns error changeset" do
      owner = Factory.create_user()
      attrs = Map.put(@valid_attrs, :url, "http://example.com")
      assert {:error, %Ecto.Changeset{} = changeset} = Multimedia.create_video(owner, attrs)

      assert errors_on(changeset).url == [
               "Invalid format. Please make sure that the url is from youtube."
             ]
    end

    test "create_video/2 does not accept too long title" do
      owner = Factory.create_user()
      attrs = Map.put(@valid_attrs, :title, String.duplicate("abcdefghjk", 17))

      assert {:error, changeset} = Multimedia.create_video(owner, attrs)
      assert "should be at most 160 character(s)" in errors_on(changeset).title
    end

    test "update_video/2 with valid data updates the video" do
      video = Factory.create_video()
      assert {:ok, %Video{} = video} = Multimedia.update_video(video, %{title: "updated title"})
      assert video.title == "updated title"
    end

    test "update_video/2 with invalid data returns error changeset" do
      %Video{id: id} = video = Factory.create_video()
      assert {:error, %Ecto.Changeset{}} = Multimedia.update_video(video, @invalid_attrs)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "delete_video/1 deletes the video" do
      video = Factory.create_video()
      assert {:ok, %Video{}} = Multimedia.delete_video(video)
      assert Multimedia.list_videos() == []
    end

    test "change_video/1 returns a video changeset" do
      video = Factory.create_video()
      assert %Ecto.Changeset{} = Multimedia.change_video(video)
    end
  end

  describe "report" do
    alias Diet.Multimedia.Report

    @valid_attrs %{spam_or_abuse: true}

    test "report_video/3 with valid data creates a report" do
      user = Factory.create_user()
      video = Factory.create_video()

      user_id = user.id
      video_id = video.id

      assert {:ok,
              %Report{
                user_id: user_id,
                reportable_id: ^video_id,
                reportable_type: "Video",
                spam_or_abuse: true
              }} = Multimedia.report_video(user_id, video_id, @valid_attrs)
    end
  end

  describe "youtube_channel" do
    alias Diet.Multimedia.YoutubeChannel

    @valid_attrs %{uid: "UARLOLGZl2-QTbJfLmAKgeAw", name: "Jane Doe", active: true}
    @invalid_attrs %{}

    test "create_youtube_channel/1 with valid data creates a video" do
      assert {:ok, %YoutubeChannel{} = channel} = Multimedia.create_youtube_channel(@valid_attrs)

      assert channel.uid == @valid_attrs[:uid]
      assert channel.name == @valid_attrs[:name]
      assert channel.active
    end

    test "create_youtube_channel/1  with no uid returns error changeset" do
      assert {:error, changeset} = Multimedia.create_youtube_channel(@invalid_attrs)
      assert "can't be blank" in errors_on(changeset).uid
    end
  end

  describe "articles" do
    alias Diet.Multimedia.Article

    @valid_attrs %{
      description: "some description",
      low_quality: true,
      published_at: "2010-04-17T14:00:00Z",
      type: "application/pdf",
      title: "some title",
      url: "some url"
    }
    @update_attrs %{
      description: "some updated description",
      low_quality: false,
      published_at: "2011-05-18T15:01:01Z",
      type: "text/csv",
      title: "some updated title",
      url: "some updated url"
    }
    @invalid_attrs %{
      description: nil,
      low_quality: nil,
      published_at: nil,
      type: nil,
      title: nil,
      url: nil
    }

    def article_fixture(attrs \\ %{}) do
      user = Factory.create_user()

      {:ok, article} = Multimedia.create_article(user, Enum.into(attrs, @valid_attrs))

      article
    end

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Multimedia.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Multimedia.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      assert {:ok, %Article{} = article} = Multimedia.create_article(@valid_attrs)
      assert article.description == "some description"
      assert article.low_quality == true
      assert article.published_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert article.type == "application/pdf"
      assert article.title == "some title"
      assert article.url == "some url"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      assert {:ok, %Article{} = article} = Multimedia.update_article(article, @update_attrs)
      assert article.description == "some updated description"
      assert article.low_quality == false
      assert article.published_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert article.type == "text/csv"
      assert article.title == "some updated title"
      assert article.url == "some updated url"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Multimedia.update_article(article, @invalid_attrs)
      assert article == Multimedia.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Multimedia.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Multimedia.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Multimedia.change_article(article)
    end
  end
end
