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
    { key: "core",      title: "Пресс",   accent: "#FF5DAA", templateIndex: -1 },
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
  property var baseExercisesByMuscle: ({
    legs: [
      { id: "legs_squat",     title: "Приседания",              sub: "4×6–10  ·  2:30", tag: "База", sets: 4 },
      { id: "legs_press",     title: "Жим ногами",              sub: "4×10–12 ·  2:00", tag: "База", sets: 4 },
      { id: "legs_rdl",       title: "Румынская тяга",          sub: "3×8–12  ·  2:00", tag: "Задняя цепь", sets: 3 },
      { id: "legs_lunge",     title: "Выпады",                  sub: "3×10–12 ·  1:30", tag: "Объём", sets: 3 },
      { id: "legs_curl",      title: "Сгибание ног лёжа",       sub: "3×12–15 ·  1:30", tag: "Изоляция", sets: 3 },
      { id: "legs_calf",      title: "Подъёмы на икры",         sub: "4×12–20 ·  1:00", tag: "Икры", sets: 4 }
    ],
    core: [
      { id: "core_crunch",    title: "Скручивания",             sub: "3×15–20 ·  1:00", tag: "Пресс", sets: 3 },
      { id: "core_legraise",  title: "Подъёмы ног",             sub: "3×10–15 ·  1:00", tag: "Низ пресса", sets: 3 },
      { id: "core_plank",     title: "Планка",                  sub: "3×40–60с ·  1:00", tag: "Стабилизация", sets: 3 },
      { id: "core_twist",     title: "Русский твист",           sub: "3×20–30 ·  1:00", tag: "Косые", sets: 3 }
    ],
    cardio: [
      { id: "cardio_tread",   title: "Беговая дорожка",         sub: "12–20 мин · Z2", tag: "Кардио", sets: 1 },
      { id: "cardio_bike",    title: "Велотренажёр",            sub: "15–25 мин · Z2", tag: "Кардио", sets: 1 },
      { id: "cardio_row",     title: "Гребля",                  sub: "10–15 мин · ровно", tag: "Кардио", sets: 1 },
      { id: "cardio_walk",    title: "Ходьба",                  sub: "20–40 мин", tag: "Восстановление", sets: 1 }
    ],
    rest: []
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
        weekdayShort: _weekdayShortRu(d),
        customExercises: (key === "rest" ? [] : null)
      })
    }

    selectedWeekIndex = _todayWeekIndex()
    syncTemplateFromSelectedWeek()
  }

  function setMuscleForSelectedDay(key) {
    var g = _groupByKey(key)
    if (!g || weekModel.count <= 0) return

    var prevKey = weekModel.get(selectedWeekIndex).muscleKey

    weekModel.setProperty(selectedWeekIndex, "muscleKey", key)
    weekModel.setProperty(selectedWeekIndex, "muscleTitle", g.title)
    weekModel.setProperty(selectedWeekIndex, "accent", g.accent)
    weekModel.setProperty(selectedWeekIndex, "enabled", (key !== "rest"))

    // When muscle changes we must NOT keep old customExercises (it caused "legs day but chest exercises")
    // Use: null -> template list, [] -> user removed all (only for enabled days).
    if (key === "rest") {
      weekModel.setProperty(selectedWeekIndex, "customExercises", [])
    } else {
      weekModel.setProperty(selectedWeekIndex, "customExercises", null)
    }

    // Reset completion for this day when muscle changes
    if (prevKey !== key) {
      doneByDay[selectedWeekIndex] = ({})
    }

    exercisesRevision++
    syncTemplateFromSelectedWeek()
  }

  function clearSelectedDay() {
    weekModel.setProperty(selectedWeekIndex, "muscleKey", "rest")
    weekModel.setProperty(selectedWeekIndex, "muscleTitle", "Отдых")
    weekModel.setProperty(selectedWeekIndex, "accent", "#C9D3DF")
    weekModel.setProperty(selectedWeekIndex, "enabled", false)
    weekModel.setProperty(selectedWeekIndex, "customExercises", [])
    doneByDay[selectedWeekIndex] = ({})
    exercisesRevision++
    syncTemplateFromSelectedWeek()
  }

  // currentDayIndex продолжает указывать на шаблон (day1..day5) для отображения контента
  property bool hasTemplateWorkout: true
  function syncTemplateFromSelectedWeek() {
    var row = weekModel.get(selectedWeekIndex)
    if (!row) { hasTemplateWorkout = true; currentDayIndex = 0; return }

    var g = _groupByKey(row.muscleKey)
    var idx = (g ? g.templateIndex : -1)
    if (row.enabled && idx >= 0) {
      hasTemplateWorkout = true
      currentDayIndex = idx
    } else {
      // пока нет шаблона (например "Ноги" или "Отдых") — показываем плейсхолдер, не Day 1
      hasTemplateWorkout = false
      currentDayIndex = 0
    }
  }

  Component.onCompleted: {
    initWeekPlan()
  syncTemplateFromSelectedWeek()
}

