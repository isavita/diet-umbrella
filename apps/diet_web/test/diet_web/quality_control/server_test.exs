defmodule DietWeb.QualityControl.ServerTest do
  use DietWeb.ConnCase

  alias DietWeb.QualityControl.Server
  alias Diet.Multimedia

  test "marks videos as low_quality if reported enough tiems" do
    user1 = Factory.create_user()
    user2 = Factory.create_user()
    video = Factory.create_video()

    Multimedia.report_video(user1.id, video.id, %{not_interested: true})
    Multimedia.report_video(user2.id, video.id, %{not_interested: true})

    refute video.low_quality == true

    {:ok, _pid} = Server.start_link(name: :makrs_videos_test, frequency: 10)
    Process.sleep(20)

    video = Multimedia.get_video!(video.id)
    assert video.low_quality == true
  end
end
