defmodule SmashulWeb.DashboardLive do
  use SmashulWeb, :live_view

  alias Smashul.Learning

  @impl true
  def mount(_params, session, socket) do
    learner = get_learner(session)
    stats = Learning.stats(learner)
    due_count = Learning.due_review_count(learner)
    next_review = Learning.next_review_time(learner)
    max_level = Smashul.Dictionary.max_level()

    {:ok,
     assign(socket,
       learner: learner,
       stats: stats,
       due_count: due_count,
       next_review: next_review,
       max_level: max_level,
       page_title: "스매셜 - Korean Practice"
     )}
  end

  @impl true
  def handle_event("start_practice", _params, socket) do
    learner = socket.assigns.learner

    # Introduce new words if the learner has no reviews yet or few due
    due_count = Learning.due_review_count(learner)

    if due_count == 0 do
      Learning.introduce_new_words(learner, 5)
    end

    {:noreply, push_navigate(socket, to: ~p"/practice")}
  end

  @impl true
  def handle_event("learn_new", _params, socket) do
    learner = socket.assigns.learner
    Learning.introduce_new_words(learner, 5)

    stats = Learning.stats(learner)
    due_count = Learning.due_review_count(learner)

    {:noreply,
     socket
     |> assign(stats: stats, due_count: due_count)
     |> put_flash(:info, "New words unlocked! Start practicing.")}
  end

  defp get_learner(session) do
    token = session["learner_token"]

    if token do
      case Learning.get_learner_by_token(token) do
        nil ->
          {:ok, learner} = Learning.get_or_create_learner(token)
          learner

        learner ->
          learner
      end
    else
      token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
      {:ok, learner} = Learning.get_or_create_learner(token)
      learner
    end
  end

  defp format_next_review(nil), do: nil

  defp format_next_review(datetime) do
    diff = DateTime.diff(datetime, DateTime.utc_now(), :second)

    cond do
      diff <= 0 -> "Now"
      diff < 60 -> "#{diff}s"
      diff < 3600 -> "#{div(diff, 60)}m"
      diff < 86_400 -> "#{div(diff, 3600)}h"
      true -> "#{div(diff, 86_400)}d"
    end
  end

  defp mastery_percentage(%{level_words_total: 0}), do: 0

  defp mastery_percentage(stats) do
    round(stats.level_words_mastered / stats.level_words_total * 100)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center min-h-[70vh]">
        <%!-- Hero Section --%>
        <div class="text-center mb-12">
          <h1 class="text-5xl font-bold mb-3 tracking-tight">
            <span class="bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
              스매셜
            </span>
          </h1>
          <p class="text-lg text-base-content/60">
            Master Korean typing through spaced repetition
          </p>
        </div>

        <%!-- Level Badge --%>
        <div class="mb-8">
          <div class={[
            "inline-flex items-center gap-2 px-5 py-2.5 rounded-full",
            "bg-gradient-to-r from-indigo-500/10 to-purple-500/10",
            "border border-indigo-500/20"
          ]}>
            <span class="text-sm font-medium text-base-content/60">Level</span>
            <span class="text-2xl font-bold text-indigo-500">{@stats.current_level}</span>
            <span class="text-xs text-base-content/40">/ {@max_level}</span>
          </div>
        </div>

        <%!-- Main Action Card --%>
        <div class={[
          "w-full max-w-md rounded-2xl p-8 mb-8",
          "bg-base-200/50 border border-base-300",
          "shadow-lg shadow-base-300/20"
        ]}>
          <%= if @due_count > 0 do %>
            <div class="text-center">
              <div class="text-6xl font-bold text-indigo-500 mb-2">{@due_count}</div>
              <p class="text-base-content/60 mb-6">
                <%= if @due_count == 1, do: "word", else: "words" %> ready for review
              </p>
              <button
                id="start-practice-btn"
                phx-click="start_practice"
                class={[
                  "w-full py-4 px-8 rounded-xl font-semibold text-lg",
                  "bg-gradient-to-r from-indigo-500 to-purple-600 text-white",
                  "hover:from-indigo-600 hover:to-purple-700",
                  "transform hover:scale-[1.02] active:scale-[0.98]",
                  "transition-all duration-200 ease-out",
                  "shadow-lg shadow-indigo-500/25 hover:shadow-xl hover:shadow-indigo-500/30"
                ]}
              >
                Start Review
              </button>
            </div>
          <% else %>
            <div class="text-center">
              <div class="text-5xl mb-4">✨</div>
              <p class="text-lg font-medium text-base-content/80 mb-2">All caught up!</p>
              <%= if @next_review do %>
                <p class="text-sm text-base-content/50 mb-6">
                  Next review in <span class="font-semibold text-indigo-500">{format_next_review(@next_review)}</span>
                </p>
              <% end %>
              <button
                id="learn-new-btn"
                phx-click="learn_new"
                class={[
                  "w-full py-4 px-8 rounded-xl font-semibold text-lg",
                  "bg-gradient-to-r from-emerald-500 to-teal-600 text-white",
                  "hover:from-emerald-600 hover:to-teal-700",
                  "transform hover:scale-[1.02] active:scale-[0.98]",
                  "transition-all duration-200 ease-out",
                  "shadow-lg shadow-emerald-500/25 hover:shadow-xl hover:shadow-emerald-500/30"
                ]}
              >
                Learn New Words
              </button>
            </div>
          <% end %>
        </div>

        <%!-- Stats Grid --%>
        <div class="w-full max-w-md grid grid-cols-3 gap-4 mb-8">
          <div class={[
            "text-center p-4 rounded-xl",
            "bg-base-200/30 border border-base-300/50"
          ]}>
            <div class="text-2xl font-bold text-emerald-500">{@stats.mastered}</div>
            <div class="text-xs text-base-content/50 mt-1">Mastered</div>
          </div>
          <div class={[
            "text-center p-4 rounded-xl",
            "bg-base-200/30 border border-base-300/50"
          ]}>
            <div class="text-2xl font-bold text-amber-500">{@stats.in_progress}</div>
            <div class="text-xs text-base-content/50 mt-1">Learning</div>
          </div>
          <div class={[
            "text-center p-4 rounded-xl",
            "bg-base-200/30 border border-base-300/50"
          ]}>
            <div class="text-2xl font-bold text-indigo-500">{@stats.total_words_seen}</div>
            <div class="text-xs text-base-content/50 mt-1">Total</div>
          </div>
        </div>

        <%!-- Level Progress --%>
        <div class="w-full max-w-md">
          <div class="flex items-center justify-between mb-2">
            <span class="text-sm font-medium text-base-content/60">Level {@stats.current_level} Progress</span>
            <span class="text-sm font-semibold text-indigo-500">{mastery_percentage(@stats)}%</span>
          </div>
          <div class="w-full h-2.5 bg-base-300/50 rounded-full overflow-hidden">
            <div
              class="h-full bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full transition-all duration-500 ease-out"
              style={"width: #{mastery_percentage(@stats)}%"}
            >
            </div>
          </div>
          <p class="text-xs text-base-content/40 mt-2">
            Master {round(@stats.mastery_threshold * 100)}% of words to unlock level {@stats.current_level + 1}
          </p>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
