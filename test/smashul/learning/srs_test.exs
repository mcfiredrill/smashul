defmodule Smashul.Learning.SRSTest do
  use Smashul.DataCase, async: true

  alias Smashul.Learning.{Review, SRS}

  describe "correct/1" do
    test "first correct answer sets interval to 1 day" do
      review = %Review{
        ease_factor: 2.5,
        interval: 0,
        repetitions: 0,
        next_review_at: DateTime.utc_now()
      }

      result = SRS.correct(review)

      assert result.repetitions == 1
      assert result.interval == 1
      assert result.ease_factor == 2.6
      assert result.last_reviewed_at != nil
      assert DateTime.compare(result.next_review_at, DateTime.utc_now()) == :gt
    end

    test "second correct answer sets interval to 6 days" do
      review = %Review{
        ease_factor: 2.5,
        interval: 1,
        repetitions: 1,
        next_review_at: DateTime.utc_now()
      }

      result = SRS.correct(review)

      assert result.repetitions == 2
      assert result.interval == 6
      assert result.ease_factor == 2.6
    end

    test "subsequent correct answers multiply interval by ease factor" do
      review = %Review{
        ease_factor: 2.5,
        interval: 6,
        repetitions: 2,
        next_review_at: DateTime.utc_now()
      }

      result = SRS.correct(review)

      assert result.repetitions == 3
      assert result.interval == 15
      assert_in_delta result.ease_factor, 2.6, 0.01
    end

    test "ease factor increases on perfect responses" do
      review = %Review{
        ease_factor: 2.5,
        interval: 15,
        repetitions: 3,
        next_review_at: DateTime.utc_now()
      }

      result = SRS.correct(review)

      assert result.ease_factor > 2.5
    end
  end

  describe "incorrect/1" do
    test "resets repetitions and interval on incorrect answer" do
      review = %Review{
        ease_factor: 2.5,
        interval: 15,
        repetitions: 3,
        next_review_at: DateTime.utc_now()
      }

      result = SRS.incorrect(review)

      assert result.repetitions == 0
      assert result.interval == 0
      assert result.last_reviewed_at != nil
    end

    test "decreases ease factor but not below minimum" do
      review = %Review{
        ease_factor: 1.5,
        interval: 6,
        repetitions: 2,
        next_review_at: DateTime.utc_now()
      }

      result = SRS.incorrect(review)

      assert result.ease_factor >= 1.3
    end

    test "schedules next review soon (1 minute)" do
      now = DateTime.utc_now()

      review = %Review{
        ease_factor: 2.5,
        interval: 6,
        repetitions: 2,
        next_review_at: now
      }

      result = SRS.incorrect(review)

      diff = DateTime.diff(result.next_review_at, now, :second)
      # Should be roughly 60 seconds from now (with small tolerance for execution time)
      assert diff >= 55 and diff <= 65
    end
  end

  describe "mastered?/1" do
    test "returns true when interval is 21 or more days" do
      assert SRS.mastered?(%Review{interval: 21})
      assert SRS.mastered?(%Review{interval: 30})
    end

    test "returns false when interval is less than 21 days" do
      refute SRS.mastered?(%Review{interval: 0})
      refute SRS.mastered?(%Review{interval: 20})
    end
  end
end
