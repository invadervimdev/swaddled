defmodule Swaddled.Repo.Migrations.CreateGenres do
  use Ecto.Migration

  def change do
    create table(:genres, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
    end

    create unique_index(:genres, [:name])

    create table(:artists_genres, primary_key: false) do
      add :artist_id, references(:artists, on_delete: :nothing, type: :binary_id),
        null: false,
        primary_key: true

      add :genre_id, references(:genres, on_delete: :nothing, type: :binary_id),
        null: false,
        primary_key: true
    end

    create unique_index(:artists_genres, [:genre_id, :artist_id])
  end
end
