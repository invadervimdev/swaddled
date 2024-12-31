defmodule Swaddled.Genres.Genre do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "genres" do
    field :name, :string

    many_to_many :artists, Swaddled.Artists.Artist, join_through: "artists_genres"
  end

  @doc false
  def changeset(genre, attrs) do
    genre
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
