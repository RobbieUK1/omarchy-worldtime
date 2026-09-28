import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Commons
import qs.Ui

import "world-icons.js" as WorldIcons

// World times clock bar widget. Shows the current time; left-clicking /
// scrolling cycles the clock format, and right-click opens a world times
// panel (city + local time, in alphabetical order, scrollable) fed by
// bar/scripts/world-times.  The default is an abbreviated day + 24-hour time
// ("Mon 14:32"); the hour format always uses a 24-hour clock.  t is the
// timezone abbreviation (BST, GMT, ...).
//   0  time                          "14:32"
//   1  time + seconds                "14:32:15"
//   2  abbreviated day + time        "Mon 14:32"
//   3  full day + time               "Monday 14:32"
//   4  time + timezone abbr          "14:32 BST"
//   5  time + seconds + timezone     "14:32:15 BST"

Panel {
  id: root
  moduleName: "robbie.worldtime"
  ipcTarget: "robbie.worldtime"

  // ---- clock state ----
  readonly property int clockModeCount: 6
  property int clockMode: 2

  // ---- world times panel state ----
  property var worldTimes: []       // entries from scripts/world-times

  readonly property var clockModeNames: [
    "time",
    "time + seconds",
    "day (short) + time",
    "day (long) + time",
    "time + timezone",
    "time + seconds + timezone"
  ]

  // Only the modes built around seconds print them, so the label can skip
  // the per-second repaint everywhere else.
  readonly property bool clockShowsSeconds: root.clockMode === 1 || root.clockMode === 5

  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  // ---- clock formatting ----
  // This widget always reads a 24-hour clock regardless of the system
  // locale. Tokens are Qt date format specifiers — ddd/dddd are abbreviated /
  // full weekdays and t is the timezone abbreviation (BST, GMT, ...).
  function clockHourToken(withSeconds) {
    return withSeconds ? "HH:mm:ss" : "HH:mm"
  }

  function formatClock(d) {
    var locale = Qt.locale()
    switch (root.clockMode) {
      case 0: return locale.toString(d, root.clockHourToken(false))
      case 1: return locale.toString(d, root.clockHourToken(true))
      case 2: return locale.toString(d, "ddd " + root.clockHourToken(false))
      case 3: return locale.toString(d, "dddd " + root.clockHourToken(false))
      case 4: return locale.toString(d, root.clockHourToken(false) + " t")
      case 5: return locale.toString(d, root.clockHourToken(true) + " t")
    }
    return ""
  }

  function cycleClockMode(direction) {
    root.clockMode = (root.clockMode + (direction || 1) + root.clockModeCount) % root.clockModeCount
    root.tick()
    if (root.bar) root.bar.showTooltip(root, root.tooltipBody())
  }

  // ---- presentation ----
  function tooltipBody() {
    var lines = ["World Times Clock"]
    lines.push("time: " + root.formatClock(new Date()) + " \u00b7 " + root.clockModeNames[root.clockMode])
    lines.push("")
    lines.push("click  \u2022 " + root.clockModeNames[root.clockMode])
    lines.push("right-click \u2022 world times panel")
    return lines.join("\n")
  }

  function tick() {
    clockLabel.text = root.formatClock(new Date())
  }

  implicitWidth: Math.max(12, clockWrap.implicitWidth + 16)
  implicitHeight: bar ? bar.barSize : 24

  Item {
    id: clockWrap
    implicitWidth: clockLabel.implicitWidth
    implicitHeight: clockLabel.implicitHeight
    anchors.centerIn: parent

    Text {
      id: clockLabel
      text: root.formatClock(new Date())
      color: bar ? bar.barForeground : Color.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.bar.iconFont
      renderType: Text.NativeRendering
      anchors.centerIn: parent
    }

    MouseArea {
      id: clockArea
      anchors.fill: parent
      z: 5
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: function(mouse) {
        if (mouse.button === Qt.RightButton) root.toggle()
        else if (mouse.button !== Qt.MiddleButton) root.cycleClockMode(1)
      }
      onWheel: root.cycleClockMode(wheel.angleDelta.y > 0 ? 1 : -1)
      onEntered: if (root.bar) root.bar.showTooltip(root, root.tooltipBody())
      onExited: if (root.bar) root.bar.hideTooltip(root)
    }
  }

  // Smooth 1s tick for all clock modes.
  Timer {
    id: tickTimer
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.tick()
  }

  // Seconds modes tick at 20Hz for a live feel.
  Timer {
    id: secondsTick
    interval: 50
    running: root.clockShowsSeconds
    repeat: true
    onTriggered: root.tick()
  }

  // ---- world times panel data ----
  function refreshWorldTimes() {
    if (!worldProc.running) worldProc.running = true
  }

  property string _lastWorldRaw: ""

  function applyWorldTimes(raw) {
    var data = {}
    try { data = JSON.parse(raw) } catch (err) { data = {} }
    if (!Array.isArray(data.entries)) return
    if (raw === root._lastWorldRaw) return
    root._lastWorldRaw = raw
    // When the list structure is the same (same city count), update entries in
    // place so the model reference stays stable and the ListView never resets
    // its scroll position. A full replacement only on first load or structure
    // change.
    if (root.worldTimes.length === data.entries.length) {
      for (var i = 0; i < data.entries.length; i++) {
        root.worldTimes[i].time = data.entries[i].time
        root.worldTimes[i].day  = data.entries[i].day
      }
    } else {
      root.worldTimes = data.entries
    }
  }

  Process {
    id: worldProc
    command: ["python3", Quickshell.env("HOME") + "/.config/omarchy/bar/scripts/world-times"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyWorldTimes(text)
    }
  }

  // Repoll once a second while the panel is open, and fetch immediately on
  // open so the first frame isn't just "Loading…". Closing resets the filter
  // so the next open starts clean.
  onOpenedChanged: {
    if (root.opened) {
      root.refreshWorldTimes()
    } else {
      root.worldSearch = ""
      root.addMatches = []
      root.addAlready = []
      root.addSearched = false
      root.addNotice = ""
    }
  }

  // Keep the list at the top while typing a new filter.
  onWorldSearchChanged: {
    if (worldList) worldList.positionViewAtBeginning()
  }

  Timer {
    id: worldTick
    interval: 1000
    running: root.opened
    repeat: true
    onTriggered: root.refreshWorldTimes()
  }

  // ------------------------------------------------------------ world times panel
  //
  // Right-clicking the clock opens a scrolling list of world clocks, sorted
  // A -> Z by city. KeyboardPanel owns the layer surface, the focus prime,
  // outside-click dismissal and the popout coordination; this widget only
  // supplies the content and its height.

  readonly property int worldRowHeight: Style.space(38)
  readonly property int worldVisibleRows: 9
  readonly property real worldListHeight: Math.max(
    Style.space(34),
    Math.min(root.worldVisibleRows, Math.max(1, root.worldTimes.length)) * root.worldRowHeight
  )
  readonly property real worldAddListHeight: Math.max(
    Style.space(34),
    Math.min(6, root.addMatches.length) * root.worldRowHeight
  )

  // The city flagged as the machine's own timezone by scripts/world-times.
  readonly property string worldLocalLabel: {
    var out = ""
    for (var i = 0; i < root.worldTimes.length; i++) {
      if (root.worldTimes[i].local) { out = String(root.worldTimes[i].city); break }
    }
    return out
  }

  // Search filter over city names, kept in step with the panel input.
  // Empty query passes the full list through untouched.
  property string worldSearch: ""
  readonly property var worldFilter: (function() {
    var q = root.worldSearch.trim().toLowerCase()
    if (q === "") return root.worldTimes
    var out = []
    for (var i = 0; i < root.worldTimes.length; i++) {
      if (String(root.worldTimes[i].city).toLowerCase().indexOf(q) !== -1)
        out.push(root.worldTimes[i])
    }
    return out
  })()

  // ---- adding a custom city ----
  // Pressing Enter in the search box scans the IANA timezone database for the
  // query; the matches are shown as a picker list (worldAddList). Picking one
  // persists it via `world-times add <zone>` and the panel refreshes. Added
  // cities live in world-times-custom.json and survive restarts.
  readonly property string worldTimesScript: Quickshell.env("HOME")
    + "/.config/omarchy/bar/scripts/world-times"

  property var addMatches: []        // [{label, zone}, ...] pending picker rows
  property var addAlready: []        // panel cities the query already matches
  property bool addBusy: false       // a search/add subprocess is running
  property string addNotice: ""      // transient feedback under the list
  property bool addSearched: false   // last Enter-search completed findable

  function runCitySearch(query) {
    query = String(query || "").trim()
    root.addMatches = []
    root.addAlready = []
    root.addSearched = false
    root.addNotice = ""
    if (query === "" || root.addBusy) return
    root.addBusy = true
    citySearchProc.command = ["python3", root.worldTimesScript, "search", query]
    if (!citySearchProc.running) citySearchProc.running = true
  }

  function addCity(entry) {
    if (!entry || !entry.zone || root.addBusy) return
    root.addBusy = true
    cityAddProc.command = ["python3", root.worldTimesScript, "add", String(entry.zone)]
    if (!cityAddProc.running) cityAddProc.running = true
  }

  // Focus and reveal whichever list the keys should drive.
  function focusActiveList() {
    var list = root.addMatches.length > 0 ? worldAddList : worldList
    list.positionViewAtIndex(list.currentIndex, ListView.Contain)
    list.forceActiveFocus()
  }

  Process {
    id: citySearchProc
    command: []
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.addBusy = false
        var d = {}
        try { d = JSON.parse(text) } catch (err) { d = {} }
        root.addMatches = Array.isArray(d.matches) ? d.matches : []
        root.addAlready = Array.isArray(d.already) ? d.already : []
        root.addSearched = true
      }
    }
  }

  Process {
    id: cityAddProc
    command: []
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.addBusy = false
        var d = {}
        try { d = JSON.parse(text) } catch (err) { d = {} }
        if (d.ok) {
          root.addNotice = "Added " + String(d.label) + " (" + String(d.zone) + ")"
          root.addMatches = []
          root.addAlready = []
          root.addSearched = false
          root.worldSearch = ""
          root.refreshWorldTimes()
          if (searchInput) searchInput.forceActiveFocus()
        } else {
          root.addNotice = d.error || "Couldn't add that city"
        }
        addNoticeTimer.restart()
      }
    }
  }

  Timer {
    id: addNoticeTimer
    interval: 2600
    onTriggered: root.addNotice = ""
  }

  KeyboardPanel {
    id: worldPanel
    anchorItem: clockWrap
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: searchInput
    contentWidth: worldPanel.fittedContentWidth(Style.space(300))
    contentHeight: worldPanel.fittedContentHeight(worldColumn.implicitHeight)

    Column {
      id: worldColumn
      width: parent.width
      spacing: Style.spacing.sm

      PanelHero {
        width: parent.width
        title: "World Times"
        meta: root.worldSearch.trim() !== ""
          ? root.worldFilter.length + " of " + root.worldTimes.length + " cities"
          : (root.worldLocalLabel
              ? root.worldLocalLabel + " local \u00b7 scroll to browse"
              : "Scroll to browse")
        detail: root.worldFilter.length > 0 ? String(root.worldFilter.length) : ""
        foreground: Color.popups.text
        fontFamily: bar ? bar.fontFamily : Style.font.family
        iconComponent: Component {
            Text {
              text: ""
              anchors.left: parent.left
              anchors.leftMargin: Style.space(5)
            color: Color.popups.text
            font.family: bar ? bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.display
          }
        }
      }

      // ---- city search ----
      Item {
        width: parent.width
        height: Style.spacing.controlHeight
        implicitHeight: height

        Rectangle {
          anchors.fill: parent
          radius: Style.cornerRadius
          border.width: Math.max(1, Style.space(2))
          border.color: searchInput.activeFocus
            ? Color.accent
            : Util.alpha(Color.popups.text, 0.18)
          color: Util.alpha(Color.popups.text, 0.05)
        }

        Text {
          text: "\uf002"
          anchors.left: parent.left
          anchors.leftMargin: Style.space(10)
          anchors.verticalCenter: parent.verticalCenter
          color: searchInput.activeFocus ? Color.accent : Util.alpha(Color.popups.text, 0.55)
          font.family: bar ? bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }

        TextInput {
          id: searchInput
          anchors.left: parent.left
          anchors.leftMargin: Style.space(28)
          anchors.right: clearBtn.left
          anchors.rightMargin: Style.space(8)
          anchors.verticalCenter: parent.verticalCenter
          color: Color.popups.text
          font.family: bar ? bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          clip: true
          selectByMouse: true
          onTextChanged: {
            root.worldSearch = text
            // Editing invalidates any pending "add this timezone" matches.
            root.addMatches = []
            root.addAlready = []
            root.addSearched = false
            root.addNotice = ""
          }
          Keys.onEscapePressed: {
            if (root.addMatches.length > 0) {
              root.addMatches = []
              root.addSearched = false
              root.worldSearch = ""
            } else if (text.length > 0) {
              root.worldSearch = ""
            } else {
              root.worldPanelOpen = false
            }
          }
          Keys.onReturnPressed: {
            if (root.addMatches.length > 0) root.addCity(root.addMatches[worldAddList.currentIndex])
            else root.runCitySearch(text)
          }
          Keys.onEnterPressed: {
            if (root.addMatches.length > 0) root.addCity(root.addMatches[worldAddList.currentIndex])
            else root.runCitySearch(text)
          }
          Keys.onDownPressed: {
            if (root.addMatches.length > 0) worldAddList.incrementCurrentIndex()
            else worldList.incrementCurrentIndex()
            root.focusActiveList()
          }
          Keys.onUpPressed: {
            if (root.addMatches.length > 0) worldAddList.decrementCurrentIndex()
            else worldList.decrementCurrentIndex()
            root.focusActiveList()
          }
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_PageDown) {
              root.focusActiveList()
              if (root.addMatches.length > 0) {
                worldAddList.currentIndex = Math.min(
                  worldAddList.count - 1,
                  worldAddList.currentIndex + root.worldVisibleRows)
              } else {
                worldList.currentIndex = Math.min(
                  worldList.count - 1,
                  worldList.currentIndex + root.worldVisibleRows)
              }
              root.focusActiveList()
              event.accepted = true
            } else if (event.key === Qt.Key_PageUp) {
              root.focusActiveList()
              if (root.addMatches.length > 0) {
                worldAddList.currentIndex = Math.max(
                  0,
                  worldAddList.currentIndex - root.worldVisibleRows)
              } else {
                worldList.currentIndex = Math.max(
                  0,
                  worldList.currentIndex - root.worldVisibleRows)
              }
              root.focusActiveList()
              event.accepted = true
            }
          }
        }

        Text {
          anchors.fill: searchInput
          anchors.rightMargin: Style.space(2)
          verticalAlignment: TextInput.AlignVCenter
          text: "Search cities\u2026"
          color: Util.alpha(Color.popups.text, 0.4)
          font.family: bar ? bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          visible: searchInput.text.length === 0
        }

        Text {
          id: clearBtn
          text: "\uf00d"
          anchors.right: parent.right
          anchors.rightMargin: Style.space(8)
          anchors.verticalCenter: parent.verticalCenter
          color: Util.alpha(Color.popups.text, 0.6)
          font.family: bar ? bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          visible: searchInput.text.length > 0
          MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.worldSearch = ""
              searchInput.forceActiveFocus()
            }
          }
        }
      }

      PanelSeparator { foreground: Color.popups.text }

      Item {
        width: parent.width
        height: root.addMatches.length > 0 ? root.worldAddListHeight : root.worldListHeight
        implicitHeight: height

        ListView {
          id: worldList
          width: parent.width
          height: parent.height
          model: root.worldFilter
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          snapMode: ListView.NoSnap
          visible: root.addMatches.length === 0
          delegate: Component { WorldRow { } }
          highlightMoveDuration: 120
          Keys.onDownPressed: { incrementCurrentIndex(); positionViewAtIndex(currentIndex, ListView.Contain) }
          Keys.onUpPressed:   { decrementCurrentIndex(); positionViewAtIndex(currentIndex, ListView.Contain) }
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_PageDown) {
              currentIndex = Math.min(count - 1, currentIndex + root.worldVisibleRows)
              positionViewAtIndex(currentIndex, ListView.Contain)
              event.accepted = true
            } else if (event.key === Qt.Key_PageUp) {
              currentIndex = Math.max(0, currentIndex - root.worldVisibleRows)
              positionViewAtIndex(currentIndex, ListView.Contain)
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              event.accepted = true
            }
          }
        }

        // Shows the IANA timezone matches for the search query. Each row adds
        // the city on click; Enter adds the highlighted match.
        ListView {
          id: worldAddList
          anchors.fill: parent
          model: root.addMatches
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          delegate: Component { WorldAddRow { } }
          highlightMoveDuration: 120
          visible: root.addMatches.length > 0
          Keys.onDownPressed: { incrementCurrentIndex(); positionViewAtIndex(currentIndex, ListView.Contain) }
          Keys.onUpPressed:   { decrementCurrentIndex(); positionViewAtIndex(currentIndex, ListView.Contain) }
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_PageDown) {
              currentIndex = Math.min(count - 1, currentIndex + root.worldVisibleRows)
              positionViewAtIndex(currentIndex, ListView.Contain)
              event.accepted = true
            } else if (event.key === Qt.Key_PageUp) {
              currentIndex = Math.max(0, currentIndex - root.worldVisibleRows)
              positionViewAtIndex(currentIndex, ListView.Contain)
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.addCity(root.addMatches[currentIndex])
              event.accepted = true
            }
          }
        }

        // Thin themed scrollbar, updated live from the view metrics.
        Item {
          id: scrollbar
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: Style.space(4)
          visible: root.addMatches.length === 0
            && worldList.contentHeight > worldList.height

          Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Util.alpha(Color.popups.text, 0.10)
          }

          Rectangle {
            width: parent.width
            radius: width / 2
            color: Util.alpha(Color.popups.text, 0.35)
            readonly property real ratio: worldList.visibleArea.heightRatio
            height: Math.max(Style.space(10), worldList.height * ratio)
            y: worldList.height * worldList.visibleArea.yPosition
          }
        }

        Text {
          anchors.centerIn: parent
          visible: root.worldTimes.length === 0
          text: "Loading\u2026"
          color: Util.alpha(Color.popups.text, 0.5)
          font.family: bar ? bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }

        Text {
          anchors.centerIn: parent
          visible: root.addMatches.length === 0 && root.addBusy
          text: "Searching timezones\u2026"
          color: Util.alpha(Color.popups.text, 0.5)
          font.family: bar ? bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }

        Text {
          anchors.centerIn: parent
          visible: root.addMatches.length === 0 && !root.addBusy
            && root.addSearched && root.worldSearch.trim() !== ""
          text: root.addAlready.length > 0
            ? (root.addAlready.join(", ") + (root.addAlready.length > 1
                ? " already in your list"
                : " is already in your list"))
            : ("No timezone like \u201c" + root.worldSearch.trim() + "\u201d\nTry a region, e.g. \u201cpacific\u201d or \u201cargentina\u201d")
          color: Util.alpha(Color.popups.text, 0.5)
          font.family: bar ? bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          horizontalAlignment: Text.AlignHCenter
          lineHeightMode: Text.FixedHeight
          lineHeight: Style.space(16)
          width: parent.width
          wrapMode: Text.Wrap
        }

        Text {
          anchors.centerIn: parent
          visible: root.worldTimes.length > 0 && root.addMatches.length === 0
            && !root.addBusy && !root.addSearched
            && root.worldSearch.trim() !== ""
            && root.worldFilter.length === 0
          text: "No matches for \u201c" + root.worldSearch.trim() + "\u201d"
          color: Util.alpha(Color.popups.text, 0.5)
          font.family: bar ? bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }
      }

      Text {
        width: parent.width
        text: root.addNotice !== ""
          ? root.addNotice
          : (root.addMatches.length > 0
              ? "click a match or press Enter to add \u00b7 Esc clears"
              : (root.worldSearch.trim() !== ""
                  ? "type filters \u00b7 Enter adds a timezone \u00b7 Esc clears"
                  : "type to search \u00b7 \u2191\u2193 navigate \u00b7 PgUp/PgDn jump \u00b7 Esc closes"))
        color: root.addNotice !== "" ? Color.accent : Util.alpha(Color.popups.text, 0.6)
        font.family: bar ? bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
      }
      }
  }

  component WorldAddRow: Item {
    id: addRow
    required property var modelData

    width: ListView.view.width
    height: root.worldRowHeight
    implicitHeight: height

    Rectangle {
      anchors.fill: parent
      radius: Style.space(4)
      color: addRowArea.containsMouse || addRow.ListView.isCurrentItem
        ? Util.alpha(Color.accent, 0.13)
        : "transparent"
    }

    MouseArea {
      id: addRowArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.addCity(addRow.modelData)
    }

    Column {
      anchors.left: parent.left
      anchors.leftMargin: Style.space(10)
      anchors.right: addGlyph.left
      anchors.rightMargin: Style.space(6)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(1)

      Text {
        width: parent.width
        elide: Text.ElideRight
        text: String(addRow.modelData.label)
        color: Color.popups.text
        font.family: bar ? bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
      }

      Text {
        width: parent.width
        elide: Text.ElideRight
        text: String(addRow.modelData.zone)
        color: Util.alpha(Color.popups.text, 0.6)
        font.family: bar ? bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    Text {
      id: addGlyph
      text: "+"
      anchors.right: parent.right
      anchors.rightMargin: Style.space(10)
      anchors.verticalCenter: parent.verticalCenter
      color: Color.accent
      font.family: bar ? bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.title
      font.bold: true
    }
  }

  component WorldRow: Item {
    id: row
    required property var modelData

    width: ListView.view.width
    height: root.worldRowHeight
    implicitHeight: height

    Rectangle {
      anchors.fill: parent
      radius: Style.space(4)
      color: row.modelData.local
        ? Util.alpha(Color.accent, 0.13)
        : (rowArea.containsMouse ? Util.alpha(Color.popups.text, 0.08) : "transparent")
    }

    MouseArea {
      id: rowArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
    }

    Text {
      text: "\u2713"
      visible: row.modelData.local
      anchors.left: parent.left
      anchors.leftMargin: Style.space(6)
      anchors.verticalCenter: parent.verticalCenter
      color: Color.accent
      font.family: bar ? bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.caption
      font.bold: true
    }

    IconImage {
      anchors.left: parent.left
      anchors.leftMargin: row.modelData.local ? Style.space(20) : Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(16)
      height: Style.space(16)
      source: WorldIcons.svgForCity(row.modelData.city, Color.popups.text)
    }

    Column {
      anchors.left: parent.left
      anchors.leftMargin: (row.modelData.local ? Style.space(20) : Style.space(8))
        + Style.space(16) + Style.space(6)
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: timeText.left
      anchors.rightMargin: Style.space(8)
      spacing: Style.space(1)

      Text {
        width: parent.width
        elide: Text.ElideRight
        text: row.modelData.city
        color: Color.popups.text
        font.family: bar ? bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
      }

      Text {
        width: parent.width
        elide: Text.ElideRight
        text: row.modelData.day + " \u00b7 " + row.modelData.offset
        color: Util.alpha(Color.popups.text, 0.6)
        font.family: bar ? bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    Text {
      id: timeText
      anchors.right: parent.right
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      text: row.modelData.time
      color: Color.popups.text
      font.family: bar ? bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.title
      font.bold: true
      horizontalAlignment: Text.AlignRight
    }
  }

}