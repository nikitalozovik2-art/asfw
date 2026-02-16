import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
  id: root
  property string text: "Pill"
  property bool active: false

  radius: 999
  height: 30
  width: Math.max(84, label.implicitWidth + 26)
  color: active ? "#ffffff" : Qt.rgba(1,1,1,0.30)
  border.width: 1
  border.color: Qt.rgba(1,1,1,0.35)

  Text {
    id: label
    anchors.centerIn: parent
    text: root.text
    color: "#1a2b3a"
    font.pixelSize: 12
    font.weight: Font.DemiBold
  }
}