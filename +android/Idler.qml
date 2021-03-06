/*
 * Copyright 2018 by Marco Martin <mart@kde.org>
 * Copyright 2018 David Edmundson <davidedmundson@kde.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 2.4
import Mycroft 1.0 as Mycroft
import QtWebView 1.1

/* Class used to simulate the homescreen in cases where we're not using minimal shell
 */

Item {
    //I was asked to have a button. I have no idea why one wouldn't just connect on startup...
    Button {
        anchors.centerIn: parent
        text: "start"
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Closed
        onClicked: Mycroft.MycroftController.start();
    }

    ClockFace {
        id: face
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.7
        height: Math.min(parent.width, parent.height) * 0.7
        visible: Mycroft.MycroftController.status == Mycroft.MycroftController.Open
        showSecondsHand: true
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: face.time = new Date();
        }
    }

    Connections {
        target: Mycroft.MycroftController
        onListeningChanged: {
            if (Mycroft.MycroftController.listening) {
                webView.visible = false;
            }
        }
        onNotUnderstood: {
            //webView.url = "https://www.duckduckgo.com?q=" + qinput.text;
            webView.visible = true;
        }
    }
    Connections {
        target: qinput
        onTextChanged: webView.visible = false;
        onFocusChanged: {
            if (qinput.focus) {
                webView.visible = false;
            }
        }
    }
    Connections {
        target: mainView
        onDepthChanged: {
            if (mainView.depth > 1) {
                webView.visible = false;
            }
        }
    }
    WebView {
        id: webView
        visible: false
        width: parent.width
        height: parent.height
        x: width * applicationWindow().globalDrawer.position
        //visible: mainView.
        url: visible ? "https://www.duckduckgo.com?q=" + qinput.text : "about:blank"
        onLoadingChanged: {
            if (loadRequest.errorString) {
                console.error(loadRequest.errorString);
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        parent: qinput
        z: 9999
        visible: webView.visible
        onClicked: webView.visible = false
    }
}
