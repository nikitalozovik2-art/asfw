import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    signal openTraining()
    signal openNutrition()
    signal openProgress()
    signal openProfile()

    Column {
        anchors.centerIn: parent
        spacing: 18
        width: 860

        Column {
            spacing: 6
            Text {
                text: "Ready for today?"
                color: "#F2F6FF"
                font.pixelSize: 42
                font.weight: Font.Bold
            }
            Text {
                text: "Choose what you want to focus on."
                color: "#A9B6D1"
                font.pixelSize: 14
            }
        }

        GridLayout {
            columns: 2
            columnSpacing: 22
            rowSpacing: 22
            width: parent.width

            HomeCard {
                title: "Training"
                subtitle: "Start a session, follow the plan, track progress."
                onOpen: root.openTraining()
            }
            HomeCard {
                title: "Nutrition"
                subtitle: "Macros, meals, and daily targets."
                onOpen: root.openNutrition()
            }
            HomeCard {
                title: "Progress"
                subtitle: "Charts, streaks, and history."
                onOpen: root.openProgress()
            }
            HomeCard {
                title: "Profile"
                subtitle: "Personal settings and preferences."
                onOpen: root.openProfile()
            }
        }
    }

    component HomeCard: Item {
        id: card
        property string title: ""
        property string subtitle: ""
        signal open()

        Layout.fillWidth: true
        height: 180

        Rectangle {
            id: bg
            anchors.fill: parent
            radius: 18
            color: "#1A2335"
            opacity: 0.72
            border.width: 1
            border.color: "#2D3A55"

            // soft inner glow hint
            Rectangle {
                anchors.fill: parent
                radius: 18
                opacity: 0.22
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#6C8CFF" }
                    GradientStop { position: 0.55; color: "transparent" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            Behavior on scale { NumberAnimation { duration: 160 } }
            Behavior on border.color { ColorAnimation { duration: 160 } }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 18
            spacing: 8

            Text {
                text: card.title
                color: "#F2F6FF"
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }
            Text {
                text: card.subtitle
                wrapMode: Text.WordWrap
                color: "#A9B6D1"
                font.pixelSize: 12
                opacity: 0.95
            }
        }

        Button {
            id: openBtn
            text: "Open"
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 18
            width: 160
            height: 38

            background: Rectangle {
                radius: 12
                color: "#C7CBD4"
                opacity: openBtn.down ? 0.85 : (openBtn.hovered ? 0.98 : 0.92)
                border.width: 1
                border.color: "#E6E9F0"
            }
            contentItem: Text {
                text: openBtn.text
                color: "#0E1320"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: card.open()
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
                bg.scale = 1.02
                bg.border.color = "#6C8CFF"
            }
            onExited: {
                bg.scale = 1.0
                bg.border.color = "#2D3A55"
            }
            onClicked: card.open()
        }
    }
}
