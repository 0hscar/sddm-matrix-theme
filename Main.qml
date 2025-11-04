import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920 // fallback, will be overridden by SDDM
    height: 1080
    color: "black"

    // --- Detect monitor by resolution ---
    property bool isPortraitMonitor: root.width === 1920 && root.height === 1080
    property bool isMain4k: root.width === 3840 && root.height === 2160

    // --- MATRIX RAIN (rotates only on portrait monitor) ---
    Item {
        id: rainRoot
        anchors.fill: parent
        z: 1

        property var katakana: [
            "ｱ","ｲ","ｳ","ｴ","ｵ","ｶ","ｷ","ｸ","ｹ","ｺ","ｻ","ｼ","ｽ","ｾ","ｿ",
            "ﾀ","ﾁ","ﾂ","ﾃ","ﾄ","ﾅ","ﾆ","ﾇ","ﾈ","ﾉ","ﾊ","ﾋ","ﾌ","ﾍ","ﾎ",
            "ﾏ","ﾐ","ﾑ","ﾒ","ﾓ","ﾔ","ﾕ","ﾖ","ﾗ","ﾘ","ﾙ","ﾚ","ﾛ","ﾜ","ｦ",
            "ﾝ","0","1","2","3","4","5","6","7","8","9","@","#","$","%"
        ]

        property int rainWidth: isPortraitMonitor ? root.height : root.width
        property int rainHeight: isPortraitMonitor ? root.width : root.height
        property int numColumns: Math.floor(rainWidth / 18)
        property int numChars: Math.floor(rainHeight / 28)
        property int trailLength: 12

        Item {
            id: rainContent
            width: rainRoot.rainWidth
            height: rainRoot.rainHeight
            anchors.centerIn: parent
            rotation: isPortraitMonitor ? 90 : 0

            Repeater {
                model: rainRoot.numColumns
                delegate: Item {
                    id: col
                    width: Math.ceil(rainContent.width / rainRoot.numColumns)
                    height: rainContent.height
                    x: col.width * index

                    // Start at a random position in the drop cycle for each column
                    property real head: Math.random() * (rainRoot.numChars + rainRoot.trailLength * 2) - rainRoot.trailLength

                    Timer {
                        interval: 60 + Math.random()*80
                        running: true
                        repeat: true
                        onTriggered: {
                            col.head = (col.head + 0.08 + Math.random()*0.05) % rainRoot.numChars
                        }
                    }

                    Column {
                        id: charColumn
                        width: parent.width
                        height: parent.height
                        spacing: 0

                        Repeater {
                            model: rainRoot.numChars
                            delegate: Text {
                                property int rowIndex: index
                                property int d: rowIndex - Math.floor(col.head)
                                text: rainRoot.katakana[Math.floor(Math.random() * rainRoot.katakana.length)]
                                font.pixelSize: 22
                                color: d === 0
                                    ? Qt.rgba(0.7, 1, 0.7, 1) // brightest green head
                                    : d < 0 && -d <= rainRoot.trailLength
                                        ? Qt.rgba(0, 1, 0, Math.max(0, 1 + d/rainRoot.trailLength))
                                        : Qt.rgba(0, 1, 0, 0)
                                opacity: 1
                                Timer {
                                    interval: 400
                                    running: true
                                    repeat: true
                                    onTriggered: {
                                        if (Math.random() < 0.15 || d === 0)
                                            parent.text = rainRoot.katakana[Math.floor(Math.random() * rainRoot.katakana.length)]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- LOGIN PANEL (only on main 4K, solid black, not rotated, with fade-in) ---
    Rectangle {
        id: loginPanel
        width: 700
        height: 380
        color: "black"
        radius: 16
        border.color: "#00ff00"
        border.width: 2
        anchors.centerIn: parent
        z: 10
        visible: isMain4k
        opacity: isMain4k ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 1200; easing.type: Easing.InOutQuad } }

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width * 0.85

            Text {
                text: "Boombox goes Wroom Wroom" // dealers choice
                color: "#00ff00"
                font.pixelSize: 32
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "USERNAME" // change to own username or manually insert it. too lazy for that
                color: "#00ff00"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: password
                placeholderText: "Password"
                echoMode: TextInput.Password
                color: "#00ff00"
                placeholderTextColor: "#008000"
                font.pixelSize: 22
                width: parent.width
                background: Rectangle { color: "#001100"; radius: 6 }
                focus: true
                Keys.onReturnPressed: loginButton.clicked()
            }

            Button {
                id: loginButton
                text: "LOGIN"
                font.pixelSize: 22
                width: parent.width
                property bool hoveredBtn: false
                background: Rectangle {
                    radius: 8
                    color: loginButton.hoveredBtn ? "#00ff00" : "#002200"
                    border.color: "#00ff00"
                    border.width: 2

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: loginButton.hoveredBtn = true
                        onExited: loginButton.hoveredBtn = false
                        onClicked: loginButton.clicked()
                    }
                }
                onClicked: {
                    if (typeof sddm !== "undefined")
                        sddm.login("USERNAME", password.text, "hyprland.desktop")
                }
            }
        }
    }

    // --- POWER BUTTONS (bottom right, only on main 4K) ---
    Row {
        spacing: 12
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 40
        z: 100
        visible: isMain4k

        Repeater {
            model: [
                { name: "SHUTDOWN", action: function(){ if (typeof sddm !== "undefined") sddm.powerOff(); } },
                { name: "REBOOT", action: function(){ if (typeof sddm !== "undefined") sddm.reboot(); } },
                { name: "SUSPEND", action: function(){ if (typeof sddm !== "undefined") sddm.suspend(); } }
            ]

            delegate: Rectangle {
                width: 120
                height: 44
                radius: 8
                property bool hovered: false
                color: hovered ? "#00ff00" : "#002200"
                border.color: "#00ff00"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    color: hovered ? "#000000" : "#00ff00"
                    font.pixelSize: 16
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: modelData.action()
                }
            }
        }
    }

    // --- DEBUG OVERLAY: Always on top, outlined, large ---
    /*
    Rectangle {
        width: 900
        height: 140
        color: "red"
        opacity: 0.7
        border.color: "yellow"
        border.width: 4
        anchors.left: parent.left
        anchors.top: parent.top
        z: 99998

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Text {
                text: "root.width: " + root.width
                color: "white"
                font.pixelSize: 28
                font.family: "monospace"
                style: Text.Outline
                styleColor: "black"
            }
            Text {
                text: "root.height: " + root.height
                color: "white"
                font.pixelSize: 28
                font.family: "monospace"
                style: Text.Outline
                styleColor: "black"
            }
            Text {
                text: "isPortraitMonitor: " + isPortraitMonitor
                color: "yellow"
                font.pixelSize: 24
                font.family: "monospace"
                style: Text.Outline
                styleColor: "black"
            }
            Text {
                text: "isMain4k: " + isMain4k
                color: "yellow"
                font.pixelSize: 24
                font.family: "monospace"
                style: Text.Outline
                styleColor: "black"
            }
        }
    }
    */
}
