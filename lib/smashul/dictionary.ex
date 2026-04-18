defmodule Smashul.Dictionary do
  @moduledoc """
  The Dictionary context for managing Korean words.
  """

  import Ecto.Query
  alias Smashul.Repo
  alias Smashul.Dictionary.Word

  @doc """
  Returns all words for a given level.
  """
  def list_words_by_level(level) do
    Word
    |> where([w], w.level == ^level)
    |> order_by([w], asc: w.id)
    |> Repo.all()
  end

  @doc """
  Returns all words for levels up to and including the given level.
  """
  def list_words_up_to_level(level) do
    Word
    |> where([w], w.level <= ^level)
    |> order_by([w], [asc: w.level, asc: w.id])
    |> Repo.all()
  end

  @doc """
  Returns the total number of levels available.
  """
  def max_level do
    Repo.one(from w in Word, select: max(w.level)) || 1
  end

  @doc """
  Returns the count of words for a given level.
  """
  def count_words_by_level(level) do
    Word
    |> where([w], w.level == ^level)
    |> Repo.aggregate(:count)
  end

  @doc """
  Gets a single word by id.
  """
  def get_word!(id), do: Repo.get!(Word, id)

  @doc """
  Creates a word.
  """
  def create_word(attrs \\ %{}) do
    %Word{}
    |> Word.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a word, raising on failure. Used for seeding.
  """
  def create_word!(attrs) do
    %Word{}
    |> Word.changeset(attrs)
    |> Repo.insert!()
  end
end
