import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
  id: root
  property real value: 0.08
  implicitHeight: 22

  Glass {
    anchors.fill: parent
    radius: 999
  opacity: 0.18
  }

  Rectangle {
    height: 14
    radius: 999
    anchors.left: parent.left
    anchors.leftMargin: 6
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(18, (parent.width - 12) * Math.max(0.01, Math.min(1.0, root.value)))
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#ff7a5a" }
      GradientStop { position: 1.0; color: "#ff56b3" }
    }
    opacity: 0.9
  }
}