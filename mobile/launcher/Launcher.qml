import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Item {
  id: root

  // These are injected by Omarchy's plugin host.
  property string omarchyPath: ""
  property var shell: null
  property var manifest: null
  readonly property var appLibrary: root.shell ? root.shell.appLibrary : null

  property bool opened: false
  property string filterText: ""
  property var apps: []
  property var selectedApp: null
  readonly property color foreground: Commons.Color.menu.text
  readonly property color mutedForeground: Commons.Color.menu.text
  readonly property int touchTarget: Math.max(Style.space(48), Style.font.body + Style.space(24))

  function refreshApps() {
    if (!root.appLibrary) {
      root.apps = []
      return
    }
    root.apps = root.appLibrary.sortedEntries(root.filterText)
  }

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.selectedApp = null
    root.refreshApps()
    if (root.appLibrary) root.appLibrary.refreshIcons()
  }

  function close() {
    root.opened = false
    root.filterText = ""
    root.selectedApp = null
  }

  function appName(entry) {
    return root.appLibrary ? root.appLibrary.entryName(entry) : String(entry.name || entry.id || "Application")
  }

  function appDetail(entry) {
    return root.appLibrary ? root.appLibrary.entrySubtext(entry) : ""
  }

  function launch(entry) {
    if (!entry || !root.appLibrary) return
    var id = String(entry.id || "")
    var name = root.appName(entry)
    if (!id) return
    root.close()
    root.appLibrary.launch(id, name)
  }

  Connections {
    target: root.appLibrary
    function onAppsChanged() { root.refreshApps() }
  }

  onFilterTextChanged: root.refreshApps()

  PanelWindow {
    id: overlay
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-mobile-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Item {
      id: viewport
      anchors.fill: parent

      Rectangle {
        anchors.fill: parent
        color: Commons.Color.menu.scrim
      }

      BorderSurface {
        id: surface
        anchors.fill: parent
        color: Commons.Color.menu.background
        radius: Style.cornerRadius
        borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, Math.max(1, Style.space(2)))
        padding: Style.spacing.panelPadding

        Item {
          id: content
          anchors.fill: parent
          anchors.margins: Style.spacing.panelPadding

          Text {
            id: title
            anchors.left: parent.left
            anchors.right: closeControl.left
            anchors.top: parent.top
            height: Math.max(Style.space(48), Style.font.title + Style.space(16))
            verticalAlignment: Text.AlignVCenter
            text: "Applications"
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            elide: Text.ElideRight
          }

          Item {
            id: closeControl
            anchors.right: parent.right
            anchors.top: parent.top
            width: Math.max(root.touchTarget, Style.space(64))
            height: root.touchTarget

            Text {
              anchors.centerIn: parent
              text: "Close"
              color: root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
            }

            TapHandler { onTapped: root.close() }
          }

          BorderSurface {
            id: searchSurface
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: title.bottom
            anchors.topMargin: Style.spacing.sm
            height: Math.max(root.touchTarget, Style.font.body + Style.space(24))
            radius: Style.cornerRadius
            color: Commons.Color.menu.background
            borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, Math.max(1, Style.space(1)))
            padding: Style.space(12)

            Text {
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.leftMargin: Style.space(12)
              anchors.rightMargin: Style.space(12)
              visible: searchInput.text.length === 0 && !searchInput.activeFocus
              text: "Search applications"
              color: root.mutedForeground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              elide: Text.ElideRight
            }

            TextInput {
              id: searchInput
              anchors.fill: parent
              anchors.leftMargin: Style.space(12)
              anchors.rightMargin: Style.space(12)
              anchors.topMargin: Style.space(4)
              anchors.bottomMargin: Style.space(4)
              text: root.filterText
              verticalAlignment: TextInput.AlignVCenter
              color: root.foreground
              selectionColor: Commons.Color.menu.selectedBackground
              selectedTextColor: Commons.Color.menu.selectedText
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              inputMethodHints: Qt.ImhNoPredictiveText
              onTextChanged: if (root.filterText !== text) root.filterText = text
              Keys.onEscapePressed: function(event) {
                if (text.length > 0) text = ""
                else root.close()
                event.accepted = true
              }
            }
          }

          Text {
            id: emptyState
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: searchSurface.bottom
            anchors.bottom: appGrid.bottom
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            visible: root.apps.length === 0
            text: root.appLibrary ? "No matching applications" : "Omarchy application library is unavailable"
            color: root.mutedForeground
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            wrapMode: Text.WordWrap
          }

          GridView {
            id: appGrid
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: searchSurface.bottom
            anchors.topMargin: Style.spacing.sm
            anchors.bottom: contextPanel.visible ? contextPanel.top : parent.bottom
            anchors.bottomMargin: contextPanel.visible ? Style.spacing.sm : 0
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            cellWidth: width / Math.max(1, Math.floor(width / Style.space(144)))
            cellHeight: Style.space(116)
            model: root.apps

            delegate: Item {
              id: appCell
              required property var modelData
              readonly property var entry: modelData.entry
              width: appGrid.cellWidth
              height: appGrid.cellHeight

              BorderSurface {
                id: appCard
                anchors.fill: parent
                anchors.margins: Style.space(4)
                radius: Style.cornerRadius
                color: Commons.Color.menu.background
                borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, Math.max(1, Style.space(1)))

                Column {
                  anchors.fill: parent
                  anchors.margins: Style.space(8)
                  spacing: Style.space(4)

                  Image {
                    id: appIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Style.space(40)
                    height: Style.space(40)
                    source: root.appLibrary ? root.appLibrary.iconSource(String(appCell.entry.icon || "")) : ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready
                  }

                  Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.max(root.touchTarget, Style.space(48))
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: root.appName(appCell.entry)
                    color: root.foreground
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                  }
                }

                TapHandler {
                  onTapped: root.launch(appCell.entry)
                  onLongPressed: root.selectedApp = appCell.entry
                }
              }
            }
          }

          BorderSurface {
            id: contextPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: visible ? Math.max(Style.space(88), root.touchTarget * 2) : 0
            visible: root.selectedApp !== null
            radius: Style.cornerRadius
            color: Commons.Color.menu.background
            borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, Math.max(1, Style.space(1)))

            Text {
              id: selectedName
              anchors.left: parent.left
              anchors.right: launchControl.left
              anchors.top: parent.top
              anchors.margins: Style.space(12)
              height: Style.space(28)
              text: root.selectedApp ? root.appName(root.selectedApp) : ""
              color: root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              elide: Text.ElideRight
            }

            Text {
              anchors.left: parent.left
              anchors.right: launchControl.left
              anchors.top: selectedName.bottom
              anchors.leftMargin: Style.space(12)
              anchors.rightMargin: Style.space(12)
              anchors.bottom: parent.bottom
              text: root.selectedApp ? root.appDetail(root.selectedApp) : ""
              color: root.mutedForeground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              elide: Text.ElideRight
              verticalAlignment: Text.AlignVCenter
            }

            Item {
              id: launchControl
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.rightMargin: Style.space(8)
              width: Math.max(root.touchTarget, Style.space(76))
              height: root.touchTarget

              Text {
                anchors.centerIn: parent
                text: "Launch"
                color: Commons.Color.menu.selectedText
                font.family: Style.font.family
                font.pixelSize: Style.font.body
              }

              TapHandler { onTapped: root.launch(root.selectedApp) }
            }
          }
        }
      }
    }
  }
}
