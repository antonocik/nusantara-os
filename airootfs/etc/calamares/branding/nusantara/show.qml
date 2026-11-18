/* Nusantara OS — slideshow Calamares (merah-putih) */

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    function nextSlide() {
        presentation.goToNextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 5000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    Slide {
        Image {
            id: logo
            source: "nusantara-logo.png"
            width: 200; height: 200
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
        Text {
            anchors.horizontalCenter: logo.horizontalCenter
            anchors.top: logo.bottom
            text: "Nusantara OS"
            color: "#e11d48"
            font.pixelSize: 28
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: logo.horizontalCenter
            anchors.top: logo.bottom
            anchors.topMargin: 42
            text: "Arch Linux · KDE Plasma · BTRFS + Snapper"
            color: "#f8fafc"
            font.pixelSize: 14
        }
    }

    Slide {
        centeredText: qsTr("Sistem berkas BTRFS dengan subvolume @, @home, dan @snapshots.\nSnapshot otomatis lewat Snapper + Timeshift.")
    }

    Slide {
        centeredText: qsTr("Siap gaming: linux-zen, Steam, Lutris, GameMode, MangoHud,\nVulkan untuk AMD/Intel, dan driver NVIDIA lewat nusantara-assistant.")
    }

    Slide {
        centeredText: qsTr("Terima kasih telah memasang Nusantara OS.\nSelamat datang di rumah baru Linux Indonesia.")
    }

    function onActivate() {
        presentation.currentSlide = 0;
    }

    function onLeave() {
    }
}
