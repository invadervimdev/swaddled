defmodule Swaddled.Repo.Migrations.AddSpotifyIdToArtists do
  use Ecto.Migration

  def change do
    alter table(:artists) do
      add :spotify_id, :string
    end

    rename table(:tracks), :spotify_uri, to: :spotify_id
  end
end
