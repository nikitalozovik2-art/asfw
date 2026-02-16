import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import "../components"

Item {
  id: root
  Layout.fillWidth: true
  Layout.fillHeight: true

  property string uiFont: "Segoe UI Variable Text"

// Modal dispatcher (в Training только одно активное окно)
readonly property int modalNone: 0
readonly property int modalMuscle: 1
readonly property int modalExercises: 2
readonly property int modalTechnique: 3
property int modalState: modalNone

function closeAllTrainingModals() {
  if (musclePicker && musclePicker.visible) musclePicker.close()
  if (editExercisesDialog && editExercisesDialog.visible) editExercisesDialog.close()
  if (techniquePopup && techniquePopup.visible) techniquePopup.close()
  modalState = modalNone
}

function openMusclePicker() {
  closeAllTrainingModals()
  syncTemplateFromSelectedWeek()
  modalState = modalMuscle
  musclePicker.open()
}

function openExercisesDialog() {
  closeAllTrainingModals()
  syncTemplateFromSelectedWeek()
  modalState = modalExercises
  editExercisesDialog.open()
}

function openTechniqueModal() {
  closeAllTrainingModals()
  modalState = modalTechnique
  root.openTechniqueModal()
}

  // Exercises data + completion tracking

  // =========================
  // Days model (архитектура)
  // =========================
  // Важно: сейчас тщательно доводим Day 1. Остальные дни — заготовки (будем шлифовать по очереди).
  property var days: [
    {
      key: "day1",
      tab: "День 1 · Грудь",
      title: "День 1 · Грудь",
      subtitle: "Тяжелый жим + верх груди",
      accent: "#FF6B7A",
      mode: "strength",
      totalRepsText: "160+",
      timeText: "40 мин",

      focusTag: "Сила",
      exercises: [
        { id: "bench_0", title: "Жим штанги лёжа 0", sub: "468  ·  2:30  ·  47.5 кг", tag: "Основное", sets: 4 },
        { id: "incline_30", title: "Жим штанги наклон 30", sub: "3610  ·  2:00", tag: "Верх груди", sets: 3 },
        { id: "db_neutral", title: "Жим гантелей лёжа (neutral)", sub: "3812  ·  1:30", tag: "Памп", sets: 4 },
        { id: "flyes", title: "Разводка гантелей", sub: "3215  ·  1:30", tag: "Памп", sets: 4 }
      ]
    },
    {
      key: "day2",
      tab: "День 2 · Спина",
      title: "День 2 · Спина",
      subtitle: "Тяга + широчайшие",
      accent: "#4FC3F7",
      mode: "strength",
      totalRepsText: "120+",
      timeText: "35 мин",

      focusTag: "Тяга",
      exercises: [
        { id: "row_main", title: "Тяга штанги в наклоне", sub: "—  ·  2:00", tag: "Основное", sets: 4 },
        { id: "pulldown", title: "Тяга верхнего блока", sub: "—  ·  1:45", tag: "Верх спины", sets: 3 }
      ]
    },
    {
      key: "day3",
      tab: "День 3 · Плечи",
      title: "День 3 · Плечи",
      subtitle: "Жим + дельты",
      accent: "#8E7BFF",
      mode: "strength",
      totalRepsText: "90+",
      timeText: "30 мин",

      focusTag: "Плечи",
      exercises: [
        { id: "ohp", title: "Жим стоя (OHP)", sub: "—  ·  2:00", tag: "Основное", sets: 4 }
      ]
    },
    {
      key: "day4",
      tab: "День 4 · Руки",
      title: "День 4 · Руки",
      subtitle: "Бицепс + трицепс",
      accent: "#FF7BD7",
      mode: "strength",
      totalRepsText: "80+",
      timeText: "25 мин",

      focusTag: "Руки",
      exercises: [
        { id: "curl", title: "Сгибания на бицепс", sub: "—  ·  1:30", tag: "Памп", sets: 3 }
      ]
    },
    {
      key: "day5",
      tab: "День 5 · Техника",
      title: "День 5 · Техника",
      subtitle: "Разбор техники",
      accent: "#53D769",
      mode: "technique",
      totalRepsText: "—",
      timeText: "—",

      focusTag: "Техника",
      exercises: [
        { id: "tech_guide", title: "Техника: база", sub: "гайд  ·  чек-листы", tag: "Гайд", sets: 1 }
      ]
    }
  ]

  
  // =============================
  // НЕДЕЛЬНЫЙ ПЛАН (Пн–Вс)
  // =============================
  property int selectedWeekIndex: 0
  // completion/progress should be tracked per weekday (Пн–Вс), not per template workout
  property int doneDayKey: selectedWeekIndex
  property string selectedMuscleKey: "rest"
  property int selectedMuscleRev: 0
  onSelectedWeekIndexChanged: {
    syncTemplateFromSelectedWeek()
    exercisesRevision++
  }   // 0..6 (Пн..Вс)
  ListModel { id: weekModel }         // элементы: { enabled, muscleKey, muscleTitle, accent, dateText, weekdayText, weekdayShort }

    property var muscleGroups: [
    { key: "chest",     title: "Грудь",    accent: "#FF6B7A", templateIndex: 0 },
    { key: "back",      title: "Спина",    accent: "#4D9AFF", templateIndex: 1 },
    { key: "shoulders", title: "Плечи",   accent: "#7C5CFF", templateIndex: 2 },
    { key: "arms",      title: "Руки",    accent: "#FFB84D", templateIndex: 3 },
    { key: "legs",      title: "Ноги",    accent: "#2AD1A3", templateIndex: -1 },
    { key: "abs",      title: "Пресс",   accent: "#FF5DAA", templateIndex: -1 },
    { key: "cardio",    title: "Кардио",  accent: "#38C3FF", templateIndex: -1 },
    { key: "technique", title: "Техника", accent: "#9AA6B2", templateIndex: 4 },
    { key: "rest",      title: "Отдых",   accent: "#C9D3DF", templateIndex: -1 }
  ]


// ----- Week plan: base exercises (stub) + helpers -----
    // Later you can replace this map with your real DB / backend.
      // ----- Week plan: база упражнений по группам мышц -----
  // Объекты в формате, который ожидает UI: { id, title, sub, tag, sets }
  // Для грудь/спина/плечи/руки/техника — берём шаблоны day1..day5 (см. _defaultExercisesForKey).
  // Для остальных групп — здесь ручная база.
  
  // Большая библиотека упражнений (база)
  // Каждый элемент: id, title, sets, reps, rest, sub (опционально), tag (опционально)
  property var baseExercisesByMuscle: ({
    "chest": [
      { "id": "bench_bar",      "title": "Жим штанги лёжа",                "sets": 4, "reps": "6–10",  "rest": 90,  "sub": "Классика • сила", "tag": "base" },
      { "id": "bench_dumb",     "title": "Жим гантелей лёжа",              "sets": 4, "reps": "8–12",  "rest": 75,  "sub": "Контроль амплитуды", "tag": "hypertrophy" },
      { "id": "incline_bar",    "title": "Жим штанги наклон",              "sets": 4, "reps": "6–10",  "rest": 90,  "sub": "Верх груди", "tag": "base" },
      { "id": "incline_dumb",   "title": "Жим гантелей наклон",            "sets": 3, "reps": "10–12", "rest": 75,  "sub": "Верх груди", "tag": "hypertrophy" },
      { "id": "machine_press",  "title": "Жим в тренажёре",                "sets": 3, "reps": "10–15", "rest": 60,  "sub": "Стабильно и безопасно" },
      { "id": "pushups",        "title": "Отжимания",                      "sets": 3, "reps": "макс",  "rest": 60,  "sub": "Вес тела" },
      { "id": "dips",           "title": "Отжимания на брусьях",           "sets": 3, "reps": "6–12",  "rest": 90,  "sub": "Грудь/трицепс", "tag": "base" },
      { "id": "cable_fly",      "title": "Кроссовер (сведение рук)",       "sets": 3, "reps": "12–15", "rest": 45,  "sub": "Памп" },
      { "id": "dumb_fly",       "title": "Разводка гантелей",              "sets": 3, "reps": "12–15", "rest": 45,  "sub": "Растяжение" },
      { "id": "pullover",       "title": "Пуловер",                        "sets": 3, "reps": "10–12", "rest": 60,  "sub": "Грудь/широчайшие" }
    ],
    "back": [
      { "id": "pullups",        "title": "Подтягивания",                   "sets": 4, "reps": "макс",  "rest": 90,  "sub": "Широчайшие", "tag": "base" },
      { "id": "lat_pulldown",   "title": "Тяга верхнего блока",             "sets": 4, "reps": "8–12",  "rest": 75,  "sub": "Ширина спины" },
      { "id": "barbell_row",    "title": "Тяга штанги в наклоне",           "sets": 4, "reps": "6–10",  "rest": 90,  "sub": "Толщина", "tag": "base" },
      { "id": "dumb_row",       "title": "Тяга гантели одной рукой",        "sets": 3, "reps": "10–12", "rest": 75,  "sub": "Контроль" },
      { "id": "seated_row",     "title": "Тяга горизонтального блока",      "sets": 3, "reps": "10–12", "rest": 75,  "sub": "Середина спины" },
      { "id": "tbar_row",       "title": "Тяга T‑грифа",                    "sets": 3, "reps": "8–10",  "rest": 90,  "sub": "Толщина" },
      { "id": "face_pull",      "title": "Тяга каната к лицу (Face Pull)",  "sets": 3, "reps": "12–15", "rest": 45,  "sub": "Задняя дельта/осанка" },
      { "id": "hyperext",       "title": "Гиперэкстензия",                  "sets": 3, "reps": "12–15", "rest": 60,  "sub": "Поясница" },
      { "id": "shrugs",         "title": "Шраги",                           "sets": 3, "reps": "10–15", "rest": 60,  "sub": "Трапеции" },
      { "id": "pullover_cable", "title": "Пуловер в блоке",                 "sets": 3, "reps": "12–15", "rest": 45,  "sub": "Широчайшие" }
    ],
    "shoulders": [
      { "id": "ohp_bar",        "title": "Жим штанги стоя (OHP)",           "sets": 4, "reps": "5–8",   "rest": 90,  "sub": "Сила", "tag": "base" },
      { "id": "ohp_dumb",       "title": "Жим гантелей сидя",               "sets": 4, "reps": "8–10",  "rest": 75,  "sub": "Контроль" },
      { "id": "lateral_raise",  "title": "Подъёмы в стороны",              "sets": 4, "reps": "12–20", "rest": 45,  "sub": "Средняя дельта" },
      { "id": "front_raise",    "title": "Подъёмы перед собой",            "sets": 3, "reps": "10–15", "rest": 45,  "sub": "Передняя дельта" },
      { "id": "rear_delt",      "title": "Разводка в наклоне",             "sets": 4, "reps": "12–20", "rest": 45,  "sub": "Задняя дельта" },
      { "id": "reverse_pec",    "title": "Обратная бабочка",               "sets": 3, "reps": "12–15", "rest": 45,  "sub": "Задняя дельта" },
      { "id": "upright_row",    "title": "Тяга к подбородку",              "sets": 3, "reps": "8–12",  "rest": 60,  "sub": "Дельты/трапеции" },
      { "id": "arnold_press",   "title": "Жим Арнольда",                   "sets": 3, "reps": "8–12",  "rest": 75,  "sub": "Полный круг" },
      { "id": "cable_lat",      "title": "Подъёмы в стороны в блоке",      "sets": 3, "reps": "12–15", "rest": 45,  "sub": "Памп" },
      { "id": "scapular",       "title": "Подъёмы лопатками",              "sets": 3, "reps": "12–15", "rest": 45,  "sub": "Стабилизация" }
    ],
    "arms": [
      { "id": "barbell_curl",   "title": "Сгибания со штангой",            "sets": 4, "reps": "8–12",  "rest": 60,  "sub": "Бицепс", "tag": "base" },
      { "id": "dumb_curl",      "title": "Сгибания с гантелями",           "sets": 3, "reps": "10–12", "rest": 60,  "sub": "Бицепс" },
      { "id": "hammer_curl",    "title": "Молотки",                        "sets": 3, "reps": "10–12", "rest": 60,  "sub": "Брахиалис" },
      { "id": "preacher_curl",  "title": "Сгибания на скамье Скотта",      "sets": 3, "reps": "10–12", "rest": 60 },
      { "id": "cable_curl",     "title": "Сгибания в блоке",              "sets": 3, "reps": "12–15", "rest": 45 },
      { "id": "close_bench",    "title": "Жим узким хватом",              "sets": 4, "reps": "6–10",  "rest": 90,  "sub": "Трицепс", "tag": "base" },
      { "id": "skull",          "title": "Французский жим (лёжа)",         "sets": 3, "reps": "8–12",  "rest": 75 },
      { "id": "rope_push",      "title": "Разгибания на блоке (канат)",    "sets": 3, "reps": "12–15", "rest": 45 },
      { "id": "overhead_ext",   "title": "Разгибания над головой",         "sets": 3, "reps": "10–12", "rest": 60 },
      { "id": "dips_tri",       "title": "Отжимания на брусьях (трицепс)", "sets": 3, "reps": "8–12",  "rest": 75 }
    ],
    "legs": [
      { "id": "squat",          "title": "Присед",                         "sets": 4, "reps": "5–8",   "rest": 120, "sub": "База", "tag": "base" },
      { "id": "leg_press",      "title": "Жим ногами",                     "sets": 4, "reps": "10–12", "rest": 90 },
      { "id": "rdl",            "title": "Румынская тяга",                  "sets": 4, "reps": "6–10",  "rest": 120, "sub": "Задняя цепь", "tag": "base" },
      { "id": "leg_curl",       "title": "Сгибания ног",                    "sets": 3, "reps": "10–15", "rest": 75 },
      { "id": "leg_ext",        "title": "Разгибания ног",                  "sets": 3, "reps": "12–15", "rest": 60 },
      { "id": "lunges",         "title": "Выпады",                          "sets": 3, "reps": "10–12", "rest": 75 },
      { "id": "calf_raise",     "title": "Подъёмы на икры",                 "sets": 4, "reps": "12–20", "rest": 45 },
      { "id": "hip_hinge",      "title": "Гудморнинг",                      "sets": 3, "reps": "8–10",  "rest": 120 },
      { "id": "hack_squat",     "title": "Хак‑присед",                      "sets": 3, "reps": "8–12",  "rest": 90 },
      { "id": "step_up",        "title": "Шаги на тумбу",                   "sets": 3, "reps": "10–12", "rest": 75 }
    ],
    "abs": [
      { "id": "plank",          "title": "Планка",                          "sets": 3, "reps": "45–60с","rest": 45,  "sub": "Кор", "tag": "base" },
      { "id": "side_plank",     "title": "Боковая планка",                  "sets": 3, "reps": "30–45с","rest": 45 },
      { "id": "crunch",         "title": "Скручивания",                     "sets": 4, "reps": "15–25", "rest": 45 },
      { "id": "leg_raise",      "title": "Подъёмы ног лёжа",                "sets": 4, "reps": "10–15", "rest": 60 },
      { "id": "hanging_raise",  "title": "Подъёмы ног в висе",              "sets": 3, "reps": "8–12",  "rest": 60 },
      { "id": "dead_bug",       "title": "Dead Bug",                        "sets": 3, "reps": "10–14", "rest": 45 },
      { "id": "mountain",       "title": "Альпинист",                       "sets": 3, "reps": "30–45с","rest": 45 },
      { "id": "russian_twist",  "title": "Русские скручивания",             "sets": 3, "reps": "16–24", "rest": 45 },
      { "id": "cable_crunch",   "title": "Скручивания в блоке",             "sets": 3, "reps": "12–15", "rest": 60 },
      { "id": "ab_wheel",       "title": "Колесо для пресса",               "sets": 3, "reps": "6–12",  "rest": 75 }
    ],
    "cardio": [
      { "id": "walk",           "title": "Быстрая ходьба",                  "sets": 1, "reps": "20–40 мин", "rest": 0, "sub": "Зона 2" },
      { "id": "bike",           "title": "Велотренажёр",                    "sets": 1, "reps": "15–30 мин", "rest": 0 },
      { "id": "rower",          "title": "Гребля",                          "sets": 1, "reps": "10–20 мин", "rest": 0 },
      { "id": "run",            "title": "Бег",                             "sets": 1, "reps": "10–30 мин", "rest": 0 },
      { "id": "stairs",         "title": "Степпер",                         "sets": 1, "reps": "10–20 мин", "rest": 0 },
      { "id": "hiit",           "title": "HIIT интервалы",                  "sets": 6, "reps": "30с/30с",   "rest": 0, "sub": "6 интервалов" },
      { "id": "jump_rope",      "title": "Скакалка",                        "sets": 6, "reps": "60с",       "rest": 30 },
      { "id": "elliptical",     "title": "Эллипс",                          "sets": 1, "reps": "15–30 мин", "rest": 0 },
      { "id": "shadow_box",     "title": "Теневой бокс",                    "sets": 6, "reps": "2 мин",      "rest": 60 },
      { "id": "mobility",       "title": "Лёгкая мобильность",              "sets": 1, "reps": "10–15 мин",  "rest": 0 }
    ],
    "technique": [
      { "id": "tech_squat",     "title": "Техника приседа (шаблон)",        "sets": 1, "reps": "5–8 мин", "rest": 0, "sub": "колени/спина" },
      { "id": "tech_bench",     "title": "Техника жима (шаблон)",           "sets": 1, "reps": "5–8 мин", "rest": 0, "sub": "лопатки/мост" },
      { "id": "tech_row",       "title": "Техника тяги (шаблон)",           "sets": 1, "reps": "5–8 мин", "rest": 0, "sub": "кор/лопатки" },
      { "id": "tech_ohp",       "title": "Техника OHP (шаблон)",            "sets": 1, "reps": "5–8 мин", "rest": 0, "sub": "стойка/кор" },
      { "id": "mob_hips",       "title": "Мобильность: таз",               "sets": 1, "reps": "6–10 мин","rest": 0 },
      { "id": "mob_shoulders",  "title": "Мобильность: плечи",             "sets": 1, "reps": "6–10 мин","rest": 0 },
      { "id": "breathing",      "title": "Дыхание и осанка",               "sets": 1, "reps": "5–8 мин", "rest": 0 },
      { "id": "warmup",         "title": "Разминка (универсальная)",       "sets": 1, "reps": "8–12 мин","rest": 0 }
    ]
  })

function _clone(obj) {
      // cheap deep clone for small JS objects
      return JSON.parse(JSON.stringify(obj))
    }


    function getTemplateIndexForMuscle(muscleKey) {
      // 0..4 correspond to root.days templates day1..day5
      if (muscleKey === "chest") return 0
      if (muscleKey === "back") return 1
      if (muscleKey === "shoulders") return 2
      if (muscleKey === "arms") return 3
      if (muscleKey === "technique") return 4
      return -1
    }

    function _defaultExercisesForKey(muscleKey) {
      // If there is a template day - clone its exercises, otherwise use base map.
      var ti = root.getTemplateIndexForMuscle(muscleKey)
      if (ti >= 0 && root.days[ti] && root.days[ti].exercises)
        return _clone(root.days[ti].exercises)
      return _clone(baseExercisesByMuscle[muscleKey] || [])
    }

    function _getSelectedRow() {
      if (weekModel.count <= 0) return null
      return weekModel.get(root.selectedWeekIndex)
    }

    function _setSelectedRowProp(name, value) {
      if (weekModel.count <= 0) return
      weekModel.setProperty(root.selectedWeekIndex, name, value)
      exercisesRevision++
      // keep UI in sync
      syncTemplateFromSelectedWeek()
    }

    function _setSelectedRowProps(props) {
      if (weekModel.count <= 0) return
      for (var k in props) {
        if (props.hasOwnProperty(k)) {
          weekModel.setProperty(root.selectedWeekIndex, k, props[k])
        }
      }
      exercisesRevision++
      syncTemplateFromSelectedWeek()
    }

  // Упражнения для окна "Упражнения" (зависит от выбранной группы)
  property var exerciseBank: {
    var _k = selectedMuscleKey
    var _r = selectedMuscleRev
    return _defaultExercisesForKey(_k)
  }

function _pad2(x) { return (x < 10 ? "0" : "") + x }
  function _formatDate(d) { return _pad2(d.getDate()) + "." + _pad2(d.getMonth()+1) + "." + d.getFullYear() }
  function _weekdayRu(d) {
    var names = ["воскресенье","понедельник","вторник","среда","четверг","пятница","суббота"]
    return names[d.getDay()]
  }
  function _weekdayShortRu(d) {
    var names = ["Вс","Пн","Вт","Ср","Чт","Пт","Сб"]
    return names[d.getDay()]
  }
  function _mondayOfWeek(now) {
    var d = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    var day = d.getDay() // 0..6 (0=Вс)
    var diff = (day === 0 ? -6 : 1 - day)
    d.setDate(d.getDate() + diff)
    return d
  }
  function _todayWeekIndex() {
    var now = new Date()
    var day = now.getDay()
    return (day === 0 ? 6 : day - 1) // Пн=0..Вс=6
  }
  function _groupByKey(key) {
    for (var i=0; i<muscleGroups.length; i++) if (muscleGroups[i].key === key) return muscleGroups[i]
    return null
  }

  function initWeekPlan() {
    weekModel.clear()

    var start = _mondayOfWeek(new Date())
    // дефолт: Пн–Пт тренировки, Сб/Вс отдых
    var defaults = ["chest","back","shoulders","arms","technique","rest","rest"]

    for (var i=0; i<7; i++) {
      var d = new Date(start.getFullYear(), start.getMonth(), start.getDate())
      d.setDate(d.getDate() + i)

      var key = defaults[i]
      var g = _groupByKey(key)
      weekModel.append({
        enabled: (key !== "rest"),
        muscleKey: key,
        muscleTitle: (g ? g.title : ""),
        accent: (g ? g.accent : "#C9D3DF"),
        dateText: _formatDate(d),
        weekdayText: _weekdayRu(d),
        weekdayShort: _weekdayShortRu(d)
      })
    }

    selectedWeekIndex = _todayWeekIndex()
    syncTemplateFromSelectedWeek()
  }

  function setMuscleForSelectedDay(key) {
  var g = _groupByKey(key)
  if (!g || weekModel.count <= 0) return

  var enabled = (key !== "rest")
  var row = weekModel.get(selectedWeekIndex)

  // Логика:
  // - сменили группу -> сбрасываем упражнения в "по шаблону" (customExercises = null)
  // - та же группа -> не трогаем customExercises (пусть остаётся null или массив)
  var nextCustom = null
  if (enabled) {
    var prevKey = row ? row.muscleKey : ""
    if (prevKey === key) {
      nextCustom = (row ? row.customExercises : null)
    } else {
      nextCustom = null
      // при смене мышц также можно сбросить прогресс по упражнениям дня (опционально)
      // сейчас НЕ трогаем doneMap: оставляем как есть, чтобы не было сюрпризов
    }
  } else {
    nextCustom = null
  }

  _setSelectedRowProps({
    "muscleKey": key,
    "muscleTitle": g.title,
    "accent": g.accent,
    "enabled": enabled,
    "customExercises": enabled ? nextCustom : null
  })
}

function clearSelectedDay() {
  // Очистить день: делаем "Отдых" и сбрасываем прогресс по сетам этого дня
  if (weekModel.count <= 0) return

  // reset done for this weekday
  doneByDay[doneDayKey] = ({})
  doneRevision++

  _setSelectedRowProps({
    "muscleKey": "rest",
    "muscleTitle": "Отдых",
    "accent": "#C9D3DF",
    "enabled": false,
    "customExercises": null
  })
}


// выбранный день
property int currentDayIndex: 0
property var currentDay: (days && days.length > 0 ? days[Math.max(0, Math.min(currentDayIndex, days.length - 1))] : null)

// упражнения выбранного дня (зависят от недели/дня и выбранной группы мышц)
property int exercisesRevision: 0
property var exercises: {
  // IMPORTANT: QML не отслеживает зависимости внутри функций.
  // Поэтому явно "дергаем" зависимости, чтобы список обновлялся при смене дня/мышцы.
  var _rev = exercisesRevision
  var _day = selectedWeekIndex
  var _mus = selectedMuscleRev

  var r = _getSelectedRow()
  if (!r || !r.enabled) return []

  // customExercises: null/undefined = "по шаблону"; массив (даже пустой) = явный выбор пользователя
  if (r.customExercises !== null && r.customExercises !== undefined) return r.customExercises

  // дефолт по мышце (на главном экране ограничиваем до 6 для компактности)
  var lib = _defaultExercisesForKey(r.muscleKey)
  return lib.slice(0, Math.min(lib.length, 6))
}

function _selectedExercisesList() {
  // чисто то, что сохранено как кастом в дне
  var r = _getSelectedRow()
  if (!r || !r.enabled) return []
  return r.customExercises || []
}

// эффективный список упражнений дня (то, что реально показываем и считаем в прогрессе)
function _effectiveExercisesList() {
  var r = _getSelectedRow()
  if (!r || !r.enabled) return []

  // customExercises: null/undefined = "по шаблону"
  if (r.customExercises !== null && r.customExercises !== undefined) return r.customExercises

  return _defaultExercisesForKey(r.muscleKey)
}

// список для редактирования в модалке
function _editableExercisesList() {
  var r = _getSelectedRow()
  if (!r || !r.enabled) return []

  // если кастома нет — редактируем клон дефолта; если есть — клон кастома (даже если пустой)
  var base = (r.customExercises !== null && r.customExercises !== undefined)
      ? r.customExercises
      : _defaultExercisesForKey(r.muscleKey)
  return _clone(base)
}

function _isExerciseSelected(exId) {
  // привязка к ревизии, чтобы делегаты обновлялись
  var _t = exercisesRevision

  var list = _effectiveExercisesList()
  for (var i = 0; i < list.length; i++) {
    if (list[i].id === exId) return true
  }
  return false
}

function _visibleExercisesForSelectedDay() {
  // для совместимости: главный экран показывает то же, что считаем в прогрессе
  return _effectiveExercisesList()
}



    function _addExercise(exObj) {
      var list = _editableExercisesList()
      // avoid duplicates by title
      for (var i = 0; i < list.length; i++) {
        if (list[i].id === exObj.id) return
      }
      list.push(_clone(exObj))
      _setSelectedRowProp("customExercises", list)
      }

    function _removeExercise(exId) {
      var list = _editableExercisesList()
      var out = []
      for (var i = 0; i < list.length; i++) {
        if (list[i].id !== exId) out.push(list[i])
      }
      _setSelectedRowProp("customExercises", out)
      }

    function _toggleExercise(exObj) {
      if (_isExerciseSelected(exObj.id)) _removeExercise(exObj.id)
      else _addExercise(exObj)
    }


  // key = "<exerciseTitle>#<setIndex>" -> true/false
  
  function _copyObject(src) {
    var out = ({})
    if (!src) return out
    for (var k in src) {
      if (src.hasOwnProperty(k)) out[k] = src[k]
    }
    return out
  }

property var doneByDay: ({ })  // dayIndex -> { "<exId>#<setIndex>": true }
  property int doneRevision: 0

  function keyForSet(dayIdx, exId, idx) { return dayIdx + "|" + exId + "#" + idx }

  function isSetDone(dayIdx, exId, idx) {
    var _t = doneRevision
    var k = keyForSet(dayIdx, exId, idx)
    var m = doneByDay[dayIdx]
    return m && m[k] === true
  }

  function setDone(dayIdx, exId, idx, value) {
    var k = keyForSet(dayIdx, exId, idx)
    var dayMap = doneByDay[dayIdx] || ({ })
    var nextDayMap = _copyObject(dayMap)
    nextDayMap[k] = (value === true)

    var nextAll = _copyObject(doneByDay)
    nextAll[dayIdx] = nextDayMap
    doneByDay = nextAll
    doneRevision++
    doneRevision++
  }

  function toggleDone(dayIdx, exId, idx) {
    setDone(dayIdx, exId, idx, !isSetDone(dayIdx, exId, idx))
  }

  function resetDay() {
    var d = doneDayKey
    var nextAll = _copyObject(doneByDay)
    nextAll[d] = ({ })
    doneByDay = nextAll
    doneRevision++

    restPaused = false
    restRemainingSeconds = restTotalSeconds
    if (restPopup && restPopup.opened) restPopup.close()
    if (restTimer) restTimer.running = false
  }


  property int totalSets: {
    var t = 0
    for (var i = 0; i < exercises.length; i++) t += exercises[i].sets
    return t
  }

  property int doneSets: {
    var _d = doneRevision
    var c = 0
    for (var i = 0; i < exercises.length; i++) {
      var ex = exercises[i]
      for (var j = 0; j < ex.sets; j++) {
        if (isSetDone(doneDayKey, ex.id, j)) c++
      }
    }
    return c
  }

  property real progress01: (totalSets > 0 ? (doneSets / totalSets) : 0)
// Technique context
  property string currentExerciseTitle: ""
  property string currentExerciseMeta: ""

  // Rest context
  property string restExerciseTitle: ""
  property int restTotalSeconds: 102  // 1:42
  property int restRemainingSeconds: restTotalSeconds
  property bool restPaused: false

  function formatTime(sec) {
    var m = Math.floor(sec / 60)
    var s = sec % 60
    return m + ":" + (s < 10 ? "0" + s : s)
  }

  function openTechnique(title, meta) {
    currentExerciseTitle = title
    currentExerciseMeta = meta
    var w = Window.window
    if (w && w.showTechnique) {
      w.showTechnique(title, meta)
    }
  }

  function openRest(title) {
    restExerciseTitle = title
    restRemainingSeconds = restTotalSeconds
    restPaused = false
    restTimer.running = true
    restPopup.open()
  }

  component UiText: Text {
    font.family: root.uiFont
    renderType: Text.NativeRendering
  }

  component PillBtn: Item {
    id: pb
    property string text: ""
    property bool active: false
    property int px: 12
    signal clicked()

    implicitHeight: 30
    implicitWidth: Math.max(92, label.implicitWidth + 26)

    Rectangle {
      anchors.fill: parent
      radius: 999
      color: pb.active ? Qt.rgba(1,1,1,0.95) : Qt.rgba(1,1,1,0.72)
      border.width: 1
      border.color: Qt.rgba(0,0,0,0.06)
    }

    UiText {
      id: label
      anchors.centerIn: parent
      text: pb.text
      font.pixelSize: pb.px
      font.weight: Font.DemiBold
      color: "#0b1520"
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: pb.clicked()
    }
  }

  // DayChip fixed: padding=0 + visually centered
  component DayChip: Item {
    id: dc
    property string text: ""
    property string subtext: ""
    property bool active: false
    property color accent: "#FF6B7A"
    signal clicked()

    readonly property bool twoLine: (dc.subtext && dc.subtext.length > 0)
    implicitHeight: dc.twoLine ? 58 : 44
    implicitWidth: Math.max(120, Math.max(chipText.implicitWidth, chipSub.implicitWidth) + 34)

    Glass { anchors.fill: parent; radius: 18; glassOpacity: dc.active ? 0.12 : 0.14; padding: 0 }

    Rectangle {
      anchors.fill: parent
      radius: 18
      color: dc.active ? Qt.rgba(dc.accent.r, dc.accent.g, dc.accent.b, 0.20) : Qt.rgba(0,0,0,0)
    }

    Column {
      anchors.centerIn: parent
      spacing: dc.twoLine ? 2 : 0
    width: dc.width

      UiText {
        id: chipText
        text: dc.text
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: "#0b1520"
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        elide: Text.ElideRight
        maximumLineCount: 1
      }

      UiText {
        id: chipSub
        visible: dc.twoLine
        text: dc.subtext
        font.pixelSize: 10
        color: Qt.rgba(0.10,0.18,0.26,0.55)
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        elide: Text.ElideRight
        maximumLineCount: 1
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: dc.clicked()
    }
  }

  component DumbbellIcon: Item {
    id: di
    property color stroke: Qt.rgba(0.10,0.20,0.35,0.85)
    implicitWidth: 22
    implicitHeight: 22

    Canvas {
      anchors.fill: parent
      onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.lineWidth = 2.2;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        ctx.strokeStyle = di.stroke;

        var w = width, h = height;
        var cy = h*0.5;

        ctx.beginPath(); ctx.moveTo(w*0.30, cy); ctx.lineTo(w*0.70, cy); ctx.stroke();

        ctx.beginPath(); ctx.moveTo(w*0.22, cy-h*0.18); ctx.lineTo(w*0.22, cy+h*0.18); ctx.stroke();
        ctx.beginPath(); ctx.moveTo(w*0.16, cy-h*0.14); ctx.lineTo(w*0.16, cy+h*0.14); ctx.stroke();

        ctx.beginPath(); ctx.moveTo(w*0.78, cy-h*0.18); ctx.lineTo(w*0.78, cy+h*0.18); ctx.stroke();
        ctx.beginPath(); ctx.moveTo(w*0.84, cy-h*0.14); ctx.lineTo(w*0.84, cy+h*0.14); ctx.stroke();
      }
    }
  }

  // ✅ FIX: RepDot теперь хранит done у себя (QML гарантированно обновляет визуал)
  component RepDot: Glass {
    id: rd
    property int number: 1
    property bool done: false
    signal clicked()

    radius: 14
    glassOpacity: 0.12
    padding: 0
    Layout.preferredWidth: 34
    Layout.preferredHeight: 34

    Rectangle {
      anchors.fill: parent
      radius: 14
      color: rd.done ? Qt.rgba(0.10, 0.75, 0.45, 0.22) : Qt.rgba(1,1,1,0.35)
      border.width: 1
      border.color: rd.done ? Qt.rgba(0.10, 0.75, 0.45, 0.55) : Qt.rgba(0,0,0,0.06)

      Behavior on color { ColorAnimation { duration: 180 } }
      Behavior on border.color { ColorAnimation { duration: 180 } }
    }

    UiText {
      anchors.centerIn: parent
      text: rd.number
      font.pixelSize: 12
      font.weight: Font.DemiBold
      color: rd.done ? Qt.rgba(0.05,0.35,0.22,0.98) : "#0b1520"
      Behavior on color { ColorAnimation { duration: 180 } }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: rd.clicked()
    }
  }

  ColumnLayout {
    width: parent.width
    height: parent.height
    spacing: 14

    // Days row (центрирование)
    Glass {
      id: dayTabs
      Layout.fillWidth: true
      Layout.preferredHeight: 72
      radius: 28
      glassOpacity: 0.14
      padding: 0

      // выбранный день (пока влияет только на визуал; дальше подключим к данным)
      property int currentIndex: 0

      RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Repeater {
          model: weekModel

          delegate: DayChip {
            accent: accent
            active: index === root.selectedWeekIndex
            text: (weekdayShort + (muscleKey !== "rest" ? " · " + muscleTitle : ""))
            subtext: (dateText + " / " + weekdayText)

            Layout.alignment: Qt.AlignVCenter
            onClicked: {
              root.selectedWeekIndex = index
              root.syncTemplateFromSelectedWeek()
            }
          }
        }

        Item { Layout.fillWidth: true }



      }
    }


    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 16

      ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 14

        RowLayout {
          Layout.fillWidth: true
          spacing: 14

          Glass {
            Layout.fillWidth: true
            // Фиксируем высоту (как в исходной "fix15"),
            // иначе внутренний контент может обрезаться из‑за clip: true
            // и карточка выглядит неровной.
            Layout.preferredHeight: 270
            Layout.minimumHeight: 270
            Layout.maximumHeight: 270
            radius: 28
            glassOpacity: 0.14


            clip: true
            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 16
              spacing: 8

              RowLayout {
                Layout.fillWidth: true
                spacing: 12

                  // Заголовок: фиксируем одну строку, чтобы высота шапки не "прыгала" между днями
  UiText {
    text: (weekModel.count > 0 ? (weekModel.get(root.selectedWeekIndex).weekdayText.charAt(0).toUpperCase() + weekModel.get(root.selectedWeekIndex).weekdayText.slice(1) + " · " + (weekModel.get(root.selectedWeekIndex).enabled ? weekModel.get(root.selectedWeekIndex).muscleTitle : "не выбрано")) : (root.currentDay ? root.currentDay.title : "Тренировка"))
    font.pixelSize: 26
    font.weight: Font.DemiBold
    color: "#0b1520"
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignVCenter
    wrapMode: Text.NoWrap
    elide: Text.ElideRight
    maximumLineCount: 1
  }

  // Пилюли: держим в одну строку (без переноса), чтобы Day-header был одинаковым во всех днях
  Flickable {
    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
    Layout.fillWidth: true
    Layout.preferredHeight: 34
    clip: true

    contentWidth: pillRow.implicitWidth
    contentHeight: pillRow.implicitHeight
    interactive: contentWidth > width
    boundsBehavior: Flickable.StopAtBounds

    Row {
      id: pillRow
      spacing: 8
      height: parent.height

      PillBtn { text: "Сила"; active: (root.currentDay && root.currentDay.mode === "strength") }
      PillBtn { text: "Гипертрофия"; active: (root.currentDay && root.currentDay.mode === "hypertrophy") }
      PillBtn {
        text: "Техника"
        active: (root.currentDay && root.currentDay.mode === "technique")
        onClicked: root.openTechnique((root.currentDay ? (root.currentDay.title + " — техника") : "Техника"),
                                      (root.currentDay ? root.currentDay.subtitle : ""))
      }
    }
  }
}

              UiText { text: (root.hasTemplateWorkout && root.currentDay ? root.currentDay.subtitle : "Выбери, что тренировать в этот день"); font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.65) }

Item {
  Layout.fillWidth: true
  height: 36

  Row {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    spacing: 8

    SoftButton {
      text: (weekModel.count > 0 && weekModel.get(root.selectedWeekIndex).enabled ? "Изменить" : "Выбрать")
      width: 112
      height: 32
      onClicked: root.openMusclePicker()
    }

    SoftButton {
      text: "Упражнения"
      enabled: (weekModel.count > 0 && weekModel.get(root.selectedWeekIndex).enabled)
      width: 132
      height: 32
      onClicked: root.openExercisesDialog()
    }

    SoftButton {
      text: "Очистить"
      enabled: (weekModel.count > 0 && weekModel.get(root.selectedWeekIndex).enabled)
      width: 104
      height: 32
      onClicked: root.clearSelectedDay()
    }
  }
}


              // ✅ FIX: clip для прогресса
              Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 999
                color: Qt.rgba(0.10,0.20,0.35,0.06)
                clip: true

                Rectangle {
                  height: parent.height
                  radius: 999
                  width: Math.max(22, parent.width * root.progress01)
                  gradient: Gradient {
                    GradientStop { position: 0.0; color: "#FF5C7A" }
                    GradientStop { position: 1.0; color: "#7AA7FF" }
                  }
                }
              }

              UiText { text: "Выполнено: " + root.doneSets + " / " + root.totalSets; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.65) }

              RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Glass { Layout.fillWidth: true; Layout.preferredHeight: 78; radius: 20; glassOpacity: 0.12
                  ColumnLayout { anchors.centerIn: parent; spacing: 6
                    UiText { text: (root.currentDay && root.currentDay.mode === "technique" ? "Гайды" : "Всего подходов"); font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.60); width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight }

                    UiText { text: (root.currentDay && root.currentDay.mode === "technique" ? String(root.exercises.length) : String(root.totalSets)); font.pixelSize: 22; font.weight: Font.DemiBold; color: "#0b1520" }
                  }
                }

                Glass { Layout.fillWidth: true; Layout.preferredHeight: 78; radius: 20; glassOpacity: 0.12
                  ColumnLayout { anchors.centerIn: parent; spacing: 6
                    UiText { text: (root.currentDay && root.currentDay.mode === "technique" ? "Фокус" : "Всего повторений"); font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.60); width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight }

                    UiText { text: (root.currentDay && root.currentDay.mode === "technique" ? "Техника" : (root.currentDay ? root.currentDay.totalRepsText : "—")); font.pixelSize: (root.currentDay && root.currentDay.mode === "technique" ? 18 : 22); font.weight: Font.DemiBold; color: "#0b1520" }
                  }
                }

                Glass { Layout.fillWidth: true; Layout.preferredHeight: 78; radius: 20; glassOpacity: 0.12
                  ColumnLayout { anchors.centerIn: parent; spacing: 6
                        UiText {
                            text: "Время"
                            font.pixelSize: 11
                            color: Qt.rgba(0.42, 0.46, 0.55, 1)
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    UiText { text: (root.currentDay ? root.currentDay.timeText : "—"); font.pixelSize: 22; font.weight: Font.DemiBold; color: "#0b1520" }
                  }
                }
              }
            }
          }

          ColumnLayout {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            spacing: 14

            Glass {
              Layout.fillWidth: true
              Layout.preferredHeight: 118
              radius: 24
              glassOpacity: 0.14

              RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                ColumnLayout {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  spacing: 6

                  UiText { text: "Серия"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.60) }

                  RowLayout { spacing: 8
                    UiText { text: "🔥"; font.pixelSize: 16; Layout.alignment: Qt.AlignVCenter }
                    UiText { text: "6 дней"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#0b1520"; Layout.alignment: Qt.AlignVCenter }
                  }

                  UiText { text: "Держи ритм это ускоряет прогресс"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55); wrapMode: Text.WordWrap }
                }

                UiText { text: "Стрик"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.55); Layout.alignment: Qt.AlignTop }
              }
            }

            Glass {
              Layout.fillWidth: true
              Layout.preferredHeight: 118
              radius: 24
              glassOpacity: 0.14

              RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                ColumnLayout {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  spacing: 6

                  RowLayout {
                    Layout.fillWidth: true
                    UiText { text: "Следующая тренировка"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.60) }
                    Item { Layout.fillWidth: true }
                    UiText { text: "Далее"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.55) }
                  }

                  UiText { text: (root.days && root.days.length>0 ? root.days[(root.currentDayIndex+1)%root.days.length].title : "—"); font.pixelSize: 18; font.weight: Font.DemiBold; color: "#0b1520" }
                  UiText { text: (root.days && root.days.length>0 ? root.days[(root.currentDayIndex+1)%root.days.length].subtitle : ""); font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55) }
                }

                Glass {
                  Layout.preferredWidth: 44
                  Layout.preferredHeight: 44
                  radius: 22
                  glassOpacity: 0.12
                  padding: 0

                  Rectangle {
                    anchors.centerIn: parent
                    width: 30; height: 30; radius: 15
                    color: Qt.rgba(0.20,0.45,1.0,0.16)
                    UiText { anchors.centerIn: parent; text: "➜"; font.pixelSize: 14; color: Qt.rgba(0.10,0.25,0.55,0.9) }
                  }
                }
              }
            }
          }
        }

        // Exercises
        ScrollView {
            id: exercisesScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                id: exColumn
                width: exercisesScroll.availableWidth
                spacing: 14
                Repeater {
                          model: root._visibleExercisesForSelectedDay()

                          delegate: Glass {
                            id: exCard
                            width: exColumn.width
                            height: 118
                            radius: 26
                            glassOpacity: 0.14

                            property var exData: modelData

                            RowLayout {
                              anchors.fill: parent
                              anchors.margins: 16
                              spacing: 14

                              Glass {
                                Layout.preferredWidth: 52
                                Layout.preferredHeight: 52
                                radius: 22
                                glassOpacity: 0.12
                                padding: 0
                                Layout.alignment: Qt.AlignVCenter

                                DumbbellIcon { anchors.centerIn: parent; stroke: Qt.rgba(0.10,0.20,0.35,0.80) }
                              }

                              ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6

                                RowLayout {
                                  Layout.fillWidth: true
                                  spacing: 10

                                  UiText {
                                    text: exCard.exData.title
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: "#0b1520"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                  }

                                  UiText { text: exCard.exData.tag; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55); Layout.alignment: Qt.AlignVCenter }
                                }

                                UiText { text: exCard.exData.sub; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.60) }

                                RowLayout {
                                  Layout.fillWidth: true
                                  spacing: 10

                                  Repeater {
                                    model: exCard.exData.sets
                                    delegate: RepDot {
                                      number: index + 1
                                      done: root.isSetDone(root.doneDayKey, exCard.exData.id, index)

                                      onClicked: {
                                        root.toggleDone(root.doneDayKey, exCard.exData.id, index)
                root.openRest(exCard.exData.title + " — повтор " + (index + 1))
                                      }
                                    }
                                  }

                                  Item { Layout.fillWidth: true }

                                  PillBtn {
                                    text: "Техника"
                                    Layout.alignment: Qt.AlignVCenter
                                    onClicked: root.openTechnique(exCard.exData.title, exCard.exData.sub)
                                  }
                                }
                              }
                            }
                          }
                        }
                Item { height: 10 }
            }
        }


        Item { Layout.fillHeight: true }
      }

      // Right column
      ColumnLayout {
        Layout.preferredWidth: 460
        Layout.fillHeight: true
        spacing: 14

        Glass {
          Layout.fillWidth: true
          Layout.preferredHeight: 170
          radius: 28
          glassOpacity: 0.14

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            RowLayout {
              Layout.fillWidth: true
              UiText { text: "Прогресс за неделю"; font.pixelSize: 14; font.weight: Font.DemiBold; color: Qt.rgba(0.15,0.25,0.35,0.80) }
              Item { Layout.fillWidth: true }
              UiText { text: "7д"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.55) }
            }

            UiText { text: "Сила/объём по дням"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55) }
            Rectangle { Layout.fillWidth: true; height: 2; radius: 1; color: Qt.rgba(0,0,0,0.04) }
            UiText { text: "(график подключим дальше)"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45) }
            Item { Layout.fillHeight: true }
          }
        }

        Glass {
          Layout.fillWidth: true
          Layout.fillHeight: true
          radius: 28
          glassOpacity: 0.14

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
              Layout.fillWidth: true
              spacing: 10
              UiText { text: "Инфо-карточки"; font.pixelSize: 14; font.weight: Font.DemiBold; color: Qt.rgba(0.15,0.25,0.35,0.80) }
              PillBtn { text: "В процессе"; px: 12 }
              Item { Layout.fillWidth: true }
              UiText { text: "Скролл внутри"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45) }
            }

            UiText { text: "Скролл внутри, кликай сеты (подключим дальше)."; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45); wrapMode: Text.WordWrap }
            Item { Layout.fillHeight: true }
          }
        }
      }
    }
  }

  // =========================
  // REST POPUP
  // =========================
  Timer {
    id: restTimer
    interval: 1000
    repeat: true
    running: false
    onTriggered: {
      if (root.restPaused) return
      if (root.restRemainingSeconds > 0) {
        root.restRemainingSeconds -= 1
      } else {
        running = false
      }
    }
  }

  Popup {
    id: restPopup
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape
    padding: 0

    x: root.width - width - 26
    y: root.height - height - 26

    background: Rectangle {
      radius: 22
      color: Qt.rgba(1,1,1,0.93)  // ~7% прозрачности
      border.width: 1
      border.color: Qt.rgba(0,0,0,0.08)
    }

    onClosed: restTimer.running = false

    contentItem: Item {
      implicitWidth: 340
      implicitHeight: 160

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
          Layout.fillWidth: true

          ColumnLayout {
            spacing: 2
            UiText { text: "Отдых"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.60) }
            UiText { text: root.restExerciseTitle; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45); elide: Text.ElideRight }
          }

          Item { Layout.fillWidth: true }
          SoftButton { text: "✕"; Layout.preferredWidth: 44; Layout.preferredHeight: 36; onClicked: restPopup.close() }
        }

        UiText {
          text: root.formatTime(root.restRemainingSeconds)
          font.pixelSize: 36
          font.weight: Font.DemiBold
          color: "#0b1520"
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          SoftButton {
            text: root.restPaused ? "Продолжить" : "Пауза"
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            onClicked: root.restPaused = !root.restPaused
          }

          SoftButton {
            text: "Сброс"
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            onClicked: {
              root.restRemainingSeconds = root.restTotalSeconds
              root.restPaused = false
              restTimer.running = true
            }
          }
        }
      }
    }
  }

  // =========================
  // TECHNIQUE (новый дизайн как на твоём фото)
  // =========================
  component BigTab: Item {
    id: bt
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool active: false
    signal clicked()

    implicitHeight: 72
    implicitWidth: 250

    Rectangle {
      anchors.fill: parent
      radius: 18
      color: bt.active ? Qt.rgba(0.10,0.35,1.0,0.96) : Qt.rgba(1,1,1,0.70)
      border.width: 1
      border.color: bt.active ? Qt.rgba(0.10,0.35,1.0,0.96) : Qt.rgba(0,0,0,0.06)
    }

    RowLayout {
      anchors.fill: parent
      anchors.margins: 14
      spacing: 10

      Rectangle {
        Layout.preferredWidth: 34
        Layout.preferredHeight: 34
        radius: 12
        color: bt.active ? Qt.rgba(1,1,1,0.18) : Qt.rgba(0.10,0.20,0.35,0.06)

        UiText {
          anchors.centerIn: parent
          text: bt.icon
          font.pixelSize: 16
          color: bt.active ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0.10,0.20,0.35,0.70)
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        UiText {
          text: bt.title
          font.pixelSize: 13
          font.weight: Font.DemiBold
          color: bt.active ? Qt.rgba(1,1,1,0.98) : "#0b1520"
          elide: Text.ElideRight
        }

        UiText {
          text: bt.subtitle
          font.pixelSize: 11
          color: bt.active ? Qt.rgba(1,1,1,0.78) : Qt.rgba(0.15,0.25,0.35,0.55)
          elide: Text.ElideRight
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: bt.clicked()
    }
  }

  component CheckLine: RowLayout {
    id: cl
    property string text: ""
    spacing: 10
    Layout.fillWidth: true

    Rectangle {
      Layout.preferredWidth: 22
      Layout.preferredHeight: 22
      radius: 11
      color: Qt.rgba(0.10,0.35,1.0,0.12)
      border.width: 1
      border.color: Qt.rgba(0.10,0.35,1.0,0.20)

      UiText { anchors.centerIn: parent; text: "✓"; font.pixelSize: 12; font.weight: Font.DemiBold; color: Qt.rgba(0.10,0.35,1.0,0.95) }
    }

    UiText {
      text: cl.text
      font.pixelSize: 13
      font.weight: Font.Medium
      color: Qt.rgba(0.08,0.12,0.18,0.92)
      wrapMode: Text.WordWrap
      lineHeightMode: Text.ProportionalHeight
      lineHeight: 1.18
      Layout.fillWidth: true
    }
  }

  Popup {
    id: techniquePopup
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape
    onClosed: root.modalState = root.modalNone

    // Справа, как у тебя в референсе
    x: Math.max(0, parent.width - width - 28)
    y: Math.max(24, (parent.height - height) / 2)

    // Большое пропорциональное окно (как в референсе)
    width: Math.min(740, Math.max(620, parent.width * 0.46))
    height: Math.min(parent.height - 80, 860)
    background: Rectangle {
        radius: 26
        color: "white"
        border.color: Qt.rgba(0,0,0,0.10)
        border.width: 1
    }

    // Лёгкое затемнение под окном (blur без QtGraphicalEffects недоступен — делаем premium dim)
    Overlay.modal: Rectangle {
        color: Qt.rgba(0,0,0,0.20)
        Rectangle { anchors.fill: parent; color: Qt.rgba(1,1,1,0.04) } // лёгкий "frost"
    }
    Overlay.modeless: Rectangle { color: "transparent" }

    property int activeTab: 0

    // Демо-контент (жим лёжа)
    readonly property var tabTitles: [
        { title: "Ключевые точки", sub: "Основные моменты" },
        { title: "Типичные ошибки", sub: "Чего нельзя делать" },
        { title: "Амплитуда движения", sub: "Насколько глубоко опускать" },
        { title: "Лайфхаки", sub: "Как сделать лучше" }
    ]

    readonly property var demo: ({
        key: [
            "Лопатки сведены и опущены — держи «полку».",
            "Локти под углом ~45° — не разводи в стороны.",
            "Гриф по дуге: вниз к нижней груди, вверх к плечам.",
            "Контроль внизу: пауза 0–1с без отскока."
        ],
        err: [
            "Отрыв таза/моста — теряешь стабильность.",
            "Сильный прогиб кистей — боль и потеря силы.",
            "Развод локтей 90° — риск плечам.",
            "Отскок от груди — ломает траекторию и темп."
        ],
        amp: [
            "Опускай до лёгкого касания груди (контролируемо).",
            "Если плечи дискомфортят — укороти амплитуду и проверь угол локтя.",
            "Сохраняй одинаковую точку касания каждый повтор.",
            "Вверх — до полного выпрямления, без «переброса» плеч вперёд."
        ],
        hacks: [
            "Сожми гриф «внутрь» — включаются широчайшие и стабилизация.",
            "Ноги в пол, пятки давят — стабильнее корпус.",
            "На старте подумай «гриф к себе» — траектория станет ровнее.",
            "Дыши: вдох на опускании, выдох после прохождения «мертвой точки»."
        ]
    })

    contentItem: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    UiText {
                        text: "Техника"
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        color: "#0E1320"
                    }
                    UiText {
                        text: root.currentExerciseTitle !== "" ? root.currentExerciseTitle : "Упражнение"
                        font.pixelSize: 14
                        color: Qt.rgba(0.10,0.12,0.16,0.55)
                        elide: Text.ElideRight
                    }
                    UiText {
                        visible: root.currentExerciseMeta !== ""
                        text: root.currentExerciseMeta
                        font.pixelSize: 12
                        color: Qt.rgba(0.10,0.12,0.16,0.42)
                        elide: Text.ElideRight
                    }
                }

                SoftButton {
                    text: "✕"
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 34
                    radius: 12
                    onClicked: techniquePopup.close()
                }
            }

            // Tabs
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: 4
                    delegate: BigTab {
                        Layout.fillWidth: true
                        title: techniquePopup.tabTitles[index].title
                        subtitle: techniquePopup.tabTitles[index].sub
                        active: techniquePopup.activeTab === index
                        onClicked: techniquePopup.activeTab = index
                    }
                }
            }

            // Main content
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                rowSpacing: 12
                columnSpacing: 12

                // K — основной текст техники (крупнее/читабельнее)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 18
                    color: Qt.rgba(1,1,1,0.96)
                    border.color: Qt.rgba(0,0,0,0.08)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                width: 28; height: 28; radius: 10
                                color: Qt.rgba(0.23,0.45,0.98,0.10)
                                Text { anchors.centerIn: parent; text: "👁"; font.pixelSize: 14 }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: techniquePopup.tabTitles[techniquePopup.activeTab].title
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                color: "#0E1320"
                                elide: Text.ElideRight
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: {
                                    if (techniquePopup.activeTab === 0) return techniquePopup.demo.key
                                    if (techniquePopup.activeTab === 1) return techniquePopup.demo.err
                                    if (techniquePopup.activeTab === 2) return techniquePopup.demo.amp
                                    return techniquePopup.demo.hacks
                                }
                                delegate: RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Rectangle {
                                        width: 22; height: 22; radius: 11
                                        color: Qt.rgba(0.23,0.45,0.98,0.18)
                                        border.color: Qt.rgba(0.23,0.45,0.98,0.35)
                                        border.width: 1
                                        Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: 12; color: "#2B5BFF" }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: 15
                                        color: Qt.rgba(0.10,0.12,0.16,0.78)
                                    }
                                }
                            }
                        }
                    }
                }

                // Z — лайфхаки (вторая колонка)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 18
                    color: Qt.rgba(1,1,1,0.96)
                    border.color: Qt.rgba(0,0,0,0.08)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                width: 28; height: 28; radius: 10
                                color: Qt.rgba(0.98,0.70,0.20,0.18)
                                border.color: Qt.rgba(0.98,0.70,0.20,0.28)
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "💡"; font.pixelSize: 14 }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Лайфхаки"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                color: "#0E1320"
                                elide: Text.ElideRight
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: techniquePopup.demo.hacks
                                delegate: RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Rectangle {
                                        width: 22; height: 22; radius: 11
                                        color: Qt.rgba(0.13,0.77,0.37,0.18)
                                        border.color: Qt.rgba(0.13,0.77,0.37,0.30)
                                        border.width: 1
                                        Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: 12; color: "#16A34A" }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: 15
                                        color: Qt.rgba(0.10,0.12,0.16,0.78)
                                    }
                                }
                            }
                        }
                    }
                }

                // H — визуальная техника (низ, на всю ширину)
                Rectangle {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
                    radius: 18
                    color: Qt.rgba(1,1,1,0.96)
                    border.color: Qt.rgba(0,0,0,0.08)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                width: 28; height: 28; radius: 10
                                color: Qt.rgba(0.23,0.45,0.98,0.10)
                                Text { anchors.centerIn: parent; text: "🎥"; font.pixelSize: 14 }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Визуальная техника"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                color: "#0E1320"
                            }

                            Rectangle {
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 62
                                radius: 16
                                color: Qt.rgba(0.23,0.45,0.98,0.06)
                                border.color: Qt.rgba(0.23,0.45,0.98,0.14)
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10
                                    Text { text: "📹"; font.pixelSize: 18 }
                                    Text { text: "/"; font.pixelSize: 14; color: Qt.rgba(0,0,0,0.25) }
                                    Text { text: "🖼"; font.pixelSize: 18 }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "+ Хочешь — добавлю видео/гиф в чек‑лист про технику прямо тут."
                            font.pixelSize: 13
                            color: Qt.rgba(0.10,0.12,0.16,0.55)
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}


  // =============================
  // Popup выбора группы мышц
  // =============================
  Popup {
    id: musclePicker
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape
    onClosed: root.modalState = root.modalNone
    anchors.centerIn: parent
    width: Math.min(parent.width - 80, 420)
    padding: 16

    background: Glass { radius: 22; glassOpacity: 0.18; padding: 0 }

    ColumnLayout {
      anchors.fill: parent
      spacing: 10

      RowLayout {
        Layout.fillWidth: true
        UiText {
          text: "Выбери, что тренировать"
          font.pixelSize: 16
          font.weight: Font.DemiBold
          color: "#0b1520"
          Layout.fillWidth: true
        }

        Item {
          width: 20
          height: 20
          Layout.alignment: Qt.AlignRight | Qt.AlignTop

          UiText {
            anchors.centerIn: parent
            text: "✕"
            font.pixelSize: 18
            color: Qt.rgba(0.10,0.16,0.22,0.70)
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: musclePicker.close()
          }
        }
      }

      Repeater {
        model: root.muscleGroups
        delegate: SoftButton {
          Layout.fillWidth: true
          height: 38
          radius: 14

          readonly property bool isSelected: (root.selectedMuscleKey === modelData.key)

          active: isSelected
          text: (isSelected ? "✓ " : "") + modelData.title

          onClicked: {
            root.setMuscleForSelectedDay(modelData.key)
            musclePicker.close()
          }
        }
      }
    }
  }





  // ----- Edit exercises dialog -----
  Dialog {
    id: editExercisesDialog
    onClosed: root.modalState = root.modalNone
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape
    x: (parent ? (parent.width - width)/2 : 0)
    y: (parent ? (parent.height - height)/2 : 0)
    width: Math.min(560, parent ? parent.width * 0.86 : 560)
    height: Math.min(540, parent ? parent.height * 0.78 : 540)

    background: Rectangle {
      radius: 18
      color: "#ffffff"
      border.color: Qt.rgba(0.12,0.18,0.25,0.10)
    }
    // selection is stored per-weekday in weekModel.customExercises
    function _hasExercise(exId) { return root._isExerciseSelected(exId) }
    function _addExercise(exObj) { root._addExercise(exObj) }
    function _removeExercise(exId) { root._removeExercise(exId) }



    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 10

      RowLayout {
        Layout.fillWidth: true
        UiText {
          text: "Упражнения"
          font.pixelSize: 18
          font.weight: Font.DemiBold
          color: "#0b1520"
          Layout.fillWidth: true
        }
        Item {
          width: 20
          height: 20
          Layout.alignment: Qt.AlignRight | Qt.AlignTop

          UiText {
            anchors.centerIn: parent
            text: "✕"
            font.pixelSize: 18
            color: Qt.rgba(0.10,0.16,0.22,0.70)
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: editExercisesDialog.close()
          }
        }
      }

      UiText {
        Layout.fillWidth: true
        text: "Выбери упражнения для этого дня. Нажми ‘+’ чтобы добавить, ‘−’ чтобы убрать."
        font.pixelSize: 12
        color: Qt.rgba(0.15,0.25,0.35,0.65)
        wrapMode: Text.WordWrap
      }

            Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 14
        color: Qt.rgba(0.06,0.10,0.15,0.03)
        border.color: Qt.rgba(0.12,0.18,0.25,0.08)

        ListView {
          id: exercisesBankView
          anchors.fill: parent
          anchors.margins: 12
          spacing: 10
          clip: true
          model: root.exerciseBank

          delegate: Rectangle {
            width: ListView.view.width
            height: 56
            radius: 14
            color: "#ffffff"
            border.color: Qt.rgba(0.12,0.18,0.25,0.10)

            RowLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 10

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                UiText { text: modelData.title; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#0b1520" }
                UiText {
                  text: (modelData.sub && modelData.sub.length ? modelData.sub : "")
                  visible: (modelData.sub && modelData.sub.length)
                  font.pixelSize: 11
                  color: Qt.rgba(0.15,0.25,0.35,0.65)
                }
              }

              SoftButton {
                text: root._isExerciseSelected(modelData.id) ? "−" : "+"
                onClicked: {
                  if (root._isExerciseSelected(modelData.id))
                    editExercisesDialog._removeExercise(modelData.id)
                  else
                    editExercisesDialog._addExercise(modelData)
                }
              }
            }
          }
        }

        UiText {
          anchors.centerIn: parent
          text: "Нет упражнений для этой группы"
          color: "#9AA6B2"
          font.pixelSize: 14
          visible: exercisesBankView.count === 0
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Item { Layout.fillWidth: true }
        SoftButton {
          text: "Сбросить к шаблону"
          enabled: (_getSelectedRow() && _getSelectedRow().enabled)
          onClicked: {
            var r = _getSelectedRow();
            if (!r) return;
            _setSelectedRowProp('customExercises', null)
          }
        }
      }
    }
  }

}