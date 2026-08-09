import qs.Commons
import qs.Services.UI
import qs.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
  id: root

  property var pluginApi: null

  // Configuration
  property var widgetSettings: pluginApi?.pluginSettings || ({})
  property var widgetMetadata: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  Component.onCompleted: {
    if (pluginApi) {
      Logger.i("av2m", "Main initialized for av2 plugin");
    }
  }


  property var values: []
  property bool isIdle: true
  property bool shouldRun: false

  function getOutputDevice() {
    let id = widgetSettings.device;
    let devices = Pipewire.nodes.values;
    let result = devices.filter(device =>  device.name === id);

    Logger.d("av2m", result);
    if(result.length > 0) return result[0];

    return null;
  }

  PwAudioSpectrum {
    id: spectrum
    node: getOutputDevice()
    enabled: root.shouldRun
    bandCount: Settings.data.audio.spectrumMirrored ? 32 : 64
    frameRate: Settings.data.audio.spectrumFrameRate
    lowerCutoff: 50
    upperCutoff: 12000
    noiseReduction: 0.77
    smoothing: true

    onValuesChanged: {
      root.values = spectrum.values;
    }

    onIdleChanged: {
      root.isIdle = spectrum.idle;
    }
  }
}
