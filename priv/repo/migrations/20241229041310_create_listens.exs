defmodule Swaddled.Repo.Migrations.CreateListens do
  use Ecto.Migration

  def change do
    create table(:listens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :started_at, :utc_datetime
      add :ms_played, :integer
      add :artist_id, references(:artists, on_delete: :nothing, type: :binary_id)
      add :track_id, references(:tracks, on_delete: :nothing, type: :binary_id)
    end

    create index(:listens, [:artist_id])
    create index(:listens, [:track_id])
    create unique_index(:listens, [:artist_id, :track_id, :started_at, :ms_played])
  end
end
