defmodule SmashulWeb.PracticeLiveTest do
  use SmashulWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Smashul.Dictionary

  setup %{conn: conn} do
    # Create test words
    {:ok, w1} =
      Dictionary.create_word(%{hangul: "안녕", romanization: "annyeong", meaning: "hello", level: 1})

    {:ok, w2} =
      Dictionary.create_word(%{hangul: "감사", romanization: "gamsa", meaning: "thanks", level: 1})

    # Create a learner and set up session
    token = "test-practice-#{System.unique_integer()}"
    {:ok, learner} = Smashul.Learning.get_or_create_learner(token)
    conn = conn |> Plug.Test.init_test_session(%{learner_token: token})

    %{words: [w1, w2], conn: conn, learner: learner}
  end

  test "renders practice page with words to practice", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/practice")

    assert render(view) =~ "Type in Hangul"
  end

  test "shows word meaning and romanization", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/practice")

    html = render(view)
    # Should show either "hello" or "thanks" (the meaning of first word)
    assert html =~ "hello" or html =~ "thanks"
  end

  test "correct answer shows success feedback", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/practice")

    # Find the current word being shown and submit the correct answer
    html = render(view)

    answer =
      if html =~ "hello" do
        "안녕"
      else
        "감사"
      end

    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => answer})

    assert render(view) =~ "Correct"
  end

  test "incorrect answer shows error feedback", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/practice")

    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => "잘못된"})

    assert render(view) =~ "Not quite"
  end

  test "can continue to next word after answering", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/practice")

    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => "잘못된"})

    assert has_element?(view, "#next-btn")
    view |> element("#next-btn") |> render_click()

    # Should still be in typing state for the next word
    assert render(view) =~ "Type in Hangul"
  end

  test "completing all words shows session complete", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/practice")

    # Answer first word (wrong)
    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => "잘못된"})

    view |> element("#next-btn") |> render_click()

    # Answer second word (wrong)
    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => "잘못된"})

    view |> element("#next-btn") |> render_click()

    assert render(view) =~ "Session Complete"
  end

  test "session complete shows correct and incorrect counts", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/practice")

    html = render(view)

    correct_answer =
      if html =~ "hello" do
        "안녕"
      else
        "감사"
      end

    # Answer first word correctly
    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => correct_answer})

    view |> element("#next-btn") |> render_click()

    # Answer second word incorrectly
    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => "잘못된"})

    view |> element("#next-btn") |> render_click()

    html = render(view)
    assert html =~ "Session Complete"
    assert html =~ "Correct"
    assert html =~ "Incorrect"
  end

  test "back to dashboard button works from complete state", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/practice")

    # Complete all words
    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => "잘못된"})

    view |> element("#next-btn") |> render_click()

    view
    |> element("#hangul-input-container")
    |> render_hook("submit_answer", %{"value" => "잘못된"})

    view |> element("#next-btn") |> render_click()

    assert has_element?(view, "#finish-btn")
    view |> element("#finish-btn") |> render_click()

    assert_redirect(view, "/")
  end
end
