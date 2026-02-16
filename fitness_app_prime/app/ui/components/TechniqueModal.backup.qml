import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../components"

Item {
  id: modal
  anchors.fill: parent
  visible: false
  z: 999

  property string titleText: "Техника"
  property string exerciseTitle: ""
  property string exerciseMeta: ""
  property int activeTab: 0

  // Data
  readonly property var tabDefs: [
    { title: "Ключевые точки", sub: "Основные моменты" },
    { title: "Типичные ошибки", sub: "Чего нельзя делать" },
    { title: "Амплитуда", sub: "Насколько глубоко" },
    { title: "Лайфхаки", sub: "Как сделать лучше" }
  ]

  readonly property var pointsItems: [
    "Лопатки сведены и опущены — держи «полку».",
    "Локти под углом ~45° — не разводи в стороны.",
    "Гриф по дуге: вниз к нижней груди, вверх к плечам.",
    "Контроль внизу: пауза 0–1с без отскока."
  ]

  readonly property var errorsItems: [
    "Локти слишком в стороны — перегружаешь плечо.",
    "Отрыв таза/мост «в потолок» — теряешь контроль.",
    "Отскок от груди — риски для плеча и ребер.",
    "Запястья ломаются назад — теряешь силу и стабильность."
  ]

  readonly property var rangeItems: [
    "Опускай гриф к нижней груди, не к шее.",
    "Глубина: лёгкое касание/контроль без отскока.",
    "Пауза 0–1с, если хочешь «железный» контроль.",
    "Если плечо ноет — сократи амплитуду и проверь локти."
  ]

  readonly property var tipsItems: [
    "Сожми гриф «внутрь» — включаются широчайшие и стабилизация.",
    "Ноги в пол, пятки давят — стабильнее корпус.",
    "На старте подумай «гриф к себе» — траектория станет ровнее.",
    "Дыши: вдох на опускании, выдох после «мертвой точки»."
  ]

  function openFor(title, meta) {
    exerciseTitle = title || ""
    exerciseMeta = meta || ""
    activeTab = 0
    visible = true
    forceActiveFocus()
  }

  function close() { visible = false }

  // Strong dim + haze (pseudo blur)
  Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.58) }
  Rectangle { anchors.fill: parent; color: Qt.rgba(1, 1, 1, 0.10) }

  MouseArea { anchors.fill: parent; onClicked: modal.close() }

  Rectangle {
    id: panel
    width: Math.min(parent.width * 0.52, 760)
    height: parent.height * 0.92
    x: parent.width - width - 28
    y: (parent.height - height) / 2
    radius: 26
    color: "#ffffff"
    border.width: 1
    border.color: Qt.rgba(0, 0, 0, 0.08)

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 22
      spacing: 14

      // Header
      RowLayout {
        Layout.fillWidth: true
        spacing: 12

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 4

          Text {
            text: modal.titleText
            font.pixelSize: 22
            font.weight: Font.Bold
            color: "#0B1520"
          }

          Text {
            text: (modal.exerciseTitle !== "" ? modal.exerciseTitle : "") +
                  (modal.exerciseMeta !== "" ? ("  •  " + modal.exerciseMeta) : "")
            font.pixelSize: 13
            color: "#6b7280"
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.fillWidth: true
          }
        }

        Rectangle {
          width: 36; height: 36; radius: 12
          color: "#f3f4f6"
          border.width: 1
          border.color: Qt.rgba(0,0,0,0.06)

          Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 16; color: "#0B1520" }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: modal.close()
          }
        }
      }

      // Tabs (premium, controlled width, no overflow)
      RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Repeater {
          model: modal.tabDefs

          delegate: Rectangle {
            id: tab
            Layout.fillWidth: true
            height: 50
            radius: 14
            property bool isActive: modal.activeTab === index

            color: isActive ? "#2563eb" : "#f3f4f6"
            border.width: 1
            border.color: isActive ? Qt.rgba(0,0,0,0.0) : Qt.rgba(0,0,0,0.06)

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: modal.activeTab = index
            }

            Column {
              anchors.centerIn: parent
              spacing: 2
              width: parent.width - 14

              Text {
                text: modelData.title
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: isActive ? "white" : "#0B1520"
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 1
                width: parent.width
              }

              Text {
                text: modelData.sub
                font.pixelSize: 10
                color: isActive ? Qt.rgba(1,1,1,0.85) : "#6b7280"
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 1
                width: parent.width
              }
            }
          }
        }
      }

      // Content: TWO COLUMNS, both filled
      ScrollView {
        id: sc
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        Item {
          width: sc.availableWidth
          height: Math.max(leftCard.implicitHeight, rightCard.implicitHeight)

          RowLayout {
            anchors.fill: parent
            spacing: 14

            // Left column: tab-dependent main content
            Glass {
              id: leftCard
              Layout.fillWidth: true
              Layout.preferredWidth: 1
              Layout.fillHeight: true
              radius: 18

              Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                  text: modal.tabDefs[modal.activeTab].title
                  font.pixelSize: 16
                  font.weight: Font.Bold
                  color: "#0B1520"
                }

                Repeater {
                  model: modal.activeTab === 0 ? modal.pointsItems
                        : modal.activeTab === 1 ? modal.errorsItems
                        : modal.activeTab === 2 ? modal.rangeItems
                        : modal.tipsItems

                  delegate: Row {
                    width: parent.width
                    spacing: 10

                    Rectangle {
                      width: 22; height: 22; radius: 11
                      color: modal.activeTab === 1 ? "#fee2e2"
                            : modal.activeTab === 3 ? "#dcfce7"
                            : "#dbeafe"
                      border.width: 1
                      border.color: Qt.rgba(0,0,0,0.06)

                      Text {
                        anchors.centerIn: parent
                        text: modal.activeTab === 1 ? "!" : "✓"
                        font.pixelSize: 12
                        color: modal.activeTab === 1 ? "#b91c1c"
                              : modal.activeTab === 3 ? "#166534"
                              : "#1d4ed8"
                      }
                    }

                    Text {
                      width: parent.width - 22 - 10
                      text: modelData
                      font.pixelSize: 13
                      color: "#111827"
                      wrapMode: Text.WordWrap
                      lineHeightMode: Text.ProportionalHeight
                      lineHeight: 1.12
                    }
                  }
                }

                Rectangle {
                  width: parent.width
                  height: 1
                  color: Qt.rgba(0,0,0,0.06)
                }

                // Small helper block to avoid emptiness for non-tips tabs
                Text {
                  visible: modal.activeTab !== 3
                  text: "Подсказка: нажми «Видео» или «Гиф» справа — позже добавим материалы."
                  font.pixelSize: 12
                  color: "#6b7280"
                  wrapMode: Text.WordWrap
                }
              }
            }

            // Right column: always useful content + quick actions
            Glass {
              id: rightCard
              Layout.fillWidth: true
              Layout.preferredWidth: 1
              Layout.fillHeight: true
              radius: 18

              Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                  text: "Визуальная техника"
                  font.pixelSize: 16
                  font.weight: Font.Bold
                  color: "#0B1520"
                }

                Text {
                  text: "Добавим видео/гиф и чек‑лист — позже."
                  font.pixelSize: 13
                  color: "#6b7280"
                  wrapMode: Text.WordWrap
                }

                Row {
                  spacing: 10

                  Rectangle {
                    width: 44; height: 44; radius: 14
                    color: "#eef2ff"
                    border.width: 1
                    border.color: Qt.rgba(0,0,0,0.06)
                    Text { anchors.centerIn: parent; text: "🎥"; font.pixelSize: 16 }
                  }

                  Rectangle {
                    width: 44; height: 44; radius: 14
                    color: "#eef2ff"
                    border.width: 1
                    border.color: Qt.rgba(0,0,0,0.06)
                    Text { anchors.centerIn: parent; text: "🖼"; font.pixelSize: 16 }
                  }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(0,0,0,0.06) }

                Text {
                  text: "Мини‑чеклист (сегодня)"
                  font.pixelSize: 14
                  font.weight: Font.DemiBold
                  color: "#0B1520"
                }

                Repeater {
                  model: [
                    "Лопатки сведены и стабильны",
                    "Запястья над локтями",
                    "Ноги в пол (стабильность)",
                    "Контроль внизу без отскока"
                  ]
                  delegate: Row {
                    spacing: 10

                    Rectangle {
                      width: 18; height: 18; radius: 9
                      color: "#f3f4f6"
                      border.width: 1
                      border.color: Qt.rgba(0,0,0,0.08)
                      Text { anchors.centerIn: parent; text: "•"; color: "#0B1520"; font.pixelSize: 12 }
                    }

                    Text {
                      text: modelData
                      font.pixelSize: 13
                      color: "#111827"
                      wrapMode: Text.WordWrap
                    }
                  }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(0,0,0,0.06) }

                Text {
                  text: "Следующий шаг"
                  font.pixelSize: 14
                  font.weight: Font.DemiBold
                  color: "#0B1520"
                }

                Text {
                  text: "Добавим реальные видео/гиф по каждому упражнению и персональные ошибки из твоих сетов."
                  font.pixelSize: 13
                  color: "#6b7280"
                  wrapMode: Text.WordWrap
                }
              }
            }
          }
        }
      }
    }
  }
}
