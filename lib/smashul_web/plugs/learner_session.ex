defmodule SmashulWeb.Plugs.LearnerSession do
  @moduledoc """
  Plug that ensures a learner exists for the current browser session.

  Creates an anonymous learner if one doesn't exist, storing the token
  in the session cookie for persistence.
  """

  import Plug.Conn
  alias Smashul.Learning

  def init(opts), do: opts

  def call(conn, _opts) do
    token = get_session(conn, :learner_token)

    {conn, learner} =
      if token do
        case Learning.get_learner_by_token(token) do
          nil ->
            create_learner(conn)

          learner ->
            {conn, learner}
        end
      else
        create_learner(conn)
      end

    assign(conn, :current_learner, learner)
  end

  defp create_learner(conn) do
    token = generate_token()
    {:ok, learner} = Learning.get_or_create_learner(token)

    conn = put_session(conn, :learner_token, token)
    {conn, learner}
  end

  defp generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end
end
