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
      assert {:ok, %Report{user_id: user_id, video_id: video_id, spam_or_abuse: true}} = Multimedia.report_video(user_id, video_id, @valid_attrs)
    end
  end
end
