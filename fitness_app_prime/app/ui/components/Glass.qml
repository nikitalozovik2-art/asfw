import QtQuick 2.15

Item {
  id: root

  property real radius: 22
  property real padding: 16

  // ВАЖНО:
  // glassOpacity = ПРОЗРАЧНОСТЬ (0.10..0.20) — то есть 10-20% прозрачности.
  // Раньше было наоборот, поэтому всё выглядело слишком "прозрачным".
  property real glassOpacity: 0.14

  property color tint: "#FFFFFF"
  property color borderColor: "#FFFFFF"
  property real borderWidth: 1
  property real borderOpacity: 0.22

  default property alias content: contentItem.data

  implicitWidth: 360
  implicitHeight: 160

  Rectangle {
    id: card
    anchors.fill: parent
    radius: root.radius

    // почти белый (1 - прозрачность)
    color: Qt.rgba(1, 1, 1, Math.max(0.0, Math.min(1.0, 1.0 - root.glassOpacity)))

    border.width: root.borderWidth
    border.color: Qt.rgba(1, 1, 1, root.borderOpacity)

    // мягкий хайлайт сверху
    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      height: Math.max(1, parent.height * 0.38)
      radius: root.radius
      color: "#FFFFFF"
      opacity: 0.10
      clip: true
    }
  }

  Item {
    id: contentItem
    anchors.fill: parent
    anchors.margins: root.padding
  }
}
