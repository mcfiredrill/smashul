defmodule Smashul.Dictionary.Word do
  use Ecto.Schema
  import Ecto.Changeset

  schema "words" do
    field :hangul, :string
    field :romanization, :string
    field :meaning, :string
    field :level, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(word, attrs) do
    word
    |> cast(attrs, [:hangul, :romanization, :meaning, :level])
    |> validate_required([:hangul, :romanization, :meaning, :level])
    |> validate_number(:level, greater_than: 0)
    |> unique_constraint(:hangul)
  end
end
