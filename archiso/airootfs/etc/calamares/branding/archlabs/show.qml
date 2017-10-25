import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Timer {
        interval: 20000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {

        Image {
            id: background1
            source: "slide1.png"
            width: 750; height: 425
            fillMode: Image.PreserveAspectFit
      		anchors.centerIn: parent
        }
    }

    Slide {

        Image {
            id: background2
            source: "slide2.png"
            width: 750; height: 425
            fillMode: Image.PreserveAspectFit
      		anchors.centerIn: parent
        }
    }

    Slide {

        Image {
            id: background3
            source: "slide3.png"
            width: 750; height: 425
            fillMode: Image.PreserveAspectFit
      		anchors.centerIn: parent
        }
    }

    Slide {

        Image {
            id: background4
            source: "slide4.png"
            width: 750; height: 425
            fillMode: Image.PreserveAspectFit
      		anchors.centerIn: parent
        }
    }

        Slide {

        Image {
            id: background5
            source: "slide5.png"
            width: 750; height: 425
            fillMode: Image.PreserveAspectFit
      		anchors.centerIn: parent
        }
    }
}
