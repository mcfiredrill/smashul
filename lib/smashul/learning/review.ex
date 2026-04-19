defmodule Smashul.Learning.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :ease_factor, :float, default: 2.5
    field :interval, :integer, default: 0
    field :repetitions, :integer, default: 0
    field :next_review_at, :utc_datetime
    field :last_reviewed_at, :utc_datetime

    belongs_to :learner, Smashul.Learning.Learner
    belongs_to :word, Smashul.Dictionary.Word

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:ease_factor, :interval, :repetitions, :next_review_at, :last_reviewed_at])
    |> validate_required([:ease_factor, :interval, :repetitions, :next_review_at])
    |> validate_number(:ease_factor, greater_than_or_equal_to: 1.3)
    |> validate_number(:interval, greater_than_or_equal_to: 0)
    |> validate_number(:repetitions, greater_than_or_equal_to: 0)
  end
end
