/* Nusantara OS SDDM Theme — Merah Putih, Garuda-style
 * Warna: charcoal #0b0e14 + merah #e11d48 + putih #f8fafc
 * Berdasar maldives + dr460nized pattern
 */
import QtQuick 2.0
import QtQuick.Controls 2.0
import SddmComponents 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#0b0e14"

    // user default terpilih
    Component.onCompleted: {
        if (userModel.lastIndex >= 0)
            userModel.currentIndex = userModel.lastIndex
    }

    property string selectedUser: userModel.currentUser

    // Pola background Garuda-style: gradient + glow merah + pola diagonal
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0b0e14" }
            GradientStop { position: 0.6; color: "#131826" }
            GradientStop { position: 1.0; color: "#1e0a12" }
        }
        opacity: 0.98
    }

    // Glow merah tengah
    Rectangle {
        x: parent.width/2 - 320
        y: parent.height/2 - 320
        width: 640; height: 640
        radius: 320
        color: "#e11d48"
        opacity: 0.08
        layer.enabled: true
        layer.effect: FastBlur { radius: 60 }
    }

    // Pola diagonal halus ala dr460nized
    Repeater {
        model: 18
        delegate: Rectangle {
            x: index * 90
            y: -100
            width: 2
            height: parent.height + 200
            color: "#ffffff"
            opacity: 0.06
            rotation: 18
        }
    }

    // Logo Nusantara (SVG di pixmaps)
    Image {
        source: "file:///usr/share/pixmaps/nusantaraos.svg"
        width: 96; height: 96
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.08
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
        layer.effect: DropShadow {
            cached: false
            radius: 12
            samples: 16
            color: "#e11d48"
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.08 + 110
        text: "NUSANTARA OS"
        color: "#f8fafc"
        font.pixelSize: 28
        font.family: "Inter, Noto Sans"
        font.bold: true
        font.letterSpacing: 6
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.08 + 146
        text: "GARUDA-STYLE  •  ARCH  •  BTRFS  •  KDE"
        color: "#f43f5e"
        font.pixelSize: 11
        font.family: "Inter, Noto Sans"
        font.letterSpacing: 3
    }

    // Box login gelas kaca
    Rectangle {
        id: loginBox
        width: 380
        height: 260
        anchors.centerIn: parent
        anchors.topMargin: 80
        radius: 18
        color: "#ffffff"
        opacity: 0.06
        border.color: "#ffffff"
        border.width: 1
        border.opacity: 0.12
        layer.enabled: true
        layer.effect: FastBlur { radius: 20 }
    }

    Column {
        anchors.centerIn: parent
        anchors.topMargin: 80
        spacing: 12
        width: 320

        // Daftar user
        ComboBox {
            width: parent.width
            height: 42
            model: userModel
            currentIndex: userModel.currentIndex
            onCurrentIndexChanged: loginBox.selectedUser = model.name
            background: Rectangle { color: "#ffffff"; opacity: 0.10; radius: 10; border.color: "#f43f5e"; border.width: 1 }
            textRole: "name"
        }

        TextField {
            id: passwordField
            width: parent.width
            height: 42
            echoMode: TextInput.Password
            placeholderText: "Password"
            color: "#f8fafc"
            placeholderTextColor: "#94a3b8"
            font.family: "Inter"
            font.pixelSize: 14
            background: Rectangle { color: "#000000"; opacity: 0.35; radius: 10; border.color: "#ffffff"; border.width: 1; border.opacity: 0.15 }
            Keys.onReturnPressed: tryLogin()
            Keys.onEscapePressed: passwordField.clear()
        }

        Button {
            width: parent.width
            height: 44
            text: "Login"
            background: Rectangle {
                color: pressed ? "#9f1239" : "#e11d48"
                radius: 10
                border.color: "#fb7185"
            }
            contentItem: Text { text: parent.text; color: "#ffffff"; font.bold: true; font.family: "Inter"; anchors.centerIn: parent; font.pixelSize: 15 }
            onClicked: tryLogin()
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignCenter
            text: loginBox.selectedUser ? "Login sebagai " + loginBox.selectedUser : ""
            color: "#94a3b8"
            font.pixelSize: 12
        }
    }

    // Jam & tanggal di pojok
    Column {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 28
        spacing: 4
        Text {
            text: Qt.formatTime(new Date(), "hh:mm")
            color: "#f8fafc"
            font.pixelSize: 38
            font.bold: true
            anchors.right: parent.right
        }
        Text {
            text: Qt.formatDate(new Date(), "dddd, dd MMMM yyyy")
            color: "#94a3b8"
            font.pixelSize: 12
            anchors.right: parent.right
        }
    }

    // Footer
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 18
        text: "Nusantara OS  •  Merdeka  •  2026"
        color: "#64748b"
        font.pixelSize: 11
        font.letterSpacing: 2
    }

    // Power buttons: Reboot & Shutdown (basics dari maldives)
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 10
        Button { text: "⟳ Reboot"; onClicked: root.powerButton.click() }
        Button { text: "⏻ Shutdown"; onClicked: root.shutdownButton.click() }
    }

    function tryLogin() {
        sddm.login(userModel.currentUser, passwordField.text, sddm.sessionId)
    }
}
