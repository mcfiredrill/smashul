defmodule SmashulWeb.DashboardLiveTest do
  use SmashulWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Smashul.Dictionary
  alias Smashul.Learning

  setup %{conn: conn} do
    # Create test words
    {:ok, _w1} =
      Dictionary.create_word(%{hangul: "안녕", romanization: "annyeong", meaning: "hello", level: 1})

    {:ok, _w2} =
      Dictionary.create_word(%{hangul: "감사", romanization: "gamsa", meaning: "thanks", level: 1})

    # Create a learner and set up session
    token = "test-dashboard-#{System.unique_integer()}"
    {:ok, learner} = Learning.get_or_create_learner(token)
    conn = conn |> Plug.Test.init_test_session(%{learner_token: token})

    %{conn: conn, learner: learner}
  end

  test "renders dashboard page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "스매셜"
  end

  test "shows level information", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "Level"
  end

  test "shows stats section", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "Mastered"
    assert render(view) =~ "Learning"
    assert render(view) =~ "Total"
  end

  test "learn new words button introduces words and updates stats", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # Should show "Learn New Words" button initially since no reviews are due
    assert has_element?(view, "#learn-new-btn")
    view |> element("#learn-new-btn") |> render_click()

    assert render(view) =~ "New words unlocked"
  end

  test "start practice navigates to practice page", %{conn: conn, learner: learner} do
    # First introduce words so there are due reviews
    Learning.introduce_new_words(learner, 5)

    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#start-practice-btn")
    view |> element("#start-practice-btn") |> render_click()

    assert_redirect(view, "/practice")
  end
end