// выбранный день
property int currentDayIndex: 0
property var currentDay: (days && days.length > 0 ? days[Math.max(0, Math.min(currentDayIndex, days.length - 1))] : null)

// упражнения выбранного дня (зависят от недели/дня и выбранной группы мышц)
property int exercisesRevision: 0
property var exercises: {
  // dependency tick (чтобы обновлялось после add/remove)
  var _t = exercisesRevision

  var r = _getSelectedRow()
  if (!r || !r.enabled) return []

  var list = r.customExercises
  if (list && list.length) return list

  var lib = _defaultExercisesForKey(r.muscleKey)
  return lib.slice(0, Math.min(lib.length, 6))
}

function _selectedExercisesList() {
  var r = _getSelectedRow()
  if (!r || !r.enabled) return []

  // IMPORTANT:
  // - customExercises === null/undefined -> day uses template (default) list for its muscle
  // - customExercises is Array (even []) -> user-edited list (empty means user removed all)
  if (r.customExercises === undefined || r.customExercises === null) {
    return _defaultExercisesForKey(r.muscleKey)
  }
  return r.customExercises
}

function _isExerciseSelected(title) {
  // привязка к ревизии, чтобы делегаты обновлялись
  var _t = exercisesRevision

  var list = _selectedExercisesList()
  for (var i = 0; i < list.length; i++) {
    if (list[i].title === title) return true
  }
  return false
}

