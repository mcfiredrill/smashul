defmodule Smashul.Repo.Migrations.CreateWords do
  use Ecto.Migration

  def change do
    create table(:words) do
      add :hangul, :string, null: false
      add :romanization, :string, null: false
      add :meaning, :string, null: false
      add :level, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:words, [:level])
    create unique_index(:words, [:hangul])
  end
end
