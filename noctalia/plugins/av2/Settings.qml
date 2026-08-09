import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import Quickshell.Services.Pipewire

ColumnLayout {
  id: root
  spacing: Style.marginM

  property var pluginApi: null

  property var widgetData: pluginApi?.pluginSettings || ({})
  property var widgetMetadata: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  Component.onCompleted: {
    if (pluginApi) {
      Logger.i("av2s", "Settings initialized");
    }
  }

  property int valueWidth: widgetData.width !== undefined ? widgetData.width : widgetMetadata.width
  property int valueHeight: widgetData.height !== undefined ? widgetData.height : widgetMetadata.height
  // property string valueVisualizerType: widgetData.visualizerType !== undefined ? widgetData.visualizerType : widgetMetadata.visualizerType
  property string valueColorName: widgetData.colorName !== undefined ? widgetData.colorName : widgetMetadata.colorName
  property bool valueHideWhenIdle: widgetData.hideWhenIdle !== undefined ? widgetData.hideWhenIdle : widgetMetadata.hideWhenIdle
  property bool valueShowBackground: widgetData.showBackground !== undefined ? widgetData.showBackground : widgetMetadata.showBackground
  property bool valueRoundedCorners: widgetData.roundedCorners !== undefined ? widgetData.roundedCorners : widgetMetadata.roundedCorners
  property string valueDevice: widgetData.device !== undefined ? widgetData.device : widgetMetadata.device

  function saveSettings() {
    pluginApi.pluginSettings.width = valueWidth;
    pluginApi.pluginSettings.height = valueHeight;
    // pluginApi.pluginSettings.visualizerType = valueVisualizerType;
    pluginApi.pluginSettings.colorName = valueColorName;
    pluginApi.pluginSettings.hideWhenIdle = valueHideWhenIdle;
    pluginApi.pluginSettings.showBackground = valueShowBackground;
    pluginApi.pluginSettings.roundedCorners = valueRoundedCorners;
    pluginApi.pluginSettings.device = valueDevice;

    pluginApi.saveSettings();
  }

  function getDeviceOptions() {
    let options = Pipewire.nodes.values;
    let available = [];
    options.forEach(function(node){
      if(node.isSink && !node.isStream) {
        let option = {
          key: node.name,
          name: (node.nickname || node.name)
        };
        available.push(option);
        Logger.d("av2s", node.id+" : " + (node.nickname || node.name) + " (" + node.name + ")");
      }
    });

    return available;
  }

  NComboBox {
    Layout.fillWidth: true
    label: "Audio Device"
    model: getDeviceOptions()
    currentKey: valueDevice
    onSelected: key => {
                  valueDevice = key;
                  saveSettings();
                }
    defaultValue: widgetMetadata.device
  }

  NTextInput {
    id: widthInput
    Layout.fillWidth: true
    label: I18n.tr("common.width")
    description: I18n.tr("bar.audio-visualizer.width-description")
    text: String(valueWidth)
    placeholderText: I18n.tr("placeholders.enter-width-pixels")
    inputMethodHints: Qt.ImhDigitsOnly
    onEditingFinished: {
      const parsed = parseInt(text);
      if (!isNaN(parsed) && parsed > 0) {
        valueWidth = parsed;
        saveSettings();
      } else {
        text = String(valueWidth);
      }
    }
    defaultValue: String(widgetMetadata.width)
  }

  NTextInput {
    id: heightInput
    Layout.fillWidth: true
    label: I18n.tr("common.height")
    description: I18n.tr("bar.audio-visualizer.height-description")
    text: String(valueHeight)
    placeholderText: I18n.tr("placeholders.enter-width-pixels")
    inputMethodHints: Qt.ImhDigitsOnly
    onEditingFinished: {
      const parsed = parseInt(text);
      if (!isNaN(parsed) && parsed > 0) {
        valueHeight = parsed;
        saveSettings();
      } else {
        text = String(valueHeight);
      }
    }
    defaultValue: String(widgetMetadata.height)
  }

  // NComboBox {
  //   Layout.fillWidth: true
  //   label: I18n.tr("panels.audio.visualizer-type-label")
  //   description: I18n.tr("panels.desktop-widgets.media-player-visualizer-type-description")
  //   model: [
  //     {
  //       "key": "linear",
  //       "name": I18n.tr("options.visualizer-types.linear")
  //     },
  //     {
  //       "key": "mirrored",
  //       "name": I18n.tr("options.visualizer-types.mirrored")
  //     },
  //     {
  //       "key": "wave",
  //       "name": I18n.tr("options.visualizer-types.wave")
  //     }
  //   ]
  //   currentKey: valueVisualizerType
  //   onSelected: key => {
  //                 valueVisualizerType = key;
  //                 saveSettings();
  //               }
  //   defaultValue: widgetMetadata.visualizerType
  // }

  NColorChoice {
    Layout.fillWidth: true
    label: I18n.tr("bar.audio-visualizer.color-name-label")
    description: I18n.tr("bar.audio-visualizer.color-name-description")
    currentKey: valueColorName
    onSelected: key => {
                  valueColorName = key;
                  saveSettings();
                }
    defaultValue: widgetMetadata.colorName
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("bar.audio-visualizer.hide-when-idle-label")
    description: I18n.tr("bar.audio-visualizer.hide-when-idle-description")
    checked: valueHideWhenIdle
    onToggled: checked => {
                 valueHideWhenIdle = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.hideWhenIdle
  }

  NDivider {
    Layout.fillWidth: true
  }

  NToggle {
    Layout.fillWidth: true
    label: I18n.tr("panels.desktop-widgets.clock-show-background-label")
    description: I18n.tr("panels.desktop-widgets.media-player-show-background-description")
    checked: valueShowBackground
    onToggled: checked => {
                 valueShowBackground = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.showBackground
  }

  NToggle {
    Layout.fillWidth: true
    visible: valueShowBackground
    label: I18n.tr("panels.desktop-widgets.clock-rounded-corners-label")
    description: I18n.tr("panels.desktop-widgets.media-player-rounded-corners-description")
    checked: valueRoundedCorners
    onToggled: checked => {
                 valueRoundedCorners = checked;
                 saveSettings();
               }
    defaultValue: widgetMetadata.roundedCorners
  }
}
