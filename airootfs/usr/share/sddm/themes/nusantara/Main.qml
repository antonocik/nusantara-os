/* Nusantara OS — tema SDDM "Merah Putih"
 * Warna: charcoal #0b0e14, merah #e11d48, putih #f8fafc
 *
 * Ditulis ulang untuk SDDM 0.21 / Qt6:
 *  - tanpa QtGraphicalEffects (dihapus di Qt6)
 *  - memakai komponen resmi SddmComponents 2.0 (TextBox/ComboBox/Button/Clock)
 *  - user dipilih lewat userModel.lastUser (SDDM tidak punya currentUser)
 */
import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0b0e14"

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = "#22c55e"
            errorMessage.text = textConstants.loginSucceeded
        }
        onLoginFailed: {
            password.text = ""
            errorMessage.color = "#f43f5e"
            errorMessage.text = textConstants.loginFailed
        }
        onInformationMessage: {
            errorMessage.color = "#f43f5e"
            errorMessage.text = message
        }
    }

    // ---- latar: gradient charcoal -> merah gelap ----
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#0b0e14" }
            GradientStop { position: 0.55; color: "#131826" }
            GradientStop { position: 1.00; color: "#1e0a12" }
        }
    }

    // garis diagonal halus (pola khas Nusantara)
    Repeater {
        model: 22
        delegate: Rectangle {
            x: index * 120 - 240
            y: -200
            width: 2
            height: root.height + 400
            color: "#ffffff"
            opacity: 0.045
            rotation: 18
        }
    }

    // ---- logo & judul ----
    Image {
        id: logo
        source: "file:///usr/share/pixmaps/nusantaraos.svg"
        width: 88
        height: 88
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(20, root.height * 0.055)
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logo.bottom
        anchors.topMargin: 10
        text: "NUSANTARA OS"
        color: "#f8fafc"
        font.pixelSize: 26
        font.bold: true
        font.letterSpacing: 6
    }

    Text {
        id: subtitle
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: title.bottom
        anchors.topMargin: 4
        text: "ARCH  •  KDE PLASMA  •  BTRFS"
        color: "#f43f5e"
        font.pixelSize: 10
        font.letterSpacing: 3
    }

    // ---- kartu login ----
    Rectangle {
        id: card
        width: 360
        height: loginColumn.implicitHeight + 48
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: subtitle.bottom
        anchors.topMargin: 28
        radius: 18
        color: Qt.rgba(0.07, 0.09, 0.13, 0.92)
        border.color: Qt.rgba(0.88, 0.11, 0.28, 0.55)
        border.width: 1

        Column {
            id: loginColumn
            anchors.fill: parent
            anchors.margins: 24
            spacing: 10

            Text {
                width: parent.width
                text: textConstants.welcomeText.arg(sddm.hostName)
                color: "#e2e8f0"
                font.pixelSize: 14
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                text: textConstants.userName
                color: "#94a3b8"
                font.pixelSize: 11
                font.bold: true
            }

            TextBox {
                id: name
                width: parent.width
                height: 38
                text: userModel.lastUser
                color: "#0f1522"
                borderColor: "#334155"
                focusColor: "#e11d48"
                hoverColor: "#f43f5e"
                textColor: "#f8fafc"
                radius: 8
                font.pixelSize: 14

                KeyNavigation.backtab: rebootButton
                KeyNavigation.tab: password

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(name.text, password.text, sessionIndex)
                        event.accepted = true
                    }
                }
            }

            Text {
                width: parent.width
                text: textConstants.password
                color: "#94a3b8"
                font.pixelSize: 11
                font.bold: true
            }

            TextBox {
                id: password
                width: parent.width
                height: 38
                echoMode: TextInput.Password
                color: "#0f1522"
                borderColor: "#334155"
                focusColor: "#e11d48"
                hoverColor: "#f43f5e"
                textColor: "#f8fafc"
                radius: 8
                font.pixelSize: 14

                KeyNavigation.backtab: name
                KeyNavigation.tab: session

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(name.text, password.text, sessionIndex)
                        event.accepted = true
                    }
                }
            }

            Text {
                width: parent.width
                text: textConstants.session
                color: "#94a3b8"
                font.pixelSize: 11
                font.bold: true
            }

            ComboBox {
                id: session
                width: parent.width
                height: 34
                model: sessionModel
                index: sessionModel.lastIndex
                color: "#151b28"
                menuColor: "#151b28"
                borderColor: "#334155"
                focusColor: "#e11d48"
                hoverColor: "#f43f5e"
                textColor: "#f8fafc"
                font.pixelSize: 12

                KeyNavigation.backtab: password
                KeyNavigation.tab: loginButton
            }

            Text {
                id: errorMessage
                width: parent.width
                height: 14
                text: textConstants.prompt
                color: "#64748b"
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            Row {
                width: parent.width
                spacing: 8

                Button {
                    id: loginButton
                    width: (parent.width - 16) / 3
                    height: 36
                    text: textConstants.login
                    borderColor: "#e11d48"
                    activeColor: "#be123c"
                    pressedColor: "#9f1239"
                    textColor: "#ffffff"
                    font.pixelSize: 12
                    font.bold: true
                    onClicked: sddm.login(name.text, password.text, sessionIndex)
                    KeyNavigation.backtab: session
                    KeyNavigation.tab: shutdownButton
                }

                Button {
                    id: shutdownButton
                    width: (parent.width - 16) / 3
                    height: 36
                    text: textConstants.shutdown
                    borderColor: "#1e293b"
                    activeColor: "#334155"
                    pressedColor: "#0f172a"
                    textColor: "#f8fafc"
                    font.pixelSize: 12
                    onClicked: sddm.powerOff()
                    KeyNavigation.backtab: loginButton
                    KeyNavigation.tab: rebootButton
                }

                Button {
                    id: rebootButton
                    width: (parent.width - 16) / 3
                    height: 36
                    text: textConstants.reboot
                    borderColor: "#1e293b"
                    activeColor: "#334155"
                    pressedColor: "#0f172a"
                    textColor: "#f8fafc"
                    font.pixelSize: 12
                    onClicked: sddm.reboot()
                    KeyNavigation.backtab: shutdownButton
                    KeyNavigation.tab: name
                }
            }
        }
    }

    // ---- jam & tanggal ----
    Clock {
        id: clock
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 28
        color: "#f8fafc"
        timeFont.pixelSize: 30
        timeFont.bold: true
        dateFont.pixelSize: 11
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 16
        text: "Nusantara OS  •  " + sddm.hostName
        color: "#475569"
        font.pixelSize: 10
        font.letterSpacing: 2
    }

    Component.onCompleted: {
        if (name.text === "")
            name.focus = true
        else
            password.focus = true
    }
}
