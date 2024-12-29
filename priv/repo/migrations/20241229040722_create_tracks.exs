defmodule Swaddled.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :spotify_uri, :string
      add :name, :string
      add :artist_id, references(:artists, on_delete: :nothing, type: :binary_id)
    end

    create index(:tracks, [:artist_id])
    create unique_index(:tracks, [:artist_id, :name, :spotify_uri])
  end
end
