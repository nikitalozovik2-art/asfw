import QtQuick 2.15

Item {
  id: root
  anchors.fill: parent
  clip: true

  // Public API
  property string raysOrigin: "top-center"   // пока поддержим top-center
  property color  raysColor: "#ffffff"
  property real   raysSpeed: 1.15
  property real   lightSpread: 0.50
  property real   rayLength: 3.0
  property bool   followMouse: true
  property real   mouseInfluence: 0.10
  property real   noiseAmount: 0.0
  property real   distortion: 0.0
  property bool   pulsating: false
  property real   fadeDistance: 1.0
  property real   saturation: 1.0

  // Internal smooth mouse
  property real _mxTarget: 0.5
  property real _myTarget: 0.2
  property real _mxSmooth: 0.5
  property real _mySmooth: 0.2

  // Time (seconds)
  property real time: 0.0

  // move only in X (как “лампа”)
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    enabled: root.followMouse
    onPositionChanged: {
      root._mxTarget = mouse.x / Math.max(1, width)
      root._myTarget = mouse.y / Math.max(1, height)
    }
  }

  Timer {
    interval: 16
    running: true
    repeat: true
    onTriggered: {
      // smoothing
      root._mxSmooth = root._mxSmooth + (root._mxTarget - root._mxSmooth) * root.mouseInfluence
      root._mySmooth = root._mySmooth + (root._myTarget - root._mySmooth) * root.mouseInfluence

      root.time += 0.016 * root.raysSpeed
    }
  }

  ShaderEffect {
    id: fx
    anchors.fill: parent

    // ВАЖНО: это будет .qsb
    fragmentShader: "file:///C:/Users/onesh/OneDrive/Desktop/fitness_app_prime/app/ui/shaders/light_rays.frag.qsb"

    // uniforms
    property real iTime: root.time
    property vector2d iResolution: Qt.vector2d(width, height)

    // ray origin/direction (top-center)
    // anchor чуть выше экрана, dir вниз
    property vector2d rayPos: Qt.vector2d(width * 0.5, -height * 0.20)
    property vector2d rayDir: Qt.vector2d(0.0, 1.0)

    // mousePos (0..1)
    property vector2d mousePos: Qt.vector2d(root._mxSmooth, root._mySmooth)

    property vector3d raysColor: Qt.vector3d(
      (Qt.rgba(root.raysColor.r, root.raysColor.g, root.raysColor.b, 1).r),
      (Qt.rgba(root.raysColor.r, root.raysColor.g, root.raysColor.b, 1).g),
      (Qt.rgba(root.raysColor.r, root.raysColor.g, root.raysColor.b, 1).b)
    )

    property real raysSpeed: root.raysSpeed
    property real lightSpread: root.lightSpread
    property real rayLength: root.rayLength
    property real pulsating: root.pulsating ? 1.0 : 0.0
    property real fadeDistance: root.fadeDistance
    property real saturation: root.saturation
    property real mouseInfluence: root.followMouse ? root.mouseInfluence : 0.0
    property real noiseAmount: root.noiseAmount
    property real distortion: root.distortion
  }
}
