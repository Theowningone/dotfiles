import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
  id: root
  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true

  property real contentPreferredWidth: 320 * Style.uiScaleRatio
  property real contentPreferredHeight: panelColumn.implicitHeight + Style.marginXL * 2

  readonly property var mainInstance: pluginApi?.mainInstance

  anchors.fill: parent

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      id: panelColumn
      anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        margins: Style.marginXL
      }

      ColumnLayout {
        Layout.fillWidth: true
        visible: true

        NText {
          Layout.fillWidth: true
          text: "1"
          pointSize: Style.fontSizeM
          color: Color.mOnSurface
        }

        Item { Layout.preferredHeight: Style.marginL }

        Repeater {
          model: root.mainInstance.enabledTimezones

          Component.onCompleted: {
            Logger.d("WorldClock2", model);
          }

          delegate: ColumnLayout {
            required property var modelData
            required property int index
            Layout.fillWidth: true

            // Divider (top, except first)
            // Rectangle {
            //   visible: index > 0
            //   Layout.fillWidth: true
            //   height: 1
            //   color: Color.mOutline
            //   opacity: 0.3
            // }

            // Row content
            RowLayout {
              Layout.fillWidth: true
              Layout.topMargin: Style.marginM
              Layout.bottomMargin: Style.marginM
              spacing: Style.marginS

              // Name
              NText {
                Layout.fillWidth: true
                text: "1"
                pointSize: Style.fontSizeM
                color: Color.mOnSurface
              }

              // Value
              NText {
                text: root.mainInstance.getTimeInTimezone(modelData.timezone)
                // text: modelData.timezone
                // text: "2"
                pointSize: Style.fontSizeM
                font.weight: Font.DemiBold
                color: Color.mOnSurface
              }
            }
          }
        }
      }

      // ======== No data / loading / error overlay ========
      // ColumnLayout {
      //   Layout.fillWidth: true
      //   Layout.topMargin: Style.marginXL * 3
      //   Layout.bottomMargin: Style.marginXL * 3
      //   visible: !root.hasData
      //   spacing: Style.marginM

      //   NText {
      //     Layout.alignment: Qt.AlignHCenter
      //     text: {
      //       if (root.mainInstance?.loading) return pluginApi?.tr("panel.loading")
      //       if (root.mainInstance?.errorMessage) return root.mainInstance.errorMessage
      //       return pluginApi?.tr("panel.noData")
      //     }
      //     pointSize: Style.fontSizeL
      //     color: Color.mOnSurfaceVariant
      //     horizontalAlignment: Text.AlignHCenter
      //     wrapMode: Text.WordWrap
      //     Layout.fillWidth: true
      //   }
      // }

      // Item { Layout.preferredHeight: Style.marginXL }

      // // ======== Footer ========
      // RowLayout {
      //   Layout.fillWidth: true
      //   spacing: Style.marginM

      //   NButton {
      //     Layout.fillWidth: true
      //     text: pluginApi?.tr("panel.refresh")
      //     onClicked: {
      //       Logger.d("Air Quality", "Refreshing from panel...")
      //       root.mainInstance?.refresh()
      //     }
      //   }

      //   NIconButton {
      //     icon: "settings"
      //     onClicked: {
      //       if (!pluginApi) return
      //       Logger.d("Air Quality", "Opening settings from panel...")
      //       BarService.openPluginSettings(pluginApi.panelOpenScreen, pluginApi.manifest)
      //       pluginApi.closePanel(pluginApi.panelOpenScreen)
      //     }
      //   }
      // }
    }
  }
}
