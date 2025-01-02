defmodule Swaddled.Artists.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  alias Swaddled.Genres.Genre

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "artists" do
    field :name, :string
    field :spotify_id, :string

    has_many :tracks, Swaddled.Tracks.Track
    many_to_many :genres, Genre, join_through: "artists_genres"
  end

  @doc false
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:name, :spotify_id])
    |> validate_required([:name])
  end
end
