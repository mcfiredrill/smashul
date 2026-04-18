defmodule Smashul.Repo.Migrations.CreateLearners do
  use Ecto.Migration

  def change do
    create table(:learners) do
      add :token, :string, null: false
      add :current_level, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create unique_index(:learners, [:token])
  end
end
