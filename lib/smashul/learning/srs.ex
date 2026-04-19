defmodule Smashul.Learning.SRS do
  @moduledoc """
  Implements the SM-2 spaced repetition algorithm.

  The SM-2 algorithm calculates review intervals based on:
  - Quality of response (0-5 scale, we use 0 for wrong, 5 for correct)
  - Current ease factor (starts at 2.5)
  - Number of successful repetitions
  - Current interval

  ## Quality Ratings
  - 5: Perfect response (correct on first try)
  - 3: Correct but with hesitation
  - 0: Incorrect

  We simplify to just correct (quality=5) and incorrect (quality=0).
  """

  alias Smashul.Learning.Review

  @min_ease_factor 1.3

  @doc """
  Calculates the next review parameters after a correct answer.

  Returns a map with updated :ease_factor, :interval, :repetitions, and :next_review_at.
  """
  def correct(%Review{} = review) do
    calculate(review, 5)
  end

  @doc """
  Calculates the next review parameters after an incorrect answer.

  Returns a map with updated :ease_factor, :interval, :repetitions, and :next_review_at.
  """
  def incorrect(%Review{} = review) do
    calculate(review, 0)
  end

  defp calculate(%Review{} = review, quality) when quality >= 3 do
    new_repetitions = review.repetitions + 1

    new_interval =
      case new_repetitions do
        1 -> 1
        2 -> 6
        _ -> round(review.interval * review.ease_factor)
      end

    new_ease_factor =
      max(
        @min_ease_factor,
        review.ease_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
      )

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %{
      ease_factor: new_ease_factor,
      interval: new_interval,
      repetitions: new_repetitions,
      next_review_at: DateTime.add(now, new_interval * 86_400, :second),
      last_reviewed_at: now
    }
  end

  defp calculate(%Review{} = _review, _quality) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %{
      ease_factor: max(@min_ease_factor, _review.ease_factor - 0.2),
      interval: 0,
      repetitions: 0,
      next_review_at: DateTime.add(now, 60, :second),
      last_reviewed_at: now
    }
  end

  @doc """
  Returns true if a review item is considered "mastered".

  A word is mastered when its interval is at least 21 days (3 weeks),
  meaning the learner has demonstrated long-term retention.
  """
  def mastered?(%Review{interval: interval}), do: interval >= 21
end
