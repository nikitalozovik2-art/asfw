import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
  id: root

  property string title: "Training Upper Body"
  property string subtitle: ""
  property real progressValue: 0.0

  // ✅ универсальные переключатели
  property bool showProgress: true
  property bool showResetButton: true

  signal resetDay()

  implicitHeight: 78

  Glass {
    anchors.fill: parent
    radius: 26
    glassOpacity: 0.20
  }

  RowLayout {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 12

    // Avatar
    Rectangle {
      Layout.preferredWidth: 40
      Layout.preferredHeight: 40
      Layout.maximumHeight: 40
      Layout.alignment: Qt.AlignVCenter

      radius: 14
      color: "#ffffff"
      border.width: 1
      border.color: Qt.rgba(1,1,1,0.35)

      Text {
        anchors.centerIn: parent
        text: "NI"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: "#0b1520"
      }
    }

    // Title / subtitle
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 3

      Text {
        text: root.title
        font.pixelSize: 17
        font.weight: Font.DemiBold
        color: "#0b1520"
        elide: Text.ElideRight
        Layout.fillWidth: true
      }

      Text {
        text: root.subtitle
        font.pixelSize: 12
        color: Qt.rgba(0.15,0.25,0.35,0.65)
        elide: Text.ElideRight
        visible: root.subtitle.length > 0
        Layout.fillWidth: true
      }
    }

    // Right block: compact progress + button
    RowLayout {
      Layout.alignment: Qt.AlignVCenter
      spacing: 10
      visible: root.showProgress || root.showResetButton

      Glass {
        radius: 16
        glassOpacity: 0.14

        Layout.preferredWidth: 118
        Layout.preferredHeight: 40
        Layout.maximumHeight: 40
        Layout.alignment: Qt.AlignVCenter

        visible: root.showProgress

        Row {
          anchors.centerIn: parent
          spacing: 8

          Canvas {
            id: ring
            width: 18
            height: 18

            property real p: Math.max(0, Math.min(1, root.progressValue))
            onPChanged: requestPaint()

            onPaint: {
              var ctx = getContext("2d")
              ctx.reset()

              var cx = width / 2
              var cy = height / 2
              var r = Math.min(width, height) / 2 - 1.5

              // bg ring
              ctx.beginPath()
              ctx.lineWidth = 2.2
              ctx.strokeStyle = "rgba(60, 80, 100, 0.18)"
              ctx.arc(cx, cy, r, 0, Math.PI * 2, false)
              ctx.stroke()

              // progress ring
              var start = -Math.PI / 2
              var end = start + (Math.PI * 2 * p)
              ctx.beginPath()
              ctx.lineWidth = 2.2
              ctx.lineCap = "round"
              ctx.strokeStyle = "rgba(45, 95, 220, 0.80)"
              ctx.arc(cx, cy, r, start, end, false)
              ctx.stroke()
            }
          }

          Column {
            spacing: 1
            Text {
              text: "Progress"
              font.pixelSize: 10
              color: Qt.rgba(0.15,0.25,0.35,0.65)
            }
            Text {
              text: Math.round(Math.max(0, Math.min(1, root.progressValue)) * 100) + "%"
              font.pixelSize: 12
              font.weight: Font.DemiBold
              color: "#0b1520"
            }
          }
        }
      }

      SoftButton {
        text: "Сброс дня"
        Layout.preferredWidth: 118
        Layout.preferredHeight: 40
        Layout.maximumHeight: 40
        Layout.alignment: Qt.AlignVCenter

        visible: root.showResetButton
        onClicked: root.resetDay()
      }
    }
  }
}
