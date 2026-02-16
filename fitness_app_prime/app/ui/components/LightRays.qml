import QtQuick 2.15

Item {
    id: root
    anchors.fill: parent

    // Public API (как в твоём React-примере)
    // origin: "top-center" | "top-left" | "top-right" | "left" | "right" | "bottom-center" | ...
    property string raysOrigin: "top-center"
    property color raysColor: "#ffffff"
    property real raysSpeed: 1.0
    property real lightSpread: 0.5
    property real rayLength: 3.0
    property bool followMouse: true
    property real mouseInfluence: 0.10
    property real noiseAmount: 0.0
    property real distortion: 0.0
    property bool pulsating: false
    property real fadeDistance: 1.0
    property real saturation: 1.0

    // Internal
    property real _t: 0.0
    property point _mouseNorm: Qt.point(0.5, 0.5)     // 0..1
    property point _rayPosPx: Qt.point(width * 0.5, -height * 0.2)
    property point _rayDirPx: Qt.point(0, 1)

    // Timer for iTime
    Timer {
        id: tick
        interval: 16
        running: true
        repeat: true
        onTriggered: root._t += 0.016 * root.raysSpeed
    }

    // Mouse tracking (hover only)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: {
            if (!root.followMouse) return;
            // normalize 0..1
            var nx = Math.max(0, Math.min(1, mouse.x / Math.max(1, width)));
            var ny = Math.max(0, Math.min(1, mouse.y / Math.max(1, height)));
            root._mouseNorm = Qt.point(nx, ny);
        }
    }

    function _computeAnchorAndDir(origin, w, h) {
        var outside = 0.20;
        switch (origin) {
        case "top-left":
            return { anchor: Qt.point(0, -outside * h), dir: Qt.point(0, 1) };
        case "top-right":
            return { anchor: Qt.point(w, -outside * h), dir: Qt.point(0, 1) };
        case "left":
            return { anchor: Qt.point(-outside * w, 0.5 * h), dir: Qt.point(1, 0) };
        case "right":
            return { anchor: Qt.point((1 + outside) * w, 0.5 * h), dir: Qt.point(-1, 0) };
        case "bottom-left":
            return { anchor: Qt.point(0, (1 + outside) * h), dir: Qt.point(0, -1) };
        case "bottom-center":
            return { anchor: Qt.point(0.5 * w, (1 + outside) * h), dir: Qt.point(0, -1) };
        case "bottom-right":
            return { anchor: Qt.point(w, (1 + outside) * h), dir: Qt.point(0, -1) };
        default: // "top-center"
            return { anchor: Qt.point(0.5 * w, -outside * h), dir: Qt.point(0, 1) };
        }
    }

    function _updatePlacement() {
        var r = _computeAnchorAndDir(root.raysOrigin, root.width, root.height);
        root._rayPosPx = r.anchor;
        root._rayDirPx = r.dir;
    }

    onWidthChanged: _updatePlacement()
    onHeightChanged: _updatePlacement()
    onRaysOriginChanged: _updatePlacement()

    Component.onCompleted: _updatePlacement()

    // ShaderEffect (uses compiled .qsb)
    ShaderEffect {
        id: fx
        anchors.fill: parent
        blending: true

        // IMPORTANT: qsb path
        fragmentShader: Qt.resolvedUrl("../shaders/light_rays.frag.qsb")

        // uniforms mapping
        property real iTime: root._t
        property vector2d iResolution: Qt.vector2d(root.width, root.height)

        property vector2d rayPos: Qt.vector2d(root._rayPosPx.x, root._rayPosPx.y)
        property vector2d rayDir: Qt.vector2d(root._rayDirPx.x, root._rayDirPx.y)

        property vector3d raysColor: Qt.vector3d(
            Qt.rgba(root.raysColor.r, root.raysColor.g, root.raysColor.b, 1).r,
            Qt.rgba(root.raysColor.r, root.raysColor.g, root.raysColor.b, 1).g,
            Qt.rgba(root.raysColor.r, root.raysColor.g, root.raysColor.b, 1).b
        )

        property real raysSpeed: 1.0           // скорость уже учтена в iTime (root._t += dt * raysSpeed)
        property real lightSpread: root.lightSpread
        property real rayLength: root.rayLength
        property real pulsating: root.pulsating ? 1.0 : 0.0
        property real fadeDistance: root.fadeDistance
        property real saturation: root.saturation

        property vector2d mousePos: Qt.vector2d(root._mouseNorm.x, root._mouseNorm.y)
        property real mouseInfluence: root.followMouse ? root.mouseInfluence : 0.0
        property real noiseAmount: root.noiseAmount
        property real distortion: root.distortion
    }
}
