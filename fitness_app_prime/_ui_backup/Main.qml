import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "components"
import "pages"

ApplicationWindow {
  id: win
  visible: true
  width: 1440
  height: 860
  title: "Fitness App Prime"

  Rectangle {
    anchors.fill: parent
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#cfefff" }
      GradientStop { position: 0.55; color: "#e5ddff" }
      GradientStop { position: 1.0; color: "#ffd9ef" }
    }

    RowLayout {
      anchors.fill: parent
      anchors.margins: 18
      spacing: 16
      Sidebar {
        id: sidebar
        Layout.preferredWidth: 92
        // если Sidebar.qml шлёт index -> сюда приходит i
        onNavigate: function(i) { stack.currentIndex = i }
      }

ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 14

        TopHeader {
          id: top
          Layout.fillWidth: true
          title: "Training Upper Body"
          subtitle: "100 кг  183 см  Жим 47.5 кг  Армейский 27.5 кг"
          progressValue: 0.0
          onResetDay: console.log("reset day")
        }

        ProgressStrip {
          Layout.fillWidth: true
          value: 0.08
        }

        StackLayout {
          id: stack
          Layout.fillWidth: true
          Layout.fillHeight: true
          currentIndex: 1

          HomePage { }
          TrainingPage { }
          ProgressPage { }
          NutritionPage { }
          ProfilePage { }
        }
      }
    }
  }
}