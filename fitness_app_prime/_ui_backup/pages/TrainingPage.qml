import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
  id: root
  Layout.fillWidth: true
  Layout.fillHeight: true

  RowLayout {
    anchors.fill: parent
    spacing: 16

    // LEFT COLUMN
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.preferredWidth: 860
      spacing: 14

      // Day card
      Glass {
        Layout.fillWidth: true
        Layout.preferredHeight: 210
        radius: 28
        glassOpacity: 0.16

        Column {
          anchors.fill: parent
          anchors.margins: 18
          spacing: 10

          RowLayout {
            spacing: 12
            Text { text: "Day 1 Chest"; font.pixelSize: 26; font.weight: Font.DemiBold; color: "#0b1520" }

            Item { Layout.fillWidth: true } // спейсер

            Pill { text: "Сила"; active: true }
            Pill { text: "Гипертрофия" }
            Pill { text: "Техника" }
          }

          Text { text: "Тяжелый жим + верх груди"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.65) }

          Rectangle { width: parent.width; height: 2; radius: 1; color: Qt.rgba(1,1,1,0.35) }

          RowLayout {
            spacing: 14

            Glass {
              Layout.preferredWidth: 220
              Layout.preferredHeight: 76
              radius: 20; glassOpacity: 0.18
              Column { anchors.centerIn: parent; spacing: 6
                Text { text: "Total sets"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.65) }
                Text { text: "16"; font.pixelSize: 22; font.weight: Font.DemiBold; color: "#0b1520" }
              }
            }

            Glass {
              Layout.preferredWidth: 220
              Layout.preferredHeight: 76
              radius: 20; glassOpacity: 0.18
              Column { anchors.centerIn: parent; spacing: 6
                Text { text: "Total reps"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.65) }
                Text { text: "160+"; font.pixelSize: 22; font.weight: Font.DemiBold; color: "#0b1520" }
              }
            }

            Glass {
              Layout.preferredWidth: 220
              Layout.preferredHeight: 76
              radius: 20; glassOpacity: 0.18
              Column { anchors.centerIn: parent; spacing: 6
                Text { text: "Time"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.65) }
                Text { text: "40 мин"; font.pixelSize: 22; font.weight: Font.DemiBold; color: "#0b1520" }
              }
            }

            Item { Layout.fillWidth: true }
          }
        }
      }

      // Exercise cards list
      Repeater {
        model: [
          { title: "Жим штанги лёжа 0", sub: "468", tag: "Main Lift" },
          { title: "Жим штанги наклон 30", sub: "3610", tag: "Upper Chest" },
          { title: "Жим гантелей лёжа (neutral)", sub: "3812", tag: "Pump" },
          { title: "Разводка гантелей", sub: "3215", tag: "Pump" }
        ]
        delegate: Glass {
          Layout.fillWidth: true
          Layout.preferredHeight: 110
          radius: 26
          glassOpacity: 0.16

          RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            Rectangle {
              Layout.preferredWidth: 44
              Layout.preferredHeight: 44
              radius: 18
              color: Qt.rgba(1,1,1,0.55)
              border.width: 1
              border.color: Qt.rgba(1,1,1,0.35)
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 6
              Text { text: modelData.title; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#0b1520"; elide: Text.ElideRight }
              Text { text: modelData.sub; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.65) }
            }

            Pill { text: "Техника" }
          }
        }
      }

      Item { Layout.fillHeight: true }
    }

    // RIGHT COLUMN
    ColumnLayout {
      Layout.preferredWidth: 460
      Layout.fillHeight: true
      spacing: 14

      Glass {
        Layout.fillWidth: true
        Layout.preferredHeight: 170
        radius: 28
        glassOpacity: 0.16

        Column {
          anchors.fill: parent
          anchors.margins: 16
          spacing: 6
          RowLayout {
            spacing: 10
            Text { text: "Weekly Progress"; font.pixelSize: 14; font.weight: Font.DemiBold; color: Qt.rgba(0.15,0.25,0.35,0.80) }
            Item { Layout.fillWidth: true }
            Text { text: "7д"; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.55) }
          }
          Text { text: "Сила/объём по дням"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.55) }
          Rectangle { width: parent.width; height: 2; radius: 1; color: Qt.rgba(1,1,1,0.35) }
          Text { text: "(график подключим дальше)"; font.pixelSize: 11; color: Qt.rgba(0.15,0.25,0.35,0.45) }
        }
      }

      Glass {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 28
        glassOpacity: 0.16

        Column {
          anchors.fill: parent
          anchors.margins: 16
          spacing: 10

          RowLayout {
            spacing: 12
            Text { text: "Rich cards"; font.pixelSize: 14; font.weight: Font.DemiBold; color: Qt.rgba(0.15,0.25,0.35,0.80) }
            Pill { text: "Live"; active: false }
            Item { Layout.fillWidth: true }
          }

          Text {
            text: "Скролл внутри, кликай сеты (подключим дальше)."
            font.pixelSize: 11
            color: Qt.rgba(0.15,0.25,0.35,0.45)
            wrapMode: Text.WordWrap
          }

          Item { Layout.fillHeight: true }
        }
      }
    }
  }
}