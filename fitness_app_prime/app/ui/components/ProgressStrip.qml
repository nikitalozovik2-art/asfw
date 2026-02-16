import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
  id: root
  property real value: 0.0 // 0..1

  // Чуть компактнее и ближе к рефу
  implicitHeight: 16

  Glass {
    anchors.fill: parent
    radius: 999
    glassOpacity: 0.08
  }

  Rectangle {
    anchors.fill: parent
    radius: 999
    color: "transparent"
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.24)
  }

  Rectangle {
    id: bar
    height: 8
    radius: 999
    anchors.left: parent.left
    anchors.leftMargin: 5
    anchors.verticalCenter: parent.verticalCenter

    width: Math.max(14, (parent.width - 10) * Math.max(0, Math.min(1, root.value)))

    gradient: Gradient {
      GradientStop { position: 0.0; color: "#FF5C7A" }
      GradientStop { position: 0.55; color: "#FF8FB3" }
      GradientStop { position: 1.0; color: "#7AA7FF" }
    }

    Rectangle {
      anchors.fill: parent
      radius: 999
      color: "#FFFFFF"
      opacity: 0.10
    }
  }
}
