/* === This file is part of Calamares - <http://github.com/calamares> ===
 *
 *   Copyright 2015, Teo Mrnjavac <teo@kde.org>
 *
 *   Calamares is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Calamares is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Calamares. If not, see <http://www.gnu.org/licenses/>.
 */

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
            width: 800; height: 300
            fillMode: Image.PreserveAspectFit
      			horizontalAlignment: Image.AlignHCenter
      			verticalAlignment: Image.AlignTop
        }
        Text {
            anchors.horizontalCenter: background1.horizontalCenter
            anchors.top: background1.bottom
            text: "Welcome to ArchLabs <br/>"+
                  "Using a graphical installer, ArchLabs brings the BunsenLabs experience to Arch.<br/>"+
				          "Our vision doesn't end there, we're changing and improving with each release."
            wrapMode: Text.WordWrap
            width: 600
            horizontalAlignment: Text.Center
        }
    }

    Slide {

        Image {
            id: background2
            source: "slide2.png"
            width: 800; height: 300
            fillMode: Image.PreserveAspectFit
      			horizontalAlignment: Image.AlignHCenter
      			verticalAlignment: Image.AlignTop
        }
        Text {
            anchors.horizontalCenter: background2.horizontalCenter
            anchors.top: background2.bottom
            text: "Featuring the lightning fast Openbox Window Manager.<br/>"+
				          "Right click to get easy access to commonly used applications.<br/>"+
                  "Customize it to suit your needs and provide amazing functionality.<br/>"+
                  "All while looking nice and remaining low on system resources."
            wrapMode: Text.WordWrap
            width: 600
            horizontalAlignment: Text.Center
        }
    }

    Slide {

        Image {
            id: background3
            source: "slide3.png"
            width: 800; height: 300
            fillMode: Image.PreserveAspectFit
      			horizontalAlignment: Image.AlignHCenter
      			verticalAlignment: Image.AlignTop
        }
        Text {
            anchors.horizontalCenter: background3.horizontalCenter
            anchors.top: background3.bottom
            text: "Made to be minimal at its core, Minimo leaves the choices up to you<br/>"+
                  "While staying true to the ArchLabs experience out of the box."
            wrapMode: Text.WordWrap
            width: 600
            horizontalAlignment: Text.Center
        }
    }

    Slide {

        Image {
            id: background4
            source: "slide4.png"
            width: 800; height: 300
            fillMode: Image.PreserveAspectFit
      			horizontalAlignment: Image.AlignHCenter
      			verticalAlignment: Image.AlignTop
        }
        Text {
            anchors.horizontalCenter: background4.horizontalCenter
            anchors.top: background4.bottom
            text: "Built around Openbox but now including i3 gaps, a tiling window manager.<br/>"+
                  "Giving you two lightweight and awesome ways to manage your applications."
            wrapMode: Text.WordWrap
            width: 600
            horizontalAlignment: Text.Center
        }
    }

        Slide {

        Image {
            id: background5
            source: "slide5.png"
            width: 800; height: 300
            fillMode: Image.PreserveAspectFit
      			horizontalAlignment: Image.AlignHCenter
      			verticalAlignment: Image.AlignTop
        }
        Text {
            anchors.horizontalCenter: background5.horizontalCenter
            anchors.top: background5.bottom
            text: "With a solid base, Minimo stays out of the way so you can get work done.<br/>"+
                  "Install your favorite apps, configure how you like, and have fun.<br/>"+
                  "We listen, come and share your suggestions to help us improve ArchLabs."
            wrapMode: Text.WordWrap
            width: 600
            horizontalAlignment: Text.Center
        }
    }
}
