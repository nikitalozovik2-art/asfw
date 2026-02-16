import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
  id: root
  property string title: "Training Upper Body"
  property string subtitle: ""
  property real progressValue: 0.0
  signal resetDay()

  implicitHeight: 92

  Glass {
    anchors.fill: parent
    radius: 28
  opacity: 0.20
  }

  RowLayout {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 14

    Rectangle {
      width: 44
      height: 44
      radius: 16
      color: "#ffffff"
      border.width: 1
      border.color: Qt.rgba(1,1,1,0.35)
      Layout.alignment: Qt.AlignVCenter
      Text { anchors.centerIn: parent; text: "NI"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#0b1520" }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 4

      Text { text: root.title; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#0b1520" }
      Text { text: root.subtitle; font.pixelSize: 12; color: Qt.rgba(0.15,0.25,0.35,0.65) }
    }

    // progress справа (пока просто текстом и кружком-плейсхолдером)
    RowLayout {
      spacing: 12
      Layout.alignment: Qt.AlignVCenter

      Glass {
        width: 120
        height: 44
        radius: 16
  opacity: 0.16

        Row {
          anchors.centerIn: parent
          spacing: 8
          Rectangle { width: 18; height: 18; radius: 9; color: Qt.rgba(0.6,0.6,0.7,0.35) }
          Column {
            spacing: 2
            Text { text: "Progress"; font.pixelSize: 10; color: Qt.rgba(0.15,0.25,0.35,0.65) }
            Text { text: Math.round(root.progressValue*100) + "%"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#0b1520" }
          }
        }
      }

      SoftButton {
        width: 120
        height: 44
        text: "Сброс дня"
        onClicked: root.resetDay()
      }
    }
  }
}