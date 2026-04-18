defmodule Smashul.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :learner_id, references(:learners, on_delete: :delete_all), null: false
      add :word_id, references(:words, on_delete: :delete_all), null: false
      add :ease_factor, :float, null: false, default: 2.5
      add :interval, :integer, null: false, default: 0
      add :repetitions, :integer, null: false, default: 0
      add :next_review_at, :utc_datetime, null: false
      add :last_reviewed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:learner_id])
    create index(:reviews, [:word_id])
    create index(:reviews, [:next_review_at])
    create unique_index(:reviews, [:learner_id, :word_id])
  end
end
