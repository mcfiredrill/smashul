# Script for populating the database with Korean words.
#
# Run with: mix run priv/repo/seeds.exs

alias Smashul.Repo
alias Smashul.Dictionary.Word

import Ecto.Query

# Only seed if no words exist
if Repo.aggregate(Word, :count) == 0 do
  words = [
    # Level 1: Basic Greetings & Essential Words
    %{hangul: "안녕", romanization: "annyeong", meaning: "hello (casual)", level: 1},
    %{hangul: "네", romanization: "ne", meaning: "yes", level: 1},
    %{hangul: "아니요", romanization: "aniyo", meaning: "no", level: 1},
    %{hangul: "감사", romanization: "gamsa", meaning: "thanks", level: 1},
    %{hangul: "사랑", romanization: "sarang", meaning: "love", level: 1},
    %{hangul: "물", romanization: "mul", meaning: "water", level: 1},
    %{hangul: "밥", romanization: "bap", meaning: "rice/meal", level: 1},
    %{hangul: "집", romanization: "jip", meaning: "house", level: 1},
    %{hangul: "나", romanization: "na", meaning: "I/me", level: 1},
    %{hangul: "너", romanization: "neo", meaning: "you", level: 1},

    # Level 2: Numbers & Basic Nouns
    %{hangul: "하나", romanization: "hana", meaning: "one", level: 2},
    %{hangul: "둘", romanization: "dul", meaning: "two", level: 2},
    %{hangul: "셋", romanization: "set", meaning: "three", level: 2},
    %{hangul: "넷", romanization: "net", meaning: "four", level: 2},
    %{hangul: "다섯", romanization: "daseot", meaning: "five", level: 2},
    %{hangul: "사람", romanization: "saram", meaning: "person", level: 2},
    %{hangul: "친구", romanization: "chingu", meaning: "friend", level: 2},
    %{hangul: "학교", romanization: "hakgyo", meaning: "school", level: 2},
    %{hangul: "책", romanization: "chaek", meaning: "book", level: 2},
    %{hangul: "선생님", romanization: "seonsaengnim", meaning: "teacher", level: 2},

    # Level 3: Colors & Adjectives
    %{hangul: "빨간", romanization: "ppalgan", meaning: "red", level: 3},
    %{hangul: "파란", romanization: "paran", meaning: "blue", level: 3},
    %{hangul: "노란", romanization: "noran", meaning: "yellow", level: 3},
    %{hangul: "하얀", romanization: "hayan", meaning: "white", level: 3},
    %{hangul: "검은", romanization: "geomeun", meaning: "black", level: 3},
    %{hangul: "큰", romanization: "keun", meaning: "big", level: 3},
    %{hangul: "작은", romanization: "jageun", meaning: "small", level: 3},
    %{hangul: "좋은", romanization: "joeun", meaning: "good", level: 3},
    %{hangul: "나쁜", romanization: "nappeun", meaning: "bad", level: 3},
    %{hangul: "예쁜", romanization: "yeppeun", meaning: "pretty", level: 3},

    # Level 4: Food & Drink
    %{hangul: "김치", romanization: "gimchi", meaning: "kimchi", level: 4},
    %{hangul: "고기", romanization: "gogi", meaning: "meat", level: 4},
    %{hangul: "과일", romanization: "gwail", meaning: "fruit", level: 4},
    %{hangul: "우유", romanization: "uyu", meaning: "milk", level: 4},
    %{hangul: "커피", romanization: "keopi", meaning: "coffee", level: 4},
    %{hangul: "빵", romanization: "ppang", meaning: "bread", level: 4},
    %{hangul: "라면", romanization: "ramyeon", meaning: "ramen", level: 4},
    %{hangul: "사과", romanization: "sagwa", meaning: "apple", level: 4},
    %{hangul: "치킨", romanization: "chikin", meaning: "chicken", level: 4},
    %{hangul: "맥주", romanization: "maekju", meaning: "beer", level: 4},

    # Level 5: Family & People
    %{hangul: "가족", romanization: "gajok", meaning: "family", level: 5},
    %{hangul: "엄마", romanization: "eomma", meaning: "mom", level: 5},
    %{hangul: "아빠", romanization: "appa", meaning: "dad", level: 5},
    %{hangul: "형", romanization: "hyeong", meaning: "older brother (male)", level: 5},
    %{hangul: "언니", romanization: "eonni", meaning: "older sister (female)", level: 5},
    %{hangul: "동생", romanization: "dongsaeng", meaning: "younger sibling", level: 5},
    %{hangul: "아이", romanization: "ai", meaning: "child", level: 5},
    %{hangul: "남자", romanization: "namja", meaning: "man", level: 5},
    %{hangul: "여자", romanization: "yeoja", meaning: "woman", level: 5},
    %{hangul: "아기", romanization: "agi", meaning: "baby", level: 5},

    # Level 6: Common Verbs
    %{hangul: "가다", romanization: "gada", meaning: "to go", level: 6},
    %{hangul: "오다", romanization: "oda", meaning: "to come", level: 6},
    %{hangul: "먹다", romanization: "meokda", meaning: "to eat", level: 6},
    %{hangul: "마시다", romanization: "masida", meaning: "to drink", level: 6},
    %{hangul: "보다", romanization: "boda", meaning: "to see", level: 6},
    %{hangul: "하다", romanization: "hada", meaning: "to do", level: 6},
    %{hangul: "읽다", romanization: "ikda", meaning: "to read", level: 6},
    %{hangul: "쓰다", romanization: "sseuda", meaning: "to write", level: 6},
    %{hangul: "자다", romanization: "jada", meaning: "to sleep", level: 6},
    %{hangul: "걷다", romanization: "geotda", meaning: "to walk", level: 6},

    # Level 7: Places & Locations
    %{hangul: "병원", romanization: "byeongwon", meaning: "hospital", level: 7},
    %{hangul: "은행", romanization: "eunhaeng", meaning: "bank", level: 7},
    %{hangul: "공원", romanization: "gongwon", meaning: "park", level: 7},
    %{hangul: "시장", romanization: "sijang", meaning: "market", level: 7},
    %{hangul: "식당", romanization: "sikdang", meaning: "restaurant", level: 7},
    %{hangul: "역", romanization: "yeok", meaning: "station", level: 7},
    %{hangul: "호텔", romanization: "hotel", meaning: "hotel", level: 7},
    %{hangul: "도서관", romanization: "doseogwan", meaning: "library", level: 7},
    %{hangul: "카페", romanization: "kape", meaning: "cafe", level: 7},
    %{hangul: "공항", romanization: "gonghang", meaning: "airport", level: 7},

    # Level 8: Time & Days
    %{hangul: "오늘", romanization: "oneul", meaning: "today", level: 8},
    %{hangul: "내일", romanization: "naeil", meaning: "tomorrow", level: 8},
    %{hangul: "어제", romanization: "eoje", meaning: "yesterday", level: 8},
    %{hangul: "월요일", romanization: "woryoil", meaning: "Monday", level: 8},
    %{hangul: "지금", romanization: "jigeum", meaning: "now", level: 8},
    %{hangul: "아침", romanization: "achim", meaning: "morning", level: 8},
    %{hangul: "저녁", romanization: "jeonyeok", meaning: "evening", level: 8},
    %{hangul: "시간", romanization: "sigan", meaning: "time", level: 8},
    %{hangul: "주말", romanization: "jumal", meaning: "weekend", level: 8},
    %{hangul: "매일", romanization: "maeil", meaning: "every day", level: 8},

    # Level 9: Body & Health
    %{hangul: "머리", romanization: "meori", meaning: "head/hair", level: 9},
    %{hangul: "눈", romanization: "nun", meaning: "eye/snow", level: 9},
    %{hangul: "입", romanization: "ip", meaning: "mouth", level: 9},
    %{hangul: "손", romanization: "son", meaning: "hand", level: 9},
    %{hangul: "발", romanization: "bal", meaning: "foot", level: 9},
    %{hangul: "마음", romanization: "maeum", meaning: "heart/mind", level: 9},
    %{hangul: "건강", romanization: "geongang", meaning: "health", level: 9},
    %{hangul: "운동", romanization: "undong", meaning: "exercise", level: 9},
    %{hangul: "약", romanization: "yak", meaning: "medicine", level: 9},
    %{hangul: "아프다", romanization: "apeuda", meaning: "to hurt/sick", level: 9},

    # Level 10: Weather & Nature
    %{hangul: "날씨", romanization: "nalssi", meaning: "weather", level: 10},
    %{hangul: "비", romanization: "bi", meaning: "rain", level: 10},
    %{hangul: "바람", romanization: "baram", meaning: "wind", level: 10},
    %{hangul: "하늘", romanization: "haneul", meaning: "sky", level: 10},
    %{hangul: "산", romanization: "san", meaning: "mountain", level: 10},
    %{hangul: "바다", romanization: "bada", meaning: "sea", level: 10},
    %{hangul: "꽃", romanization: "kkot", meaning: "flower", level: 10},
    %{hangul: "나무", romanization: "namu", meaning: "tree", level: 10},
    %{hangul: "별", romanization: "byeol", meaning: "star", level: 10},
    %{hangul: "달", romanization: "dal", meaning: "moon", level: 10},

    # Level 11: Common Phrases
    %{hangul: "괜찮다", romanization: "gwaenchanta", meaning: "to be okay", level: 11},
    %{hangul: "필요하다", romanization: "piryohada", meaning: "to need", level: 11},
    %{hangul: "알다", romanization: "alda", meaning: "to know", level: 11},
    %{hangul: "모르다", romanization: "moreuda", meaning: "to not know", level: 11},
    %{hangul: "생각하다", romanization: "saenggakhada", meaning: "to think", level: 11},
    %{hangul: "기다리다", romanization: "gidarida", meaning: "to wait", level: 11},
    %{hangul: "만나다", romanization: "mannada", meaning: "to meet", level: 11},
    %{hangul: "시작하다", romanization: "sijakhada", meaning: "to start", level: 11},
    %{hangul: "끝나다", romanization: "kkeutnada", meaning: "to end", level: 11},
    %{hangul: "도착하다", romanization: "dochakhada", meaning: "to arrive", level: 11},

    # Level 12: Emotions & Feelings
    %{hangul: "행복하다", romanization: "haengbokhada", meaning: "to be happy", level: 12},
    %{hangul: "슬프다", romanization: "seulpeuda", meaning: "to be sad", level: 12},
    %{hangul: "화나다", romanization: "hwanada", meaning: "to be angry", level: 12},
    %{hangul: "무섭다", romanization: "museopda", meaning: "to be scary", level: 12},
    %{hangul: "재미있다", romanization: "jaemiitda", meaning: "to be fun", level: 12},
    %{hangul: "지루하다", romanization: "jiruhada", meaning: "to be boring", level: 12},
    %{hangul: "피곤하다", romanization: "pigonhada", meaning: "to be tired", level: 12},
    %{hangul: "배고프다", romanization: "baegopeda", meaning: "to be hungry", level: 12},
    %{hangul: "걱정하다", romanization: "geokjeonghada", meaning: "to worry", level: 12},
    %{hangul: "외롭다", romanization: "oeropda", meaning: "to be lonely", level: 12},

    # Level 13: Travel & Transport
    %{hangul: "여행", romanization: "yeohaeng", meaning: "travel", level: 13},
    %{hangul: "비행기", romanization: "bihaenggi", meaning: "airplane", level: 13},
    %{hangul: "지하철", romanization: "jihacheol", meaning: "subway", level: 13},
    %{hangul: "버스", romanization: "beoseu", meaning: "bus", level: 13},
    %{hangul: "택시", romanization: "taeksi", meaning: "taxi", level: 13},
    %{hangul: "자동차", romanization: "jadongcha", meaning: "car", level: 13},
    %{hangul: "표", romanization: "pyo", meaning: "ticket", level: 13},
    %{hangul: "짐", romanization: "jim", meaning: "luggage", level: 13},
    %{hangul: "지도", romanization: "jido", meaning: "map", level: 13},
    %{hangul: "여권", romanization: "yeogwon", meaning: "passport", level: 13},

    # Level 14: Shopping & Money
    %{hangul: "돈", romanization: "don", meaning: "money", level: 14},
    %{hangul: "가격", romanization: "gagyeok", meaning: "price", level: 14},
    %{hangul: "싸다", romanization: "ssada", meaning: "to be cheap", level: 14},
    %{hangul: "비싸다", romanization: "bissada", meaning: "to be expensive", level: 14},
    %{hangul: "신용카드", romanization: "sinyongkadeu", meaning: "credit card", level: 14},
    %{hangul: "영수증", romanization: "yeongsujeung", meaning: "receipt", level: 14},
    %{hangul: "할인", romanization: "halin", meaning: "discount", level: 14},
    %{hangul: "선물", romanization: "seonmul", meaning: "gift", level: 14},
    %{hangul: "계산", romanization: "gyesan", meaning: "calculation/bill", level: 14},
    %{hangul: "교환", romanization: "gyohwan", meaning: "exchange", level: 14},

    # Level 15: Work & Education
    %{hangul: "회사", romanization: "hoesa", meaning: "company", level: 15},
    %{hangul: "직업", romanization: "jigeop", meaning: "job/occupation", level: 15},
    %{hangul: "회의", romanization: "hoeui", meaning: "meeting", level: 15},
    %{hangul: "대학교", romanization: "daehakgyo", meaning: "university", level: 15},
    %{hangul: "시험", romanization: "siheom", meaning: "exam", level: 15},
    %{hangul: "숙제", romanization: "sukje", meaning: "homework", level: 15},
    %{hangul: "졸업", romanization: "joreop", meaning: "graduation", level: 15},
    %{hangul: "연구", romanization: "yeongu", meaning: "research", level: 15},
    %{hangul: "발표", romanization: "balpyo", meaning: "presentation", level: 15},
    %{hangul: "프로젝트", romanization: "peurojekteu", meaning: "project", level: 15},

    # Level 16: Technology
    %{hangul: "컴퓨터", romanization: "keompyuteo", meaning: "computer", level: 16},
    %{hangul: "휴대폰", romanization: "hyudaepon", meaning: "cell phone", level: 16},
    %{hangul: "인터넷", romanization: "inteonet", meaning: "internet", level: 16},
    %{hangul: "이메일", romanization: "imeil", meaning: "email", level: 16},
    %{hangul: "비밀번호", romanization: "bimilbeonho", meaning: "password", level: 16},
    %{hangul: "프로그램", romanization: "peurogeuraem", meaning: "program", level: 16},
    %{hangul: "웹사이트", romanization: "wepsaiteu", meaning: "website", level: 16},
    %{hangul: "다운로드", romanization: "daunrodeu", meaning: "download", level: 16},
    %{hangul: "검색", romanization: "geomsaek", meaning: "search", level: 16},
    %{hangul: "화면", romanization: "hwamyeon", meaning: "screen", level: 16},

    # Level 17: Culture & Entertainment
    %{hangul: "영화", romanization: "yeonghwa", meaning: "movie", level: 17},
    %{hangul: "음악", romanization: "eumak", meaning: "music", level: 17},
    %{hangul: "노래", romanization: "norae", meaning: "song", level: 17},
    %{hangul: "드라마", romanization: "deurama", meaning: "drama", level: 17},
    %{hangul: "게임", romanization: "geim", meaning: "game", level: 17},
    %{hangul: "축구", romanization: "chukgu", meaning: "soccer", level: 17},
    %{hangul: "사진", romanization: "sajin", meaning: "photo", level: 17},
    %{hangul: "공연", romanization: "gongyeon", meaning: "performance", level: 17},
    %{hangul: "미술관", romanization: "misulgwan", meaning: "art gallery", level: 17},
    %{hangul: "콘서트", romanization: "konseoteu", meaning: "concert", level: 17},

    # Level 18: Abstract Concepts
    %{hangul: "경험", romanization: "gyeongheom", meaning: "experience", level: 18},
    %{hangul: "문화", romanization: "munhwa", meaning: "culture", level: 18},
    %{hangul: "역사", romanization: "yeoksa", meaning: "history", level: 18},
    %{hangul: "정치", romanization: "jeongchi", meaning: "politics", level: 18},
    %{hangul: "경제", romanization: "gyeongje", meaning: "economy", level: 18},
    %{hangul: "사회", romanization: "sahoe", meaning: "society", level: 18},
    %{hangul: "환경", romanization: "hwangyeong", meaning: "environment", level: 18},
    %{hangul: "교육", romanization: "gyoyuk", meaning: "education", level: 18},
    %{hangul: "자유", romanization: "jayu", meaning: "freedom", level: 18},
    %{hangul: "평화", romanization: "pyeonghwa", meaning: "peace", level: 18},

    # Level 19: Advanced Vocabulary
    %{hangul: "성취감", romanization: "seongchwigam", meaning: "sense of achievement", level: 19},
    %{hangul: "도전", romanization: "dojeon", meaning: "challenge", level: 19},
    %{hangul: "창의적", romanization: "changuijeok", meaning: "creative", level: 19},
    %{hangul: "효율적", romanization: "hyoyuljeok", meaning: "efficient", level: 19},
    %{hangul: "책임감", romanization: "chaegimgam", meaning: "responsibility", level: 19},
    %{hangul: "의사소통", romanization: "uisasotong", meaning: "communication", level: 19},
    %{hangul: "긍정적", romanization: "geungjeongjeok", meaning: "positive", level: 19},
    %{hangul: "부정적", romanization: "bujeongjeok", meaning: "negative", level: 19},
    %{hangul: "독립적", romanization: "dongnipjeok", meaning: "independent", level: 19},
    %{hangul: "전통적", romanization: "jeontongjeok", meaning: "traditional", level: 19},

    # Level 20: Complex Expressions
    %{hangul: "감사합니다", romanization: "gamsahamnida", meaning: "thank you (formal)", level: 20},
    %{hangul: "안녕하세요", romanization: "annyeonghaseyo", meaning: "hello (formal)", level: 20},
    %{hangul: "죄송합니다", romanization: "joesonghamnida", meaning: "I'm sorry (formal)", level: 20},
    %{hangul: "실례합니다", romanization: "sillyehamnida", meaning: "excuse me (formal)", level: 20},
    %{hangul: "처음 뵙겠습니다", romanization: "cheoeum boepgesseumnida", meaning: "nice to meet you", level: 20},
    %{hangul: "잘 부탁드립니다", romanization: "jal butakdeurimnida", meaning: "please take care of me", level: 20},
    %{hangul: "수고하셨습니다", romanization: "sugohasyeosseumnida", meaning: "good work (formal)", level: 20},
    %{hangul: "맛있게 드세요", romanization: "masitge deuseyo", meaning: "enjoy your meal", level: 20},
    %{hangul: "다녀오겠습니다", romanization: "danyeoogesseumnida", meaning: "I'll be back", level: 20},
    %{hangul: "건강하세요", romanization: "geonganghaseyo", meaning: "stay healthy", level: 20}
  ]

  for word_attrs <- words do
    %Word{}
    |> Word.changeset(word_attrs)
    |> Repo.insert!()
  end

  IO.puts("Seeded #{length(words)} Korean words across 20 levels.")
else
  IO.puts("Words already exist, skipping seed.")
end
