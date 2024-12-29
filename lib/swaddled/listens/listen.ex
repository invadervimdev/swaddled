defmodule Swaddled.Listens.Listen do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "listens" do
    field :started_at, :utc_datetime
    field :ms_played, :integer

    belongs_to :artist, Swaddled.Artists.Artist
    belongs_to :track, Swaddled.Tracks.Track
  end

  @doc false
  def changeset(listen, attrs) do
    listen
    |> cast(attrs, [:started_at, :ms_played])
    |> validate_required([:started_at, :ms_played])
  end
end
