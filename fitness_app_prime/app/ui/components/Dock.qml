import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    height: 84

    // 0 Home, 1 Training, 2 Nutrition, 3 Progress, 4 Profile
    property int currentIndex: 0
    signal navigate(int idx)

    Rectangle {
        id: bar
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        radius: 22
        color: "#0B0F18"
        opacity: 0.82
        border.width: 1
        border.color: "#2A3550"

        // subtle top highlight
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            opacity: 0.35
            color: "#7FA6FF"
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 18

        DockButton { text: "Home"; active: root.currentIndex === 0; onClicked: root.navigate(0) }
        DockButton { text: "Training"; active: root.currentIndex === 1; onClicked: root.navigate(1) }
        DockButton { text: "Nutrition"; active: root.currentIndex === 2; onClicked: root.navigate(2) }
        DockButton { text: "Progress"; active: root.currentIndex === 3; onClicked: root.navigate(3) }
        DockButton { text: "Profile"; active: root.currentIndex === 4; onClicked: root.navigate(4) }
    }
}
