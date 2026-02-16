import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
  id: root
  property int currentIndex: 1
  signal navigate(int index)

  // подстройка "чуть выше середины"
  property int verticalOffset: -70

  width: 92

  // фон панели
  Rectangle {
    id: panel
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: 92
    radius: 28
    color: Qt.rgba(1,1,1,0.34)
    border.width: 1
    border.color: Qt.rgba(1,1,1,0.55)
  }

  Column {
    id: col
    anchors.horizontalCenter: panel.horizontalCenter
    anchors.verticalCenter: panel.verticalCenter
    anchors.verticalCenterOffset: root.verticalOffset
    spacing: 10

    SidebarButton { idx: 0; label: "Home";      glyph: "\uE80F" } // home
    SidebarButton { idx: 1; label: "Training";  glyph: "\uEADA" } // dumbbell-ish (если не нравится — поменяем)
    SidebarButton { idx: 2; label: "Progress";  glyph: "\uE9D2" } // chart
    SidebarButton { idx: 3; label: "Nutrition"; glyph: "\uE790" } // food-ish
    SidebarButton { idx: 4; label: "Profile";   glyph: "\uE77B" } // contact/user
    SidebarButton { idx: 5; label: "More";      glyph: "\uE712" } // dots/settings
  }

  component SidebarButton: Item {
    id: b
    property int idx: 0
    property string label: ""
    property string glyph: ""
    width: 56
    height: 56

    // круг
    Rectangle {
      id: circle
      anchors.fill: parent
      radius: 999
      color: (root.currentIndex === b.idx) ? Qt.rgba(0.35,0.55,1.0,0.80) : Qt.rgba(1,1,1,0.42)
      border.width: 1
      border.color: (root.currentIndex === b.idx) ? Qt.rgba(1,1,1,0.70) : Qt.rgba(1,1,1,0.55)

      Behavior on color { NumberAnimation { duration: 160 } }
    }

    // иконка (НЕ эмодзи)
    Text {
      anchors.centerIn: parent
      text: b.glyph
      font.family: "Segoe MDL2 Assets"
      font.pixelSize: 20
      color: (root.currentIndex === b.idx) ? "#ffffff" : "#1e2a3a"
      opacity: (root.currentIndex === b.idx) ? 1.0 : 0.92
      Behavior on color { ColorAnimation { duration: 160 } }
    }

    // hover tooltip (плавно)
    Rectangle {
      id: tip
      visible: ma.containsMouse
      opacity: ma.containsMouse ? 1 : 0
      anchors.left: parent.right
      anchors.leftMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      radius: 12
      color: Qt.rgba(1,1,1,0.92)
      border.width: 1
      border.color: Qt.rgba(0.85,0.90,1.0,0.9)

      Behavior on opacity { NumberAnimation { duration: 140 } }
      Behavior on anchors.leftMargin { NumberAnimation { duration: 140 } }

      // “не резко”: чуть выезжает
      anchors.leftMargin: ma.containsMouse ? 14 : 10

      Text {
        anchors.margins: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: b.label
        color: "#0b1520"
        font.pixelSize: 13
        font.weight: 600
      }
    }

    MouseArea {
      id: ma
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        root.currentIndex = b.idx
        root.navigate(b.idx)
      }
    }
  }
}