function _visibleExercisesForSelectedDay() {
  var row = _getSelectedRow()
  if (!row || !row.enabled) return []
  var picked = _selectedExercisesList()
  if (picked && picked.length > 0) return picked
  return _defaultExercisesForKey(row.muscleKey)
}


    function _addExercise(exObj) {
      var list = _selectedExercisesList().slice(0)
      // avoid duplicates by title
      for (var i = 0; i < list.length; i++) {
        if (list[i].title === exObj.title) return
      }
      list.push(_clone(exObj))
      _setSelectedRowProp("customExercises", list)
      }

    function _removeExercise(title) {
      var list = _selectedExercisesList()
      var out = []
      for (var i = 0; i < list.length; i++) {
        if (list[i].title !== title) out.push(list[i])
      }
      _setSelectedRowProp("customExercises", out)
      }

    function _toggleExercise(exObj) {
      if (_isExerciseSelected(exObj.title)) _removeExercise(exObj.title)
      else _addExercise(exObj)
    }


  // key = "<exerciseTitle>#<setIndex>" -> true/false
  property var doneByDay: ({ })  // dayIndex -> { "<exId>#<setIndex>": true }

  function keyForSet(dayIdx, exId, idx) { return dayIdx + "|" + exId + "#" + idx }

  function isSetDone(dayIdx, exId, idx) {
    var k = keyForSet(dayIdx, exId, idx)
    var m = doneByDay[dayIdx]
    return (m && m[k] === true) ? true : false
}

  function setDone(dayIdx, exId, idx, value) {
    var k = keyForSet(dayIdx, exId, idx)
    var dayMap = doneByDay[dayIdx] || ({ })
    var nextDayMap = Object.assign({}, dayMap)
    nextDayMap[k] = (value === true)

    var nextAll = Object.assign({}, doneByDay)
    nextAll[dayIdx] = nextDayMap
    doneByDay = nextAll
  }

  function toggleDone(dayIdx, exId, idx) {
    setDone(dayIdx, exId, idx, !isSetDone(dayIdx, exId, idx))
  }

  function resetDay() {
    var d = currentDayIndex
    var nextAll = Object.assign({}, doneByDay)
    nextAll[d] = ({ })
    doneByDay = nextAll

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
    var c = 0
    for (var i = 0; i < exercises.length; i++) {
      var ex = exercises[i]
      for (var j = 0; j < ex.sets; j++) {
        if (isSetDone(currentDayIndex, ex.id, j)) c++
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



  // DayChip fixed: padding=0 + visually centered


  // ✅ FIX: RepDot теперь хранит done у себя (QML гарантированно обновляет визуал)

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

                  Item {
                      width: 118; height: 46
                      property bool active: index === root.selectedDayIndex
                      Rectangle {
                          anchors.fill: parent
                          radius: 18
                          color: active ? Qt.rgba(1,1,1,0.55) : Qt.rgba(1,1,1,0.14)
                          border.color: active ? Qt.rgba(1,1,1,0.55) : Qt.rgba(1,1,1,0.10)
                          border.width: 1
                      }
                      Column {
                          anchors.centerIn: parent
                          spacing: 2
                          Text { text: model.title; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#0b1520"; horizontalAlignment: Text.AlignHCenter; width: parent.width }
                          Text { text: model.dateText; font.pixelSize: 10; color: Qt.rgba(0.35,0.38,0.46,1); horizontalAlignment: Text.AlignHCenter; width: parent.width }
                      }
                      MouseArea {
                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor
                          onClicked: root.selectDay(index)
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
  Text {
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
                  Item {
                      Layout.preferredHeight: 36
                      property bool active: true
                      signal clicked()
                      implicitWidth: editText.implicitWidth + 28
                      Rectangle { anchors.fill: parent; radius: 18; color: active ? "white" : Qt.rgba(1,1,1,0.18); border.width: 1; border.color: Qt.rgba(1,1,1,0.10) }
                      Text { id: editText; anchors.centerIn: parent; text: "Изменить"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#0b1520" }
                      MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
                      onClicked: editWorkoutDialog.open()
                  }
                  Item {
                      Layout.preferredHeight: 36
                      property bool active: false
                      signal clicked()
                      implicitWidth: exText.implicitWidth + 28
                      Rectangle { anchors.fill: parent; radius: 18; color: active ? "white" : Qt.rgba(1,1,1,0.18); border.width: 1; border.color: Qt.rgba(1,1,1,0.10) }
                      Text { id: exText; anchors.centerIn: parent; text: "Упражнения"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#0b1520" }
                      MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
                      onClicked: showExercisesDialog.open()
                  }
    contentHeight: pillRow.implicitHeight
    interactive: contentWidth > width
    boundsBehavior: Flickable.StopAtBounds

    Row {
      id: pillRow
      spacing: 8
      height: parent.height

      Item {
        height: parent.height
        property bool active: (root.currentDay && root.currentDay.mode === "strength")
        signal clicked()
        implicitWidth: t1.implicitWidth + 28
        Rectangle { anchors.fill: parent; radius: 18; color: active ? "white" : Qt.rgba(1,1,1,0.18); border.width: 1; border.color: Qt.rgba(1,1,1,0.10) }
        Text { id: t1; anchors.centerIn: parent; text: "Сила"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#0b1520" }
        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
        onClicked: root.setMode("strength")
      }
      Item {
        height: parent.height
        property bool active: (root.currentDay && root.currentDay.mode === "hypertrophy")
        signal clicked()
        implicitWidth: t2.implicitWidth + 28
        Rectangle { anchors.fill: parent; radius: 18; color: active ? "white" : Qt.rgba(1,1,1,0.18); border.width: 1; border.color: Qt.rgba(1,1,1,0.10) }
        Text { id: t2; anchors.centerIn: parent; text: "Гипертрофия"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#0b1520" }
        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
        onClicked: root.setMode("hypertrophy")
      }
      Item {
        height: parent.height
        property bool active: (root.currentDay && root.currentDay.mode === "technique")
        signal clicked()
        implicitWidth: t3.implicitWidth + 28
        Rectangle { anchors.fill: parent; radius: 18; color: active ? "white" : Qt.rgba(1,1,1,0.18); border.width: 1; border.color: Qt.rgba(1,1,1,0.10) }
        Text { id: t3; anchors.centerIn: parent; text: "Техника"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#0b1520" }
        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
        onClicked: root.openTechnique((root.currentDay ? (root.currentDay.title + " — техника") : "Техника"),
                                     (root.currentDay ? root.currentDay.subtitle : ""))
      }
    }
  }
}

              Text { text: (root.hasTemplateWorkout && root.currentDay ? root.currentDay.subtitle : "Выбери, что тренировать в этот день"); font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.65) }

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
      onClicked: musclePicker.open()
    }

    SoftButton {
      text: "Упражнения"
      enabled: (weekModel.count > 0 && weekModel.get(root.selectedWeekIndex).enabled)
      width: 132
      height: 32
      onClicked: editExercisesDialog.open()
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

              Text { text: "Выполнено: " + root.doneSets + " / " + root.totalSets; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.65) }

              RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Glass { Layout.fillWidth: true; Layout.preferredHeight: 78; radius: 20; glassOpacity: 0.12
                  ColumnLayout { anchors.centerIn: parent; spacing: 6
                    Text { text: (root.currentDay && root.currentDay.mode === "technique" ? "Гайды" : "Всего подходов"); font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.60); width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight }

                    Text { text: (root.currentDay && root.currentDay.mode === "technique" ? String(root.exercises.length) : String(root.totalSets)); font.pixelSize: 22; font.weight: Font.DemiBold; color: "#0b1520" }
                  }
                }

                Glass { Layout.fillWidth: true; Layout.preferredHeight: 78; radius: 20; glassOpacity: 0.12
                  ColumnLayout { anchors.centerIn: parent; spacing: 6
                    Text { text: (root.currentDay && root.currentDay.mode === "technique" ? "Фокус" : "Всего повторений"); font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.60); width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight }

                    Text { text: (root.currentDay && root.currentDay.mode === "technique" ? "Техника" : (root.currentDay ? root.currentDay.totalRepsText : "—")); font.pixelSize: (root.currentDay && root.currentDay.mode === "technique" ? 18 : 22); font.weight: Font.DemiBold; color: "#0b1520" }
                  }
                }

                Glass { Layout.fillWidth: true; Layout.preferredHeight: 78; radius: 20; glassOpacity: 0.12
                  ColumnLayout { anchors.centerIn: parent; spacing: 6
                        Text {
                            text: "Время"
                            font.pixelSize: 11
                            color: Qt.rgba(0.42, 0.46, 0.55, 1)
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    Text { text: (root.currentDay ? root.currentDay.timeText : "—"); font.pixelSize: 22; font.weight: Font.DemiBold; color: "#0b1520" }
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

                  Text { text: "Серия"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.60) }

                  RowLayout { spacing: 8
                    Text { text: "🔥"; font.pixelSize: 16; Layout.alignment: Qt.AlignVCenter }
                    Text { text: "6 дней"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#0b1520"; Layout.alignment: Qt.AlignVCenter }
                  }

                  Text { text: "Держи ритм это ускоряет прогресс"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55); wrapMode: Text.WordWrap }
                }

                Text { text: "Стрик"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.55); Layout.alignment: Qt.AlignTop }
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
                    Text { text: "Следующая тренировка"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.60) }
                    Item { Layout.fillWidth: true }
                    Text { text: "Далее"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.55) }
                  }

                  Text { text: (root.days && root.days.length>0 ? root.days[(root.currentDayIndex+1)%root.days.length].title : "—"); font.pixelSize: 18; font.weight: Font.DemiBold; color: "#0b1520" }
                  Text { text: (root.days && root.days.length>0 ? root.days[(root.currentDayIndex+1)%root.days.length].subtitle : ""); font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55) }
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
                    Text { anchors.centerIn: parent; text: "➜"; font.pixelSize: 14; color: Qt.rgba(0.10,0.25,0.55,0.9) }
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

                                Text { anchors.centerIn: parent; text: "🏋"; font.pixelSize: 20; color: Qt.rgba(0.10,0.20,0.35,0.80) }
                              }

                              ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6

                                RowLayout {
                                  Layout.fillWidth: true
                                  spacing: 10

                                  Text {
                                    text: exCard.exData.title
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: "#0b1520"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                  }

                                  Text { text: exCard.exData.tag; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55); Layout.alignment: Qt.AlignVCenter }
                                }

                                Text { text: exCard.exData.sub; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.60) }

                                RowLayout {
                                  Layout.fillWidth: true
                                  spacing: 10

                                  Repeater {
                                    model: exCard.exData.sets
                                    delegate: RepDot {
                                      number: index + 1
                                      done: !!root.isSetDone(root.currentDayIndex, exCard.exData.id, index)

                                      onClicked: {
                                        root.toggleDone(root.currentDayIndex, exCard.exData.id, index)
                root.openRest(exCard.exData.title + " — повтор " + (index + 1))
                                      }
                                    }
                                  }

                                  Item { Layout.fillWidth: true }

              Item {
                implicitWidth: techTxt.implicitWidth + 22
                implicitHeight: 26
                Rectangle {
                  anchors.fill: parent
                  radius: 13
                  color: Qt.rgba(1,1,1,0.35)
                  border.width: 1
                  border.color: Qt.rgba(1,1,1,0.25)
                }
                Text { id: techTxt; anchors.centerIn: parent; text: "Техника"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#0b1520" }
                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.openTechnique(model.title + " — техника", model.group)
                }
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
              Text { text: "Прогресс за неделю"; font.pixelSize: 14; font.weight: Font.DemiBold; color: Qt.rgba(0.15,0.25,0.35,0.80) }
              Item { Layout.fillWidth: true }
              Text { text: "7д"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.55) }
            }

            Text { text: "Сила/объём по дням"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55) }
            Rectangle { Layout.fillWidth: true; height: 2; radius: 1; color: Qt.rgba(0,0,0,0.04) }
            Text { text: "(график подключим дальше)"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45) }
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
              Text { text: "Инфо-карточки"; font.pixelSize: 14; font.weight: Font.DemiBold; color: Qt.rgba(0.15,0.25,0.35,0.80) }
      Item {
        implicitWidth: stTxt.implicitWidth + 22
        implicitHeight: 26
        Rectangle { anchors.fill: parent; radius: 13; color: Qt.rgba(1,1,1,0.35); border.width: 1; border.color: Qt.rgba(1,1,1,0.25) }
        Text { id: stTxt; anchors.centerIn: parent; text: "В процессе"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#0b1520" }
      }
              Item { Layout.fillWidth: true }
              Text { text: "Скролл внутри"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45) }
            }

            Text { text: "Скролл внутри, кликай сеты (подключим дальше)."; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45); wrapMode: Text.WordWrap }
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
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
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
            Text { text: "Отдых"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.60) }
            Text { text: root.restExerciseTitle; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45); elide: Text.ElideRight }
          }

          Item { Layout.fillWidth: true }
          SoftButton { text: "✕"; Layout.preferredWidth: 44; Layout.preferredHeight: 36; onClicked: restPopup.close() }
        }

        Text {
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


  Popup {
    id: techniquePopup
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

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

                    Text {
                        text: "Техника"
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        color: "#0E1320"
                    }
                    Text {
                        text: root.currentExerciseTitle !== "" ? root.currentExerciseTitle : "Упражнение"
                        font.pixelSize: 14
                        color: Qt.rgba(0.10,0.12,0.16,0.55)
                        elide: Text.ElideRight
                    }
                    Text {
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
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: parent
    width: Math.min(parent.width - 80, 420)
    padding: 16

    background: Glass { radius: 22; glassOpacity: 0.18; padding: 0 }

    ColumnLayout {
      anchors.fill: parent
      spacing: 10

      RowLayout {
        Layout.fillWidth: true
        Text {
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

          Text {
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

          readonly property bool isSelected: (root.exercisesRevision >= 0) && (root._getSelectedRow() && root._getSelectedRow().muscleKey === modelData.key)

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
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
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
    function _hasExercise(title) { return root._isExerciseSelected(title) }
    function _addExercise(exObj) { root._addExercise(exObj) }
    function _removeExercise(title) { root._removeExercise(title) }



    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 10

      RowLayout {
        Layout.fillWidth: true
        Text {
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

          Text {
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

      Text {
        Layout.fillWidth: true
        text: "Выбери упражнения для этого дня. Нажми ✓ чтобы добавить, ✕ чтобы убрать."
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
          property string bankKey: {
            var _r = root.exercisesRevision
            var row = root._getSelectedRow()
            return (row && row.muscleKey) ? row.muscleKey : ""
          }

          model: root._defaultExercisesForKey(bankKey)

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
                Text { text: modelData.title; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#0b1520" }
                Text {
                  text: (modelData.sub && modelData.sub.length ? modelData.sub : "")
                  visible: (modelData.sub && modelData.sub.length)
                  font.pixelSize: 11
                  color: Qt.rgba(0.15,0.25,0.35,0.65)
                }
              }

              Item {
                width: 118
                height: 40
                Layout.alignment: Qt.AlignVCenter

                readonly property bool selected: root._isExerciseSelected(modelData.title)

                Rectangle {
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  width: parent.width
                  height: parent.height
                  radius: 12
                  color: Qt.rgba(0,0,0,0.0)
                  border.color: Qt.rgba(0.12,0.18,0.25,0.10)

                  Row {
                    anchors.fill: parent
                    spacing: 0

                    // ✓ add
                    Rectangle {
                      width: parent.width/2
                      height: parent.height
                      radius: 12
                      color: Qt.rgba(0.20, 0.75, 0.45, 0.95)
                      border.color: Qt.rgba(0,0,0,0.08)
                      opacity: selected ? 0.35 : 1.0

                      Text {
                        anchors.centerIn: parent
                        text: "✓"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: "white"
                      }

                      MouseArea {
                        anchors.fill: parent
                        enabled: !selected
                        cursorShape: Qt.PointingHandCursor
                        onClicked: editExercisesDialog._addExercise(modelData)
                      }
                    }

                    // ✕ remove
                    Rectangle {
                      width: parent.width/2
                      height: parent.height
                      radius: 12
                      color: Qt.rgba(0.95, 0.35, 0.45, 0.95)
                      border.color: Qt.rgba(0,0,0,0.08)
                      opacity: selected ? 1.0 : 0.35

                      Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: "white"
                      }

                      MouseArea {
                        anchors.fill: parent
                        enabled: selected
                        cursorShape: Qt.PointingHandCursor
                        onClicked: editExercisesDialog._removeExercise(modelData.title)
                      }
                    }
                  }
                }
              }}
            }
          }
        }

        Text {
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
            _setSelectedRowProp('customExercises', _defaultExercisesForKey(r.muscleKey))
          }
        }
      }
    }
  }

