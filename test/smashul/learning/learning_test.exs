defmodule Smashul.LearningTest do
  use Smashul.DataCase, async: true

  alias Smashul.Learning
  alias Smashul.Dictionary

  setup do
    # Create test words
    {:ok, w1} =
      Dictionary.create_word(%{hangul: "안녕", romanization: "annyeong", meaning: "hello", level: 1})

    {:ok, w2} =
      Dictionary.create_word(%{hangul: "감사", romanization: "gamsa", meaning: "thanks", level: 1})

    {:ok, w3} =
      Dictionary.create_word(%{hangul: "사랑", romanization: "sarang", meaning: "love", level: 2})

    # Create a learner
    token = "test-token-#{System.unique_integer()}"
    {:ok, learner} = Learning.get_or_create_learner(token)

    %{learner: learner, words: [w1, w2, w3]}
  end

  describe "get_or_create_learner/1" do
    test "creates a new learner with given token" do
      token = "new-token-#{System.unique_integer()}"
      assert {:ok, learner} = Learning.get_or_create_learner(token)
      assert learner.token == token
      assert learner.current_level == 1
    end

    test "returns existing learner for same token" do
      token = "existing-token-#{System.unique_integer()}"
      {:ok, learner1} = Learning.get_or_create_learner(token)
      {:ok, learner2} = Learning.get_or_create_learner(token)
      assert learner1.id == learner2.id
    end
  end

  describe "introduce_new_words/2" do
    test "creates reviews for new words at learner's level", %{learner: learner} do
      reviews = Learning.introduce_new_words(learner, 5)

      assert length(reviews) == 2
      word_ids = Enum.map(reviews, & &1.word_id)
      assert length(Enum.uniq(word_ids)) == 2
    end

    test "does not introduce words above learner's level", %{learner: learner, words: [_w1, _w2, w3]} do
      reviews = Learning.introduce_new_words(learner, 10)

      word_ids = Enum.map(reviews, & &1.word_id)
      refute w3.id in word_ids
    end

    test "does not duplicate existing reviews", %{learner: learner} do
      Learning.introduce_new_words(learner, 5)
      second_batch = Learning.introduce_new_words(learner, 5)

      assert second_batch == []
    end
  end

  describe "due_reviews/2" do
    test "returns reviews that are due", %{learner: learner} do
      Learning.introduce_new_words(learner, 5)

      reviews = Learning.due_reviews(learner)
      assert length(reviews) == 2

      Enum.each(reviews, fn review ->
        assert review.word != nil
        assert review.word.hangul != nil
      end)
    end

    test "returns empty list when no reviews are due", %{learner: learner} do
      assert Learning.due_reviews(learner) == []
    end
  end

  describe "due_review_count/1" do
    test "returns count of due reviews", %{learner: learner} do
      assert Learning.due_review_count(learner) == 0

      Learning.introduce_new_words(learner, 5)
      assert Learning.due_review_count(learner) == 2
    end
  end

  describe "record_correct/1 and record_incorrect/1" do
    test "record_correct updates review with SRS parameters", %{learner: learner} do
      Learning.introduce_new_words(learner, 5)
      [review | _] = Learning.due_reviews(learner)

      {:ok, updated} = Learning.record_correct(review)

      assert updated.repetitions == 1
      assert updated.interval == 1
      assert updated.last_reviewed_at != nil
    end

    test "record_incorrect resets review", %{learner: learner} do
      Learning.introduce_new_words(learner, 5)
      [review | _] = Learning.due_reviews(learner)

      {:ok, updated} = Learning.record_incorrect(review)

      assert updated.repetitions == 0
      assert updated.interval == 0
    end
  end

  describe "stats/1" do
    test "returns correct statistics", %{learner: learner} do
      stats = Learning.stats(learner)

      assert stats.total_words_seen == 0
      assert stats.mastered == 0
      assert stats.in_progress == 0
      assert stats.current_level == 1
    end

    test "updates after introducing words", %{learner: learner} do
      Learning.introduce_new_words(learner, 5)

      stats = Learning.stats(learner)

      assert stats.total_words_seen == 2
      assert stats.in_progress == 2
      assert stats.mastered == 0
    end
  end
end
