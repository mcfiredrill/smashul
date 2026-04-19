defmodule Smashul.Learning.Learner do
  use Ecto.Schema
  import Ecto.Changeset

  schema "learners" do
    field :token, :string
    field :current_level, :integer, default: 1

    has_many :reviews, Smashul.Learning.Review

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(learner, attrs) do
    learner
    |> cast(attrs, [:current_level])
    |> validate_required([:token, :current_level])
    |> validate_number(:current_level, greater_than: 0)
    |> unique_constraint(:token)
  end

  @doc false
  def create_changeset(learner, attrs) do
    learner
    |> cast(attrs, [:current_level])
    |> put_change(:token, generate_token())
    |> validate_required([:token, :current_level])
    |> validate_number(:current_level, greater_than: 0)
    |> unique_constraint(:token)
  end

  defp generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end
end
