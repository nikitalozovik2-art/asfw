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

        DockButton { text: "Home";     idx: 0; active: root.currentIndex === 0; onClicked: root.navigate(0) }
        DockButton { text: "Training"; idx: 1; active: root.currentIndex === 1; onClicked: root.navigate(1) }
        DockButton { text: "Nutrition";idx: 2; active: root.currentIndex === 2; onClicked: root.navigate(2) }
        DockButton { text: "Progress"; idx: 3; active: root.currentIndex === 3; onClicked: root.navigate(3) }
        DockButton { text: "Profile";  idx: 4; active: root.currentIndex === 4; onClicked: root.navigate(4) }
    }

    component DockButton: Item {
        id: btn
        property string text: ""
        property int idx: 0
        property bool active: false
        signal clicked()

        width: 66
        height: 54

        Rectangle {
            id: pill
            anchors.fill: parent
            radius: 14
            color: btn.active ? "#131C2D" : "#0D1320"
            border.width: 1
            border.color: btn.active ? "#6C8CFF" : "#25314A"
            opacity: 0.98

            Behavior on color { ColorAnimation { duration: 160 } }
            Behavior on border.color { ColorAnimation { duration: 160 } }
            Behavior on scale { NumberAnimation { duration: 140 } }
        }

        Text {
            anchors.centerIn: parent
            text: btn.text
            color: btn.active ? "#EAF0FF" : "#B9C3DA"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            Behavior on color { ColorAnimation { duration: 160 } }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()

            onEntered: pill.scale = 1.06
            onExited:  pill.scale = 1.0
        }
    }
}
