defmodule Smashul.Learning do
  @moduledoc """
  The Learning context manages learner progress, reviews, and level progression.
  """

  import Ecto.Query
  alias Smashul.Repo
  alias Smashul.Learning.{Learner, Review, SRS}
  alias Smashul.Dictionary

  # Percentage of words that must be mastered to unlock next level
  @mastery_threshold 0.8

  ## Learner Functions

  @doc """
  Gets or creates a learner by their session token.
  """
  def get_or_create_learner(token) do
    case Repo.get_by(Learner, token: token) do
      nil ->
        %Learner{}
        |> Learner.create_changeset(%{})
        |> Ecto.Changeset.put_change(:token, token)
        |> Repo.insert()

      learner ->
        {:ok, learner}
    end
  end

  @doc """
  Gets a learner by token.
  """
  def get_learner_by_token(token) do
    Repo.get_by(Learner, token: token)
  end

  @doc """
  Gets a learner by id.
  """
  def get_learner!(id), do: Repo.get!(Learner, id)

  ## Review Functions

  @doc """
  Returns the reviews due for a learner right now, with words preloaded.
  Limited to `limit` items (default 10 for a batch).
  """
  def due_reviews(learner, limit \\ 10) do
    now = DateTime.utc_now()

    Review
    |> where([r], r.learner_id == ^learner.id)
    |> where([r], r.next_review_at <= ^now)
    |> order_by([r], asc: r.next_review_at)
    |> limit(^limit)
    |> preload(:word)
    |> Repo.all()
  end

  @doc """
  Returns the count of reviews due for a learner.
  """
  def due_review_count(learner) do
    now = DateTime.utc_now()

    Review
    |> where([r], r.learner_id == ^learner.id)
    |> where([r], r.next_review_at <= ^now)
    |> Repo.aggregate(:count)
  end

  @doc """
  Returns the next review time for a learner, or nil if no reviews exist.
  """
  def next_review_time(learner) do
    Review
    |> where([r], r.learner_id == ^learner.id)
    |> where([r], r.next_review_at > ^DateTime.utc_now())
    |> order_by([r], asc: r.next_review_at)
    |> limit(1)
    |> select([r], r.next_review_at)
    |> Repo.one()
  end

  @doc """
  Introduces new words to a learner for their current level.

  Creates review records for words the learner hasn't seen yet,
  up to `count` new words at a time.
  """
  def introduce_new_words(learner, count \\ 5) do
    existing_word_ids =
      Review
      |> where([r], r.learner_id == ^learner.id)
      |> select([r], r.word_id)
      |> Repo.all()

    new_words =
      Smashul.Dictionary.Word
      |> where([w], w.level <= ^learner.current_level)
      |> where([w], w.id not in ^existing_word_ids)
      |> order_by([w], [asc: w.level, asc: w.id])
      |> limit(^count)
      |> Repo.all()

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    reviews =
      Enum.map(new_words, fn word ->
        %Review{learner_id: learner.id, word_id: word.id}
        |> Review.changeset(%{next_review_at: now})
        |> Repo.insert!()
      end)

    reviews
  end

  @doc """
  Records a correct answer for a review and updates SRS parameters.
  """
  def record_correct(review) do
    updates = SRS.correct(review)

    review
    |> Review.changeset(updates)
    |> Repo.update()
  end

  @doc """
  Records an incorrect answer for a review and updates SRS parameters.
  """
  def record_incorrect(review) do
    updates = SRS.incorrect(review)

    review
    |> Review.changeset(updates)
    |> Repo.update()
  end

  @doc """
  Gets a review by id with word preloaded.
  """
  def get_review!(id) do
    Review
    |> preload(:word)
    |> Repo.get!(id)
  end

  ## Level Progression

  @doc """
  Checks if a learner should level up and performs the level up if so.

  Returns `{:leveled_up, new_level}` or `:not_ready`.
  """
  def check_level_up(learner) do
    total_words = Dictionary.count_words_by_level(learner.current_level)

    if total_words == 0 do
      :not_ready
    else
      mastered_count =
        Review
        |> join(:inner, [r], w in assoc(r, :word))
        |> where([r, w], r.learner_id == ^learner.id)
        |> where([r, w], w.level == ^learner.current_level)
        |> where([r], r.interval >= 21)
        |> Repo.aggregate(:count)

      mastery_ratio = mastered_count / total_words

      if mastery_ratio >= @mastery_threshold do
        max_level = Dictionary.max_level()
        new_level = min(learner.current_level + 1, max_level)

        if new_level > learner.current_level do
          learner
          |> Learner.changeset(%{current_level: new_level})
          |> Repo.update!()

          {:leveled_up, new_level}
        else
          :not_ready
        end
      else
        :not_ready
      end
    end
  end

  ## Stats

  @doc """
  Returns learning statistics for a learner.
  """
  def stats(learner) do
    reviews =
      Review
      |> where([r], r.learner_id == ^learner.id)
      |> preload(:word)
      |> Repo.all()

    total = length(reviews)
    mastered = Enum.count(reviews, &SRS.mastered?/1)
    in_progress = total - mastered

    level_words = Dictionary.count_words_by_level(learner.current_level)

    level_mastered =
      Enum.count(reviews, fn r ->
        r.word.level == learner.current_level && SRS.mastered?(r)
      end)

    %{
      total_words_seen: total,
      mastered: mastered,
      in_progress: in_progress,
      current_level: learner.current_level,
      level_words_total: level_words,
      level_words_mastered: level_mastered,
      mastery_threshold: @mastery_threshold
    }
  end
end
