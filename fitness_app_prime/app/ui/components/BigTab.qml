import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked()

    implicitHeight: 60
    implicitWidth: 170

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.active ? "#FFFFFF22" : "#FFFFFF14"
        border.width: 1
        border.color: root.active ? "#FFFFFF66" : "#FFFFFF22"
    }

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 2

        Text {
            text: root.title
            color: "white"
            font.pixelSize: 14
            font.bold: true
            elide: Text.ElideRight
        }

        Text {
            text: root.subtitle
            visible: root.subtitle.length > 0
            color: "#CCFFFFFF"
            font.pixelSize: 11
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
