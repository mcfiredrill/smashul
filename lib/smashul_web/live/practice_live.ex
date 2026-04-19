defmodule SmashulWeb.PracticeLive do
  use SmashulWeb, :live_view

  alias Smashul.Learning

  @impl true
  def mount(_params, session, socket) do
    learner = get_learner(session)

    # Get due reviews for this session
    reviews = Learning.due_reviews(learner, 10)

    socket =
      if reviews == [] do
        # No reviews due, try introducing new words
        new_reviews = Learning.introduce_new_words(learner, 5)

        if new_reviews == [] do
          socket
          |> assign(
            learner: learner,
            reviews: [],
            current_review: nil,
            current_index: 0,
            total_count: 0,
            input_value: "",
            state: :empty,
            correct_count: 0,
            incorrect_count: 0,
            page_title: "Practice - 스매셜"
          )
        else
          reviews = Learning.due_reviews(learner, 10)
          current = List.first(reviews)

          socket
          |> assign(
            learner: learner,
            reviews: reviews,
            current_review: current,
            current_index: 0,
            total_count: length(reviews),
            input_value: "",
            state: :typing,
            correct_count: 0,
            incorrect_count: 0,
            page_title: "Practice - 스매셜"
          )
        end
      else
        current = List.first(reviews)

        socket
        |> assign(
          learner: learner,
          reviews: reviews,
          current_review: current,
          current_index: 0,
          total_count: length(reviews),
          input_value: "",
          state: :typing,
          correct_count: 0,
          incorrect_count: 0,
          page_title: "Practice - 스매셜"
        )
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("hangul_input", %{"value" => value}, socket) do
    {:noreply, assign(socket, input_value: value)}
  end

  @impl true
  def handle_event("submit_answer", %{"value" => value}, socket) do
    review = socket.assigns.current_review
    input = String.trim(value)
    correct = input == review.word.hangul

    socket =
      if correct do
        {:ok, _updated_review} = Learning.record_correct(review)

        socket
        |> assign(
          state: :correct,
          input_value: input,
          correct_count: socket.assigns.correct_count + 1
        )
      else
        {:ok, _updated_review} = Learning.record_incorrect(review)

        socket
        |> assign(
          state: :incorrect,
          input_value: input,
          incorrect_count: socket.assigns.incorrect_count + 1
        )
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("next_word", _params, socket) do
    next_index = socket.assigns.current_index + 1

    if next_index >= socket.assigns.total_count do
      # Check for level up
      learner = Learning.get_learner!(socket.assigns.learner.id)
      level_up_result = Learning.check_level_up(learner)

      {:noreply,
       assign(socket,
         state: :complete,
         learner: learner,
         level_up: level_up_result
       )}
    else
      next_review = Enum.at(socket.assigns.reviews, next_index)

      {:noreply,
       assign(socket,
         current_review: next_review,
         current_index: next_index,
         input_value: "",
         state: :typing
       )}
    end
  end

  @impl true
  def handle_event("back_to_dashboard", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/")}
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

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center min-h-[70vh]">
        <%= case @state do %>
          <% :empty -> %>
            <div class="text-center mt-20">
              <div class="text-6xl mb-6">📚</div>
              <h2 class="text-2xl font-bold text-base-content/80 mb-3">No words to practice</h2>
              <p class="text-base-content/50 mb-8">All your reviews are complete for now.</p>
              <button
                id="back-btn"
                phx-click="back_to_dashboard"
                class={[
                  "py-3 px-8 rounded-xl font-semibold",
                  "bg-gradient-to-r from-indigo-500 to-purple-600 text-white",
                  "hover:from-indigo-600 hover:to-purple-700",
                  "transform hover:scale-[1.02] active:scale-[0.98]",
                  "transition-all duration-200"
                ]}
              >
                Back to Dashboard
              </button>
            </div>

          <% :complete -> %>
            <div class="text-center mt-12 w-full max-w-md">
              <div class="text-7xl mb-6">🎉</div>
              <h2 class="text-3xl font-bold text-base-content mb-4">Session Complete!</h2>

              <div class="grid grid-cols-2 gap-4 mb-8">
                <div class={[
                  "p-5 rounded-xl",
                  "bg-emerald-500/10 border border-emerald-500/20"
                ]}>
                  <div class="text-3xl font-bold text-emerald-500">{@correct_count}</div>
                  <div class="text-sm text-emerald-500/70 mt-1">Correct</div>
                </div>
                <div class={[
                  "p-5 rounded-xl",
                  "bg-rose-500/10 border border-rose-500/20"
                ]}>
                  <div class="text-3xl font-bold text-rose-500">{@incorrect_count}</div>
                  <div class="text-sm text-rose-500/70 mt-1">Incorrect</div>
                </div>
              </div>

              <%= case assigns[:level_up] do %>
                <% {:leveled_up, new_level} -> %>
                  <div class={[
                    "mb-8 p-6 rounded-2xl",
                    "bg-gradient-to-r from-amber-500/10 to-orange-500/10",
                    "border border-amber-500/30"
                  ]}>
                    <div class="text-4xl mb-2">🏆</div>
                    <p class="text-xl font-bold text-amber-500">Level Up!</p>
                    <p class="text-base-content/60 mt-1">
                      You've reached level <span class="font-bold text-amber-500">{new_level}</span>
                    </p>
                  </div>
                <% _ -> %>
              <% end %>

              <button
                id="finish-btn"
                phx-click="back_to_dashboard"
                class={[
                  "w-full py-4 px-8 rounded-xl font-semibold text-lg",
                  "bg-gradient-to-r from-indigo-500 to-purple-600 text-white",
                  "hover:from-indigo-600 hover:to-purple-700",
                  "transform hover:scale-[1.02] active:scale-[0.98]",
                  "transition-all duration-200",
                  "shadow-lg shadow-indigo-500/25"
                ]}
              >
                Back to Dashboard
              </button>
            </div>

          <% state when state in [:typing, :correct, :incorrect] -> %>
            <%!-- Progress Bar --%>
            <div class="w-full max-w-lg mb-8">
              <div class="flex items-center justify-between mb-2">
                <span class="text-sm text-base-content/50">{@current_index + 1} / {@total_count}</span>
                <span class="text-sm text-base-content/50">
                  <span class="text-emerald-500">{@correct_count}✓</span>
                  <span class="mx-1">·</span>
                  <span class="text-rose-500">{@incorrect_count}✗</span>
                </span>
              </div>
              <div class="w-full h-1.5 bg-base-300/50 rounded-full overflow-hidden">
                <div
                  class="h-full bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full transition-all duration-300"
                  style={"width: #{(@current_index + 1) / @total_count * 100}%"}
                >
                </div>
              </div>
            </div>

            <%!-- Word Card --%>
            <div class={[
              "w-full max-w-lg rounded-2xl p-10 mb-6 text-center",
              "bg-base-200/50 border border-base-300",
              "shadow-lg shadow-base-300/20",
              "transition-all duration-300"
            ]}>
              <%!-- Meaning (what to type) --%>
              <p class="text-base-content/50 text-sm font-medium uppercase tracking-wider mb-2">
                Type in Hangul
              </p>
              <p class="text-2xl font-bold text-base-content/80 mb-1">
                {@current_review.word.meaning}
              </p>
              <p class="text-sm text-base-content/40 mb-8 italic">
                {@current_review.word.romanization}
              </p>

              <%!-- Input Area --%>
              <div class="relative">
                <div
                  id="hangul-input-container"
                  phx-hook=".HangulInput"
                  phx-update="ignore"
                  data-state={@state}
                  data-answer={@current_review.word.hangul}
                  class="w-full"
                >
                  <input
                    type="text"
                    id="hangul-input"
                    autocomplete="off"
                    autocorrect="off"
                    autocapitalize="off"
                    spellcheck="false"
                    placeholder="한글을 입력하세요..."
                    class={[
                      "w-full text-center text-3xl font-semibold py-4 px-6 rounded-xl",
                      "bg-base-100 border-2 outline-none",
                      "transition-all duration-200",
                      "placeholder:text-base-content/20 placeholder:text-lg placeholder:font-normal",
                      "focus:ring-2 focus:ring-indigo-500/30 focus:border-indigo-500",
                      "border-base-300"
                    ]}
                  />
                </div>
              </div>
            </div>

            <%!-- Feedback --%>
            <%= if @state == :correct do %>
              <div class={[
                "w-full max-w-lg mb-6 p-5 rounded-xl text-center",
                "bg-emerald-500/10 border border-emerald-500/20",
                "animate-[fadeIn_0.3s_ease-out]"
              ]}>
                <div class="text-3xl mb-2">✅</div>
                <p class="font-semibold text-emerald-500 text-lg">Correct!</p>
                <p class="text-emerald-500/70 text-sm mt-1">{@current_review.word.hangul}</p>
              </div>

              <button
                id="next-btn"
                phx-click="next_word"
                class={[
                  "py-3 px-10 rounded-xl font-semibold",
                  "bg-gradient-to-r from-emerald-500 to-teal-600 text-white",
                  "hover:from-emerald-600 hover:to-teal-700",
                  "transform hover:scale-[1.02] active:scale-[0.98]",
                  "transition-all duration-200",
                  "shadow-lg shadow-emerald-500/25"
                ]}
              >
                Continue →
              </button>
            <% end %>

            <%= if @state == :incorrect do %>
              <div class={[
                "w-full max-w-lg mb-6 p-5 rounded-xl text-center",
                "bg-rose-500/10 border border-rose-500/20",
                "animate-[fadeIn_0.3s_ease-out]"
              ]}>
                <div class="text-3xl mb-2">❌</div>
                <p class="font-semibold text-rose-500 text-lg">Not quite</p>
                <p class="text-base-content/60 text-sm mt-1">
                  Correct answer: <span class="font-bold text-lg text-base-content/80">{@current_review.word.hangul}</span>
                </p>
              </div>

              <button
                id="next-btn"
                phx-click="next_word"
                class={[
                  "py-3 px-10 rounded-xl font-semibold",
                  "bg-gradient-to-r from-indigo-500 to-purple-600 text-white",
                  "hover:from-indigo-600 hover:to-purple-700",
                  "transform hover:scale-[1.02] active:scale-[0.98]",
                  "transition-all duration-200",
                  "shadow-lg shadow-indigo-500/25"
                ]}
              >
                Continue →
              </button>
            <% end %>
        <% end %>
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".HangulInput">
        // Korean Hangul Input Method Engine
        // Maps QWERTY keys to Korean jamo and composes syllable blocks

        // Consonant map (initial/final) - Standard Korean 2-set (두벌식) layout
        const CONSONANTS = {
          'q': 'ㅂ', 'w': 'ㅈ', 'e': 'ㄷ', 'r': 'ㄱ', 't': 'ㅅ',
          'a': 'ㅁ', 's': 'ㄴ', 'd': 'ㅇ', 'f': 'ㄹ',
          'g': 'ㅎ', 'z': 'ㅋ', 'x': 'ㅌ', 'c': 'ㅊ', 'v': 'ㅍ',
          // Shift consonants (double)
          'Q': 'ㅃ', 'W': 'ㅉ', 'E': 'ㄸ', 'R': 'ㄲ', 'T': 'ㅆ'
        };

        // Vowel map
        const VOWELS = {
          'y': 'ㅛ', 'u': 'ㅕ', 'i': 'ㅑ', 'o': 'ㅐ', 'p': 'ㅔ',
          'h': 'ㅗ', 'j': 'ㅓ', 'k': 'ㅏ', 'l': 'ㅣ',
          'b': 'ㅠ', 'n': 'ㅜ', 'm': 'ㅡ',
          'O': 'ㅒ', 'P': 'ㅖ'
        };

        // Choseong (initial consonant) codes
        const CHOSEONG = ['ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ','ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];
        // Jungseong (medial vowel) codes
        const JUNGSEONG = ['ㅏ','ㅐ','ㅑ','ㅒ','ㅓ','ㅔ','ㅕ','ㅖ','ㅗ','ㅘ','ㅙ','ㅚ','ㅛ','ㅜ','ㅝ','ㅞ','ㅟ','ㅠ','ㅡ','ㅢ','ㅣ'];
        // Jongseong (final consonant) codes - 0 index is no final consonant
        const JONGSEONG = ['','ㄱ','ㄲ','ㄳ','ㄴ','ㄵ','ㄶ','ㄷ','ㄹ','ㄺ','ㄻ','ㄼ','ㄽ','ㄾ','ㄿ','ㅀ','ㅁ','ㅂ','ㅄ','ㅅ','ㅆ','ㅇ','ㅈ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];

        // Compound vowels
        const COMPOUND_VOWELS = {
          'ㅗㅏ': 'ㅘ', 'ㅗㅐ': 'ㅙ', 'ㅗㅣ': 'ㅚ',
          'ㅜㅓ': 'ㅝ', 'ㅜㅔ': 'ㅞ', 'ㅜㅣ': 'ㅟ',
          'ㅡㅣ': 'ㅢ'
        };

        // Compound final consonants
        const COMPOUND_JONGSEONG = {
          'ㄱㅅ': 'ㄳ', 'ㄴㅈ': 'ㄵ', 'ㄴㅎ': 'ㄶ',
          'ㄹㄱ': 'ㄺ', 'ㄹㅁ': 'ㄻ', 'ㄹㅂ': 'ㄼ',
          'ㄹㅅ': 'ㄽ', 'ㄹㅌ': 'ㄾ', 'ㄹㅍ': 'ㄿ',
          'ㄹㅎ': 'ㅀ', 'ㅂㅅ': 'ㅄ'
        };

        // Decompose compound jongseong for when a vowel follows
        const DECOMPOSE_JONGSEONG = {
          'ㄳ': ['ㄱ', 'ㅅ'], 'ㄵ': ['ㄴ', 'ㅈ'], 'ㄶ': ['ㄴ', 'ㅎ'],
          'ㄺ': ['ㄹ', 'ㄱ'], 'ㄻ': ['ㄹ', 'ㅁ'], 'ㄼ': ['ㄹ', 'ㅂ'],
          'ㄽ': ['ㄹ', 'ㅅ'], 'ㄾ': ['ㄹ', 'ㅌ'], 'ㄿ': ['ㄹ', 'ㅍ'],
          'ㅀ': ['ㄹ', 'ㅎ'], 'ㅄ': ['ㅂ', 'ㅅ']
        };

        function isConsonant(ch) { return CHOSEONG.includes(ch) || ['ㄲ','ㄸ','ㅃ','ㅆ','ㅉ'].includes(ch); }
        function isVowel(ch) { return JUNGSEONG.includes(ch); }

        function compose(cho, jung, jong) {
          let choIdx = CHOSEONG.indexOf(cho);
          let jungIdx = JUNGSEONG.indexOf(jung);
          let jongIdx = jong ? JONGSEONG.indexOf(jong) : 0;
          if (choIdx < 0 || jungIdx < 0 || jongIdx < 0) return null;
          return String.fromCharCode(0xAC00 + choIdx * 21 * 28 + jungIdx * 28 + jongIdx);
        }

        export default {
          mounted() {
            this.buffer = []; // jamo buffer for current syllable
            this.committed = ""; // completed text
            this.input = this.el.querySelector("#hangul-input");

            this.input.addEventListener("keydown", (e) => {
              // Allow navigation and special keys
              if (e.ctrlKey || e.metaKey || e.altKey) return;

              if (e.key === "Enter") {
                e.preventDefault();
                const fullValue = this.committed + this.getComposing();
                if (fullValue.length > 0) {
                  this.pushEvent("submit_answer", { value: fullValue });
                }
                return;
              }

              if (e.key === "Backspace") {
                e.preventDefault();
                if (this.buffer.length > 0) {
                  this.buffer.pop();
                } else if (this.committed.length > 0) {
                  // Remove last character and decompose it back to buffer
                  this.committed = this.committed.slice(0, -1);
                }
                this.updateDisplay();
                return;
              }

              // Check if this key maps to a Korean character
              const key = e.key;
              const consonant = CONSONANTS[key];
              const vowel = VOWELS[key];

              if (!consonant && !vowel) {
                // Not a mappable key, ignore
                if (key.length === 1) e.preventDefault();
                return;
              }

              e.preventDefault();

              if (consonant) {
                this.addJamo(consonant, 'consonant');
              } else if (vowel) {
                this.addJamo(vowel, 'vowel');
              }

              this.updateDisplay();
            });

            // Prevent direct input
            this.input.addEventListener("input", (e) => {
              e.preventDefault();
              this.updateDisplay();
            });

            this.input.focus();

            // Refocus when state changes
            this.handleEvent("refocus", () => {
              this.reset();
              this.input.focus();
            });
          },

          updated() {
            const state = this.el.dataset.state;
            if (state === "typing") {
              this.reset();
              this.input.focus();
            }
          },

          addJamo(jamo, type) {
            if (type === 'consonant') {
              if (this.buffer.length === 0) {
                // Start new syllable with consonant (choseong)
                this.buffer.push(jamo);
              } else if (this.buffer.length === 1 && isConsonant(this.buffer[0])) {
                // We have a choseong, this could be a double consonant... no, commit and start new
                // Actually: if buffer is just a consonant with no vowel, commit it and start new
                this.committed += this.buffer[0];
                this.buffer = [jamo];
              } else if (this.buffer.length === 2 && isConsonant(this.buffer[0]) && isVowel(this.buffer[1])) {
                // We have cho+jung, this consonant could be jongseong
                if (JONGSEONG.includes(jamo)) {
                  this.buffer.push(jamo);
                } else {
                  // Can't be jongseong, commit current and start new
                  this.committed += compose(this.buffer[0], this.buffer[1], null);
                  this.buffer = [jamo];
                }
              } else if (this.buffer.length === 3) {
                // We have cho+jung+jong, try compound jongseong
                let compound = COMPOUND_JONGSEONG[this.buffer[2] + jamo];
                if (compound) {
                  this.buffer[2] = compound;
                } else {
                  // Commit current syllable and start new
                  this.committed += compose(this.buffer[0], this.buffer[1], this.buffer[2]);
                  this.buffer = [jamo];
                }
              } else {
                // Fallback: commit current composing and start fresh
                this.committed += this.getComposing();
                this.buffer = [jamo];
              }
            } else if (type === 'vowel') {
              if (this.buffer.length === 0) {
                // Vowel without consonant - just add it (like ㅏ standalone)
                // In Korean, standalone vowels use ㅇ as placeholder
                this.committed += compose('ㅇ', jamo, null) || jamo;
              } else if (this.buffer.length === 1 && isConsonant(this.buffer[0])) {
                // We have a choseong, add vowel as jungseong
                this.buffer.push(jamo);
              } else if (this.buffer.length === 2 && isConsonant(this.buffer[0]) && isVowel(this.buffer[1])) {
                // Try compound vowel
                let compound = COMPOUND_VOWELS[this.buffer[1] + jamo];
                if (compound) {
                  this.buffer[1] = compound;
                } else {
                  // Commit current and start new with ㅇ+vowel
                  this.committed += compose(this.buffer[0], this.buffer[1], null);
                  this.buffer = [];
                  this.committed += compose('ㅇ', jamo, null) || jamo;
                }
              } else if (this.buffer.length === 3) {
                // We have cho+jung+jong, vowel after jongseong means:
                // the jongseong becomes choseong of new syllable
                let jong = this.buffer[2];
                let decomposed = DECOMPOSE_JONGSEONG[jong];

                if (decomposed) {
                  // Compound jongseong: first part stays, second becomes new choseong
                  this.committed += compose(this.buffer[0], this.buffer[1], decomposed[0]);
                  this.buffer = [decomposed[1], jamo];
                } else {
                  // Simple jongseong becomes new choseong
                  this.committed += compose(this.buffer[0], this.buffer[1], null);
                  this.buffer = [jong, jamo];
                }
              } else {
                this.committed += this.getComposing();
                this.buffer = [];
                this.committed += compose('ㅇ', jamo, null) || jamo;
              }
            }
          },

          getComposing() {
            if (this.buffer.length === 0) return "";
            if (this.buffer.length === 1) return this.buffer[0];
            if (this.buffer.length === 2 && isConsonant(this.buffer[0]) && isVowel(this.buffer[1])) {
              return compose(this.buffer[0], this.buffer[1], null) || this.buffer.join('');
            }
            if (this.buffer.length === 3) {
              return compose(this.buffer[0], this.buffer[1], this.buffer[2]) || this.buffer.join('');
            }
            return this.buffer.join('');
          },

          updateDisplay() {
            const composing = this.getComposing();
            this.input.value = this.committed + composing;
            // Push current value to server for live feedback
            this.pushEvent("hangul_input", { value: this.input.value });
          },

          reset() {
            this.buffer = [];
            this.committed = "";
            if (this.input) {
              this.input.value = "";
            }
          }
        }
      </script>
    </Layouts.app>
    """
  end
end
