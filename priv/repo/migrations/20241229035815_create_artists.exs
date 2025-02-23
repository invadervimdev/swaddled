defmodule Swaddled.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
    end

    create unique_index(:artists, [:name])
  end
end
