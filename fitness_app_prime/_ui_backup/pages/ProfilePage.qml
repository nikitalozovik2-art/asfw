import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
  Layout.fillWidth: true
  Layout.fillHeight: true

  Glass { anchors.fill: parent; radius: 28; glassOpacity: 0.14 }

  Text {
    anchors.centerIn: parent
    text: "Профиль (скоро)"
    font.pixelSize: 20
    font.weight: Font.DemiBold
    color: "#0b1520"
  }
}