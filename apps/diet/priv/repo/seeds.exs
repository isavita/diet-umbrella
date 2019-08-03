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
alias Diet.Multimedia.Category
alias Diet.Multimedia.Video
alias Diet.Repo

user_changesets = [
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

for {name, position} <- [
      {"Computer Science", 1},
      {"Science", 1},
      {"Fitness", 1},
      {"ASMR", 1},
      {"Physics", 1},
      {"Other", 0}
    ] do
  Multimedia.create_category!(%{name: name, position: position})
end

computer_science = Repo.get_by(Category, name: "Computer Science")
jose = Repo.get_by(User, username: "jose")

videos = [
  %Video{
    url: "https://www.youtube.com/watch?v=0Bn2NQP2i7A",
    title: "IOHK Summit 2019 day 2",
    description: "IOHK Summit 2019 day 2 technical talks",
    category_id: computer_science.id,
    user: jose
  }
]

Enum.each(videos, &Repo.insert(&1, on_conflict: :nothing))
