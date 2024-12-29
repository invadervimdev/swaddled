defmodule Swaddled.Tracks.Track do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tracks" do
    field :name, :string
    field :spotify_uri, :string

    belongs_to :artist, Swaddled.Artists.Artist
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:spotify_uri, :name])
    |> validate_required([:spotify_uri, :name])
  end
end
