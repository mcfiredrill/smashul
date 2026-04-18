defmodule SmashulWeb.PageControllerTest do
  use SmashulWeb.ConnCase

  alias Smashul.Dictionary

  setup do
    {:ok, _w1} =
      Dictionary.create_word(%{hangul: "안녕", romanization: "annyeong", meaning: "hello", level: 1})

    :ok
  end

  test "GET / redirects to LiveView dashboard", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "스매셜"
  end
end
