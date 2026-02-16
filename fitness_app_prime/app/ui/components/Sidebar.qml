import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 72
    height: parent ? parent.height : 600

    property int currentIndex: 1
    signal navigate(int index)

    // ЕДИНЫЕ размеры для всех пунктов
    readonly property int btnSize: 54
    readonly property int iconSize: 44   // было 36 → делаем заметно больше
    readonly property int radius: 18

    // ПОРЯДОК КАК ТЫ ХОЧЕШЬ:
    // 1 Home, 2 Training, 3 Nutrition, 4 Progress, 5 Profile
    readonly property var items: [
        { idx: 0, label: "Home",      icon: "../assets/icons_png/home.png" },
        { idx: 1, label: "Training",  icon: "../assets/icons_png/training.png" },
        { idx: 3, label: "Nutrition", icon: "../assets/icons_png/nutrition.png" },
        { idx: 2, label: "Progress",  icon: "../assets/icons_png/progress.png" },
        { idx: 4, label: "Profile",   icon: "../assets/icons_png/profile.png" }
    ]

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: Qt.rgba(1, 1, 1, 0.14)
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.05)
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 18
        spacing: 14

        Repeater {
            model: root.items

            delegate: Item {
                width: root.btnSize
                height: root.btnSize

                property bool active: root.currentIndex === modelData.idx

                Rectangle {
                    anchors.fill: parent
                    radius: root.radius
                    color: active ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.10)
                    border.width: 1
                    border.color: active ? Qt.rgba(0, 0, 0, 0.12) : Qt.rgba(0, 0, 0, 0.06)

                    Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
                    Behavior on border.color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
                }

                Image {
                    anchors.centerIn: parent
                    width: root.iconSize
                    height: root.iconSize
                    source: modelData.icon
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: active ? 1.0 : 0.92
                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    ToolTip.visible: containsMouse
                    ToolTip.text: modelData.label
                    ToolTip.delay: 120
                    ToolTip.timeout: 1200

                    onClicked: root.navigate(modelData.idx)
                }
            }
        }
    }
}
