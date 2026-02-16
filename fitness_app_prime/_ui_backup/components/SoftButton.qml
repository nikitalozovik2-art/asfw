import QtQuick 2.15
import QtQuick.Controls 2.15

Control {
  id: root
  property string text: "Button"
  property bool active: false
  signal clicked()

  implicitWidth: 200
  implicitHeight: 44

  background: Rectangle {
    radius: 18
    color: root.active ? Qt.rgba(1,1,1,0.95) : Qt.rgba(1,1,1,0.55)
    border.width: 1
    border.color: root.active ? Qt.rgba(0.25,0.55,1.0,0.45) : Qt.rgba(1,1,1,0.35)
  }

  contentItem: Text {
    text: root.text
    color: "#0b1520"
    font.pixelSize: 14
    font.weight: Font.DemiBold
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}