import qs.Commons
import qs.Services.UI
import qs.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property var pluginApi: null

  // Configuration
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // Get timezones from settings
  readonly property var timezones: cfg.timezones || defaults.timezones || []
  readonly property int rotationInterval: cfg.rotationInterval ?? defaults.rotationInterval ?? 5000
  readonly property string timeFormat: cfg.timeFormat || defaults.timeFormat || "HH:mm"

  // Filter enabled timezones
  readonly property var enabledTimezones: {
    let enabled = [];
    for (let i = 0; i < timezones.length; i++) {
      if (timezones[i].enabled) {
        enabled.push(timezones[i]);
      }
    }
    return enabled;
  }

  property int currentIndex: 0
  property string currentTime: ""
  property string currentCity: ""

  // Update time when Time singleton changes
  Connections {
    target: Time
    function onNowChanged() {
      updateTime();
    }
  }

  property var timeProcesses: ({})

  function updateTime() {
    if (enabledTimezones.length === 0) {
      currentCity = I18n.tr("world-clock.no-timezone");
      currentTime = "--:--";
      return;
    }

    let tz = enabledTimezones[currentIndex];
    currentCity = tz.name;

    // Get time using date command with TZ environment variable
    getTimeInTimezone(tz.timezone);
  }

  function getTimeInTimezone(timezone) {
    // Create format string based on user preference
    let format = timeFormat;
    if (format === "HH:mm") format = "+%H:%M";
    else if (format === "HH:mm:ss") format = "+%H:%M:%S";
    else if (format === "h:mm A") format = "+%I:%M %p";
    else if (format === "h:mm:ss A") format = "+%I:%M:%S %p";
    else if (format === "h:mm:ss A") format = "+%I:%M:%S %p";
    else if (format === "time-date") format = "+%I:%M %p %a, %b %y";
    else format = "+%H:%M";

    let processId = "time_" + timezone.replace(/\//g, "_");

    if (!timeProcesses[processId]) {
      timeProcesses[processId] = timeProcessComponent.createObject(root, {
        processId: processId,
        timezone: timezone,
        dateFormat: format
      });
    } else {
      timeProcesses[processId].dateFormat = format;
      timeProcesses[processId].running = true;
    }
  }

  // Rotation timer
  Timer {
    id: rotationTimer
    interval: rotationInterval
    running: enabledTimezones.length > 1
    repeat: true
    onTriggered: {
      root.currentIndex = (root.currentIndex + 1) % enabledTimezones.length;
      updateTime();
    }
  }

  Component {
    id: timeProcessComponent
    Process {
      property string processId: ""
      property string timezone: ""
      property string dateFormat: "+%H:%M"

      running: false
      command: ["sh", "-c", "TZ=" + timezone + " date '" + dateFormat + "'"]
      stdout: StdioCollector {}

      Component.onCompleted: {
        running = true;
      }

      onExited: (exitCode) => {
        if (exitCode === 0) {
          root.currentTime = stdout.text.trim();
        }
      }
    }
  }

  Component.onCompleted: {
    if (pluginApi) {
      Logger.i("WorldClock2", "Main initialized for World Clock2 plugin");
    }
  }
}
