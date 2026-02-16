import QtQuick 2.15

Item {
    id: btn

    property string text: ""
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
        onExited: pill.scale = 1.0
    }
}
