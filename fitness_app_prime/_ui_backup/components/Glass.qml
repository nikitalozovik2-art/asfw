import QtQuick 2.15

Item {
  id: root
  // внешний API
  property real radius: 28
  property real opacityValue: 0.38   // было слишком прозрачно -> делаем плотнее
  property color tint: "#FFFFFF"
  property real borderOpacity: 0.55

  anchors.fill: parent

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: root.tint
    opacity: root.opacityValue
    border.width: 1
    border.color: Qt.rgba(1,1,1, root.borderOpacity)
  }

  // лёгкая подложка-градиент, чтобы выглядело "премиально" как в web
  Rectangle {
    anchors.fill: parent
    radius: root.radius
    gradient: Gradient {
      GradientStop { position: 0.0; color: Qt.rgba(1,1,1, 0.18) }
      GradientStop { position: 1.0; color: Qt.rgba(1,1,1, 0.06) }
    }
    border.width: 0
  }
}