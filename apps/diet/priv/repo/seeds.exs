# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Diet.Repo.insert!(%Diet.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
alias Diet.Accounts.User
alias Diet.Multimedia
alias Diet.Multimedia.{Article, Like, Tag, Video, YoutubeChannel}
alias Diet.Repo

import Ecto.Query

user_changesets = [
  User.registration_changeset(%User{}, %{
    admin: true,
    name: "Weight Hater",
    username: "weighthater",
    password: "password"
  }),
  User.registration_changeset(%User{}, %{
    admin: true,
    name: "Jose Valim",
    username: "jose",
    password: "password"
  }),
  User.registration_changeset(%User{}, %{
    admin: true,
    name: "Wolfram Alpha",
    username: "wolfram",
    password: "password"
  }),
  User.registration_changeset(%User{}, %{
    name: "Chris MacDonald",
    username: "chris",
    password: "password"
  }),
  User.registration_changeset(%User{}, %{
    name: "Bruce Tate",
    username: "bruce",
    password: "password"
  })
]

Enum.each(user_changesets, &Repo.insert(&1, on_conflict: :nothing))
jose = Repo.get_by(User, username: "jose")
chris = Repo.get_by(User, username: "chris")

videos = [
  %Video{
    url: "https://www.youtube.com/watch?v=0Bn2NQP2i7A",
    title: "IOHK Summit 2019 day 2",
    description: "IOHK Summit 2019 day 2 technical talks",
    published_at: DateTime.truncate(DateTime.utc_now(), :second),
    user: jose
  },
  %Video{
    url: "https://www.youtube.com/watch?v=VsnQf7exv5I",
    title: "Turing Award Lecture",
    description:
      ~s/We are pleased to announce that Geoffrey Hinton and Yann LeCun will deliver the Turing Lecture at FCRC.  Hinton's talk, entitled, "The Deep Learning Revolution" and LeCun's talk, entitled, "The Deep Learning Revolution: The Sequel," will be presented June 23rd from 5:15-6:30pm in Symphony Hall./,
    published_at: DateTime.truncate(DateTime.utc_now(), :second),
    user: jose
  },
  %Video{
    url: "https://www.youtube.com/watch?v=HEpNiOM6lto&t=1s",
    title: "Becoming a Kardashev Type I Civilization",
    description:
      ~s/The Kardashev Scale has become a standardized way of classifying (hypothetical) advanced civilizations. The lowest rank, Type 1, is still way ahead of us - but by how much? When will we achieve Type 1 status and exactly how could we plausibly do so? In this video, we go through some estimates of when humanity might become Type 1, and in particular what kind of energy sources we could harness to achieve this feat./,
    published_at: DateTime.truncate(DateTime.utc_now(), :second),
    user: chris
  },
  %Video{
    url: "https://www.youtube.com/watch?v=bGcvv3683Os",
    title: "Industrializing the Moon",
    description:
      ~s/We return to the Moon to explore ways to go beyond simple Lunar Bases to a full-fledged productive colony that can help us travel to other worlds and expand our own./,
    user: chris
  }
]

Enum.each(videos, &Repo.insert!(&1, on_conflict: :nothing))
videos = Repo.all(from(v in Video, where: v.user_id == ^jose.id))

Enum.each(
  videos,
  &Repo.insert!(%Like{user_id: jose.id, likeable_id: &1.id, likeable_type: "Video"},
    on_conflict: :nothing
  )
)

# Add articles
articles = [
  %Article{
    url: "https://www.technologyreview.com/lists/innovators-under-35/2016/pioneer/oriol-vinyals/",
    title: "Oriol Vinyals, 33",
    published_at: DateTime.truncate(DateTime.utc_now(), :second),
    user: jose
  },
  %Article{
    url: "https://arxiv.org/pdf/math/0303109.pdf",
    title: "Ricci flow with surgery on three-manifolds",
    description:
      ~s{This is a technical paper, which is a continuation of math.DG/0211159. Here we construct Ricci flow with surgeries and verify most of the assertions, made in section 13 of that e-print; the exceptions are (1) the statement that manifolds that can collapse with local lower bound on sectional curvature are graph manifolds - this is deferred to a separate paper, since the proof has nothing to do with the Ricci flow, and (2) the claim on the lower bound for the volume of maximal horns and the smoothness of solutions from some time on, which turned out to be unjustified and, on the other hand, irrelevant for the other conclusions.},
    type: "application/pdf",
    published_at: DateTime.truncate(DateTime.utc_now(), :second),
    user: chris
  }
]

Enum.each(articles, &Repo.insert!(&1, on_conflict: :nothing))

# Add youtube channels
youtube_channels = %{
  "biolayne" => "UCqMBA83S0TnfTlTeE5j1mgQ",
  # ProPhysic
  "Paul Revelia" => "UCykSWsfEKRES6RDotQF6ChQ",
  # ProPhysic
  "Stephen Beaugrand" => "UCWzV6dk0zczHf9kX_DNTy-A",
  "Jeff Nippard" => "UC68TLK0mAEzUyHx5x5k-S1Q",
  "Alan Thrall" => "UCRLOLGZl3-QTaJfLmAKgoAw",
  # ProPhysic
  "Tyler Wiebe" => "UC8y6ZGNyaA6NVxx1yY7gegA",
  "Laurin Conlin" => "UCshUyld89tZSUGDZk0fooKw",
  "KaitAnnMichelle" => "UC-Hbk9jN55Ulx_GY8JPE7IQ"
}

Enum.each(youtube_channels, fn {name, uid} ->
  Repo.insert!(%YoutubeChannel{uid: uid, name: name, active: name == "biolayne"},
    on_conflict: :nothing
  )
end)

# Create basic tags
for tag <- ["Diet", "Reverse Diet", "Mini Cut", "Bulking Diet", "Fitness", "Other"] do
  Tag.changeset(%Tag{}, %{name: tag}) |> Repo.insert!(on_conflict: :nothing)
end

fitness_tag = Repo.get_by!(Tag, name: "Fitness")
other_tag = Repo.get_by!(Tag, name: "Other")

videos = Repo.all(Video) |> Repo.preload(:tags)
articles = Repo.all(Article) |> Repo.preload(:tags)

tag_post = fn post, tags ->
  post
  |> Ecto.Changeset.change(%{})
  |> Ecto.Changeset.put_assoc(:tags, tags, required: true)
  |> Repo.update()
end

Enum.each(videos ++ articles, fn elem ->
  cond do
    rem(elem.id, 2) == 0 ->
      tag_post.(elem, [fitness_tag])
    true ->
      tag_post.(elem, [other_tag])
  end
end)
