defmodule Smashul.DictionaryTest do
  use Smashul.DataCase, async: true

  alias Smashul.Dictionary
  alias Smashul.Dictionary.Word

  setup do
    # Create some test words
    {:ok, w1} =
      Dictionary.create_word(%{hangul: "안녕", romanization: "annyeong", meaning: "hello", level: 1})

    {:ok, w2} =
      Dictionary.create_word(%{hangul: "감사", romanization: "gamsa", meaning: "thanks", level: 1})

    {:ok, w3} =
      Dictionary.create_word(%{hangul: "사랑", romanization: "sarang", meaning: "love", level: 2})

    %{words: [w1, w2, w3]}
  end

  describe "list_words_by_level/1" do
    test "returns words for the specified level", %{words: [w1, w2, _w3]} do
      words = Dictionary.list_words_by_level(1)

      assert length(words) == 2
      ids = Enum.map(words, & &1.id)
      assert w1.id in ids
      assert w2.id in ids
    end

    test "returns empty list for level with no words" do
      assert Dictionary.list_words_by_level(99) == []
    end
  end

  describe "list_words_up_to_level/1" do
    test "returns words for all levels up to specified level", %{words: [w1, w2, w3]} do
      words = Dictionary.list_words_up_to_level(2)

      assert length(words) == 3
      ids = Enum.map(words, & &1.id)
      assert w1.id in ids
      assert w2.id in ids
      assert w3.id in ids
    end

    test "returns only level 1 words when level is 1", %{words: [_w1, _w2, w3]} do
      words = Dictionary.list_words_up_to_level(1)

      assert length(words) == 2
      ids = Enum.map(words, & &1.id)
      refute w3.id in ids
    end
  end

  describe "count_words_by_level/1" do
    test "returns correct count", _context do
      assert Dictionary.count_words_by_level(1) == 2
      assert Dictionary.count_words_by_level(2) == 1
      assert Dictionary.count_words_by_level(99) == 0
    end
  end

  describe "max_level/0" do
    test "returns the highest level", _context do
      assert Dictionary.max_level() == 2
    end
  end

  describe "create_word/1" do
    test "creates a word with valid attributes" do
      attrs = %{hangul: "물", romanization: "mul", meaning: "water", level: 1}
      assert {:ok, %Word{} = word} = Dictionary.create_word(attrs)
      assert word.hangul == "물"
      assert word.romanization == "mul"
      assert word.meaning == "water"
      assert word.level == 1
    end

    test "returns error with invalid attributes" do
      assert {:error, _changeset} = Dictionary.create_word(%{})
    end

    test "enforces unique hangul constraint" do
      attrs = %{hangul: "테스트", romanization: "teseuteu", meaning: "test1", level: 1}
      assert {:ok, _word} = Dictionary.create_word(attrs)

      attrs2 = %{hangul: "테스트", romanization: "teseuteu", meaning: "test2", level: 2}
      assert {:error, changeset} = Dictionary.create_word(attrs2)
      assert "has already been taken" in errors_on(changeset).hangul
    end
  end
end
