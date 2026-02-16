import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "components" as C
import "pages" as P

ApplicationWindow {
    id: win
    width: 1365
    height: 768
    visible: true
    title: "Fitness App Prime"
    color: "#0B1220"

    // 0 Home, 1 Training, 2 Nutrition, 3 Progress, 4 Profile
    property int pageIndex: 0

    Rectangle {
        anchors.fill: parent
        color: "#0B1220"

        // Background gradient
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#0A1626" }
                GradientStop { position: 0.55; color: "#07121F" }
                GradientStop { position: 1.0; color: "#050A12" }
            }
        }

        // Soft spotlight bottom-center
        Rectangle {
            width: parent.width * 0.75
            height: parent.height * 0.75
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height * 0.25
            radius: width
            opacity: 0.22
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#9AA7FF" }
                GradientStop { position: 0.45; color: "#5B66D6" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        StackLayout {
            id: stack
            anchors.fill: parent
            anchors.bottomMargin: 120
            currentIndex: win.pageIndex

            P.HomePage {
                onOpenTraining: win.pageIndex = 1
                onOpenNutrition: win.pageIndex = 2
                onOpenProgress: win.pageIndex = 3
                onOpenProfile:  win.pageIndex = 4
            }

            P.TrainingPage { }
            P.NutritionPage { }
            P.ProgressPage { }
            P.ProfilePage { }
        }

        // ✅ Dock через Loader: ошибки Dock больше не валят Main.qml
        Loader {
            id: dockLoader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
            active: true
            sourceComponent: dockComponent
        }

        Component {
            id: dockComponent
            C.Dock {
                currentIndex: win.pageIndex
                onNavigate: function(idx) { win.pageIndex = idx }
            }
        }
    }
}
