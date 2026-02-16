import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
  Layout.fillWidth: true
  Layout.fillHeight: true

  Glass { anchors.fill: parent; radius: 26; glassOpacity: 0.20 }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 18
    spacing: 12

    Text { text: "Профиль (демо)"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#0b1520" }
  }
}