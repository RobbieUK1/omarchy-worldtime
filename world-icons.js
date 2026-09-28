.pragma library

// City landmark / trademark icons for the world-times panel. Each city renders
// a small monochrome line icon next to its name. Icons are generated at
// runtime as data-URI SVGs so they pick up the current theme text color and
// never need separate asset files.

function wrap(body, color) {
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" stroke="' + (color || "#e6f6f0") + '">' + body + '</svg>'
}

function svgForCity(city, color) {
  var key = String(city || "").toLowerCase().trim()
  var id = CITY_ICONS[key] || "globe"
  var body = ICONS[id] || ICONS["globe"]
  return "data:image/svg+xml;utf8," + encodeURIComponent(wrap(body, String(color)))
}

var ICONS = {

  skyline: '<path d="M3 21V9h3.5v12"/><path d="M8.7 21V5h3.6v16"/><path d="M14.5 21v-8h3.5v8"/><path d="M11 5V3.5"/><path d="M2.8 21h18.4"/>',

  mountain: '<path d="M3 20 8.5 7l3.5 7 3-4.5 5.5 10.5z"/><path d="M3 20h18"/>',

  palm: '<path d="M12 20V10"/><path d="M12 11.5c-4.2-.5-7.8-1.9-10-4.3 2.8.9 6.1 1.3 10 1.3s7.2-.4 10-1.3c-2.2 2.4-5.8 3.8-10 4.3z"/><path d="M7.5 20.5c2.8-1.6 6.2-1.6 9 0"/>',

  parthenon: '<path d="M4 20h16"/><path d="M4 11h16"/><path d="M4 11 12 5l8 6"/><path d="M5.5 11v9"/><path d="M9 11v9"/><path d="M12.5 11v9"/><path d="M16 11v9"/><path d="M19.5 11v9"/>',

  skytower: '<path d="M10.8 20h6.4"/><path d="M11.2 20 11.7 9h.6l.5 11"/><circle cx="12" cy="11.2" r="1.7"/><path d="M12 9V3"/>',

  flames: '<path d="M5 9c1.5 2 3 3.6 3 5.8a3 3 0 1 1-6 0C2 12.6 3.5 11 5 9z"/><path d="M12 9c1.5 2 3 3.6 3 5.8a3 3 0 1 1-6 0C9 12.6 10.5 11 12 9z"/><path d="M19 9c1.5 2 3 3.6 3 5.8a3 3 0 1 1-6 0C16 12.6 17.5 11 19 9z"/><path d="M2 21h20"/>',

  temple: '<path d="M12 21V4.5"/><path d="M7.5 21V11"/><path d="M16.5 21V11"/><path d="M12 4.5l-1.8-2.2M12 4.5l1.8-2.2"/><path d="M7.5 11l-1.7-2M7.5 11l1.7-2"/><path d="M16.5 11l-1.7-2M16.5 11l1.7-2"/><path d="M5.5 21h13"/><path d="M8.5 15.5h7"/><path d="M9.5 18h5"/>',

  pagoda: '<path d="M12 20V4.5"/><path d="M5.5 7l6.5-3 6.5 3"/><path d="M4.5 12l7.5-3 7.5 3"/><path d="M3.5 17l8.5-3 8.5 3"/><path d="M12 4.5V2.5"/>',

  gate: '<path d="M4 9h16"/><path d="M4 9 12 4l8 5"/><path d="M5.5 9v8"/><path d="M9 9v8"/><path d="M12.5 9v8"/><path d="M16 9v8"/><path d="M19.5 9v8"/><path d="M4 17h16"/><circle cx="12" cy="2.4" r=".7"/>',

  parliament: '<path d="M5 21V12h14v9"/><path d="M4 12h16"/><path d="M6.5 21v-6"/><path d="M9.5 21v-6"/><path d="M12.5 21v-6"/><path d="M15.5 21v-6"/><path d="M9.5 12V8.5h5V12"/><path d="M9.5 8.5h5"/><path d="M12 8.5V6"/>',

  obelisk: '<path d="M10.6 18 11.6 4h.8l1 14"/><path d="M11.6 4 12 1.2l.4 2.8"/><path d="M8.5 18h7"/><path d="M9 21h6"/>',

  pyramids: '<path d="M3.5 20 10 5l6.5 15z"/><path d="M15 19.5 18.5 9l4 10.5z"/><path d="M2 20h20"/><circle cx="18.5" cy="3.8" r="1.4"/>',

  pyramid: '<path d="M4 20h16"/><path d="M6.5 20l1-5h9l1 5"/><path d="M8.6 15l1-4.5h4.8l1 4.5"/><path d="M10.6 10.5 12 8.4l1.4 2.1"/><path d="M10.6 10.5v2.2"/><path d="M13.4 10.5v2.2"/><path d="M10.6 12.7h2.8"/>',

  minaret: '<path d="M11.5 21V6h3v15"/><path d="M13 6V4"/><path d="M13 4l2-1.2"/><path d="M11 9h4"/><path d="M7 21V14h4v7"/><path d="M7 14l1-1.5h2l1 1.5"/><path d="M5.5 21h13"/>',

  island: '<path d="M6.5 21c0-3 2.4-5.5 5.5-5.5 3.1 0 5.5 2.5 5.5 5.5"/><path d="M12 15.5V12"/><path d="M12 13c-2.7-.3-5-1.2-6.8-2.9 2.3.6 4.6.9 6.8.9s4.5-.3 6.8-.9c-1.8 1.7-4.1 2.6-6.8 2.9z"/><path d="M4 21h16"/>',

  atoll: '<circle cx="12" cy="13" r="7"/><circle cx="12" cy="13" r="2.2"/><path d="M12 20v2.5"/>',

  bicycle: '<circle cx="5.5" cy="17.5" r="3.5"/><circle cx="18.5" cy="17.5" r="3.5"/><circle cx="12" cy="17.5" r="1.2"/><path d="M9 13.5 12 17.5"/><path d="M15.5 13.5 12 17.5"/><path d="M9 13.5h6.5"/><path d="M7.5 13.5h3"/><path d="M14 13.5v2.5"/>',

  burj: '<path d="M11 21 11.8 4.5h.4l.8 16.5"/><path d="M7.5 21 11.4 9"/><path d="M16.5 21 12.6 9"/><path d="M7 21h10"/>',

  arch: '<path d="M7 21v-6a5.5 5.5 0 0 1 10 0v6"/><path d="M12 9.5V4.5"/><path d="M11.3 4.5a.7.7 0 0 0 1.4 0"/><path d="M5 21h14"/>',

  acacia: '<path d="M4 9.5h16"/><path d="M4 9.5C4 13 7.6 15 12 15s8-2 8-5.5"/><path d="M12 15v6"/><path d="M11 18h3"/>',

  empire: '<path d="M8.5 21V10.5h7V21"/><path d="M10 10.5V8h4v2.5"/><path d="M11 8V6h2v2"/><path d="M12 6V3"/>',

  iceberg: '<path d="M5.5 14.5 9 6l3 4.5 3-3.5 3 4 2-2.5"/><path d="M2.5 14.5h19"/><path d="M6.5 14.5v6.5"/><path d="M12 14.5v6.5"/><path d="M17.5 14.5v6.5"/>',

  longship: '<path d="M3 15c2.2-3.3 5.3-4.8 9-4.8s6.8 1.5 9 4.8"/><path d="M3 15c1.8 1.7 4.8 2.8 9 2.8 4.2 0 7.2-1.1 9-2.8"/><path d="M21 14c.5-2.5-.3-4.8-2-7"/><path d="M12 10.2V4.5"/><path d="M9.6 9.6h4.8L12 5.2z"/><circle cx="6.5" cy="14.2" r=".9"/><circle cx="8.8" cy="13" r=".9"/><circle cx="11.4" cy="12.4" r=".9"/><circle cx="14" cy="12.6" r=".9"/><circle cx="16.6" cy="13.4" r=".9"/>',

  eiffel: '<path d="M4.5 21C7 13.5 10 8.5 12 3.5"/><path d="M19.5 21C17 13.5 14 8.5 12 3.5"/><path d="M7 16.5h10"/><path d="M8.5 12.5h7"/><path d="M10 9h4"/><path d="M12 3.5V2"/><path d="M11.2 2a.8.8 0 0 0 1.6 0"/>',

  kangaroo: '<path d="M10.5 20c0-6.5 3-10.5 6.5-12"/><path d="M16.5 8c.8.5 1.4 1.2 1.7 2.1"/><path d="M20.5 6.5c-.4 1-1 1.7-1.9 2.1.5.4.8.9 1 1.5"/><path d="M19.5 6.2c.3-.9.9-1.5 1.8-1.9"/><path d="M7.5 20.5c-3-.3-4.5-1.6-5-3.8 1.5.2 3 .4 4.8.2"/><path d="M11 18.5h2"/>',

  castle: '<path d="M4 21h16"/><path d="M5.5 21v-9M18.5 21v-9"/><path d="M5.5 12h13"/><path d="M8.5 21V8.5M15.5 21V8.5"/><path d="M8.5 8.5V5.5M15.5 8.5V5.5"/><path d="M8.5 5.5h7"/><path d="M12 5.5V3.5"/><path d="M12 4.6l2.2.5"/>',

  volcano: '<path d="M5 21 12 6.5 19 21z"/><path d="M10.4 8.8h3.2"/><path d="M8.7 5.2c.8 1 1.9 1.5 3.3 1.5s2.5-.5 3.3-1.5"/><path d="M4 21h16"/>',

  christ: '<path d="M6.5 21 12 13.5 17.5 21z"/><circle cx="12" cy="6.2" r="1"/><path d="M12 7.4v6"/><path d="M12 10l-4.5-2.2M12 10l4.5-2.2"/><path d="M12 13.4l-2.6 3M12 13.4l2.6 3"/>',

  colosseum: '<path d="M5.5 21V10.5a6.5 6.5 0 0 1 13 0V21"/><path d="M4.5 21h15"/><path d="M7.65 11a1.2 1.2 0 0 1 2.4 0"/><path d="M10.8 11a1.2 1.2 0 0 1 2.4 0"/><path d="M15.15 11a1.2 1.2 0 0 1 2.4 0"/><path d="M7.65 14a1.2 1.2 0 0 1 2.4 0"/><path d="M10.8 14a1.2 1.2 0 0 1 2.4 0"/><path d="M15.15 14a1.2 1.2 0 0 1 2.4 0"/><path d="M7.65 17a1.2 1.2 0 0 1 2.4 0"/><path d="M10.8 17a1.2 1.2 0 0 1 2.4 0"/><path d="M15.15 17a1.2 1.2 0 0 1 2.4 0"/>',

  palaceGate: '<path d="M6.5 21v-8h11v8"/><path d="M6.5 13h11"/><path d="M4.5 13l3.2-3.5h8.6l3.2 3.5"/><path d="M7.7 9.5 12 6.5l4.6 3"/><path d="M10.5 17.5v3.5h3v-3.5"/>',

  merlion: '<path d="M3.5 8.8c1.7.9 3.4 1.2 5.4.7"/><circle cx="10.3" cy="8.8" r="1.5"/><path d="M10.3 7.3c1.1.4 1.9 1.2 2.3 2.3"/><path d="M11.7 10.5c1 1 1.5 2.4 1.1 3.8"/><path d="M11.9 14.3c1.4.6 3 .5 4.4-.3"/><path d="M16.5 13.8c-.3 2.9-1.7 4.9-3.6 6"/><path d="M14.2 16.5c1.8.7 3.2 1.8 4 3.4"/>',

  opera: '<path d="M3 19c1.5-5.5 4.5-10 10-13.5-.5 5 1 9.5-1.8 13.5z"/><path d="M9 19c1.2-4.5 3.8-8.2 8-10.5-.6 4.6.6 8.9-2 10.5z"/><path d="M13.8 19c.9-3.6 3-6.3 6.2-7.8-.8 4.2-.3 7.3-2.4 8.3z"/><path d="M2.5 19h19"/>',

  tower101: '<path d="M10.6 21v-2.4h2.8v2.4"/><path d="M10.4 18.6v-2.4h3.2v2.4"/><path d="M10.2 16.2v-2.4h3.6v2.4"/><path d="M10 13.8v-2.4h4v2.4"/><path d="M10.2 11.4V9h3.6v2.4"/><path d="M10.6 9V6.2h2.8V9"/><path d="M12 6.2V3.4"/><path d="M9.5 21h5"/>',

  milad: '<path d="M11.7 21 12 9.7l.3 11.3"/><path d="M8.5 6.5c.6-1.3 1.9-2 3.5-2s2.9.7 3.5 2c-.6 1.4-1.9 2-3.5 2s-2.9-.6-3.5-2z"/><path d="M12 4.5V2.5"/><path d="M10 21h4"/>',

  tokyoTower: '<path d="M4.5 21 12 6.5 19.5 21"/><path d="M12 6.5V2.8"/><path d="M6.5 14.8c1.8 1.2 9.2 1.2 11 0"/><path d="M9 10c1.8 1.2 4.2 1.2 6 0"/><path d="M7.8 21c2.8-.9 5.6-.9 8.4 0"/>',

  cnTower: '<path d="M11.4 21 11.8 10.6l.4 10.4"/><path d="M9 21h6"/><path d="M8.8 10c.6-1.9 2-3 3.2-3 1.2 0 2.6 1.1 3.2 3"/><path d="M8.8 10c.5 1.9 1.9 3 3.2 3 1.3 0 2.7-1.1 3.2-3"/><path d="M12 7V3"/>',

  yurt: '<path d="M4.5 18c.7-4.5 4-7 7.5-7s6.8 2.5 7.5 7z"/><path d="M4.5 18v2h15v-2"/><circle cx="12" cy="9.5" r="1.4"/><path d="M10.5 20v-2.5h3v2.5"/>',

  mountainSea: '<path d="M3 15.5 8 6.5l3.5 5 2.5-3.5 5.5 7.5z"/><path d="M3 15.5h18"/><path d="M2 18.5c1.6.9 3.2.9 4.8 0s3.2-.9 4.8 0 3.2.9 4.8 0 3.2-.9 4.8 0"/>',

  cathedral: '<path d="M6 21V12h12v9"/><path d="M6 12 12 6l6 6"/><path d="M12 6V2.2"/><path d="M11.2 2.8h1.6"/><path d="M10.4 21v-3c0-.7.6-1.2 1.6-1.2s1.6.5 1.6 1.2v3"/>',

  domeRock: '<path d="M6 16C6 8 18 8 18 16"/><path d="M6 16h12"/><path d="M6 16v3"/><path d="M18 16v3"/><path d="M6 19h12"/><path d="M12 10V7.5"/><path d="M11 19v-2.2c0-.55 2-.55 2 0V19"/>',

  onionDome: '<path d="M12 4.5c-3.5.4-5.5 3.2-5.5 8V15h11v-2.5c0-4.8-2-7.6-5.5-8z"/><path d="M12 4.5V2"/><path d="M11 3h2"/><path d="M6.5 15v4h11v-4"/><path d="M6.5 15h11"/>',

  stupa: '<path d="M8 13.5c0-3.8 1.7-6 4-6s4 2.2 4 6"/><path d="M8 13.5v2.5h8v-2.5"/><path d="M8 16v3.5"/><path d="M16 16v3.5"/><path d="M8 19.5h8"/><path d="M12 7.4V5"/><path d="M11.2 5.6a1.6 1.6 0 0 0 1.6 0"/>',

  petronas: '<path d="M6 21 7.4 8h2.2L11 21"/><path d="M13 21 14.4 8h2.2L18 21"/><path d="M8.6 14h6.8"/><path d="M8.5 8V5.5"/><path d="M15.5 8V5.5"/><path d="M4.5 21h15"/>',

  tram: '<path d="M6 15.5C6 11 7 8.5 8.5 8.5h7c1.5 0 2.5 2.5 2.5 7z"/><path d="M15.5 8.5V5"/><path d="M15.5 5l2-.5"/><path d="M8.2 11h2.4"/><path d="M11.6 11h2.4"/><path d="M15 11h1.6"/><path d="M11 13.8c0-.6 2-.6 2 0v1.7h-2z"/><circle cx="9.5" cy="17" r="1.4"/><circle cx="15" cy="17" r="1.4"/><path d="M3.5 18.5h17"/>',

  bigBen: '<path d="M8.5 21h7"/><path d="M9 21V8h6v13"/><path d="M9 8 12 5l3 3"/><path d="M12 5V2.2"/><circle cx="12" cy="12" r="1.9"/><path d="M12 12V10.8"/><path d="M12 12l1 .7"/><path d="M5 21V16h4v5"/><path d="M3.5 21h17"/>',

  bear: '<path d="M9.5 9A2.5 2.5 0 1 1 14.5 9l.5.3c1.5 1.6 2 4 1.4 6.4-.6 2.3-2 3.9-4.4 4.1-2.4-.2-3.8-1.8-4.4-4.1-.6-2.4-.1-4.8 1.4-6.4z"/><circle cx="10.4" cy="6.5" r="1.1"/><circle cx="13.6" cy="6.5" r="1.1"/><path d="M9.5 20.5v1M14.5 20.5v1"/>',

  harp: '<path d="M5.5 21V5h8"/><path d="M13.5 5v16"/><path d="M7.4 6.2c1.3 5 2 10 2.4 14.3"/><path d="M9 6.2c1.3 4.5 2 9.2 2.4 13.4"/><path d="M10.6 6.2c1.3 4 2 8.3 2.4 12.4"/><path d="M4.5 21h10"/>',

  kuwait: '<path d="M6.7 21 7.2 8.5l.6 0 .5 12.5"/><circle cx="7.7" cy="6.8" r="1.6"/><path d="M7.7 5.2V3"/><path d="M11.4 21 12 10.4l.6 10.6"/><circle cx="12" cy="8.6" r="1.1"/><circle cx="12" cy="5" r="1.9"/><path d="M12 3.1V1.6"/><path d="M16.7 21l.3-9.5h.6l.4 9.5"/><circle cx="17" cy="9.8" r="1.3"/><path d="M17 8.5V6.5"/><path d="M5.5 21h13"/>',

  crown: '<path d="M6.5 15.5V10l3 3.2L12 5l2.5 8.2 3-3.2v5.5z"/><path d="M6.5 15.5h11"/><path d="M6.5 18h11"/><circle cx="12" cy="8.8" r="1"/>',

  swiss: '<path d="M5.5 6.5h13v13h-13z"/><path d="M12 9v8"/><path d="M8 12.5h8"/>',

  mosque: '<path d="M8.7 13c0-4 1.4-6.5 3.3-6.5s3.3 2.5 3.3 6.5"/><path d="M12 6.5V4.5"/><path d="M5 21V12h2v9"/><path d="M17 21V12h2v9"/><path d="M5 12l1-1.7 1 1.7"/><path d="M17 12l1-1.7 1 1.7"/><path d="M11 21v-4.2c0-.5 2-.5 2 0V21"/><path d="M4 21h16"/>',

  lighthouse: '<path d="M9 21 10.2 9h3.6l1.2 12"/><path d="M9.3 12h5.4"/><circle cx="12" cy="7.6" r="1.1"/><path d="M10.3 6.5 12 4l1.7 2.5"/><path d="M14.8 8l2.6-.8"/><path d="M8 21h8"/>',

  globe: '<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17"/><path d="M12 3.5c-2.8 2.2-2.8 14.8 0 17"/>'

}

var CITY_ICONS = {
  "adelaide": "skyline",
  "anchorage": "mountain",
  "apia": "palm",
  "athens": "parthenon",
  "auckland": "skytower",
  "baghdad": "skyline",
  "baku": "flames",
  "bangkok": "temple",
  "beijing": "pagoda",
  "berlin": "gate",
  "bogotá": "mountain",
  "brisbane": "skyline",
  "bucharest": "parliament",
  "buenos aires": "obelisk",
  "cairo": "pyramids",
  "caracas": "mountain",
  "casablanca": "minaret",
  "chatham islands": "island",
  "chicago": "skyline",
  "copenhagen": "bicycle",
  "darwin": "skyline",
  "denver": "mountain",
  "dhaka": "skyline",
  "dubai": "burj",
  "dublin": "harp",
  "guatemala city": "pyramid",
  "halifax": "lighthouse",
  "ho chi minh city": "skyline",
  "hong kong": "skyline",
  "honolulu": "palm",
  "istanbul": "mosque",
  "jakarta": "obelisk",
  "jerusalem": "domeRock",
  "johannesburg": "skyline",
  "karachi": "skyline",
  "kathmandu": "stupa",
  "kiritimati": "atoll",
  "kolkata": "domeRock",
  "kuala lumpur": "petronas",
  "kuwait city": "kuwait",
  "kyiv": "onionDome",
  "kyiiv": "onionDome",
  "lagos": "skyline",
  "lima": "skyline",
  "lisbon": "tram",
  "london": "bigBen",
  "los angeles": "palm",
  "madrid": "bear",
  "manila": "skyline",
  "melbourne": "skyline",
  "mexico city": "pyramid",
  "moscow": "onionDome",
  "mumbai": "arch",
  "nairobi": "acacia",
  "new york": "empire",
  "nuuk": "iceberg",
  "oslo": "longship",
  "paris": "eiffel",
  "perth": "kangaroo",
  "prague": "castle",
  "reykjavík": "volcano",
  "rio de janeiro": "christ",
  "rome": "colosseum",
  "são paulo": "skyline",
  "santiago": "mountain",
  "seoul": "palaceGate",
  "singapore": "merlion",
  "stockholm": "crown",
  "suva": "palm",
  "sydney": "opera",
  "taipei": "tower101",
  "tehran": "milad",
  "tokyo": "tokyoTower",
  "toronto": "cnTower",
  "ulaanbaatar": "yurt",
  "vancouver": "mountainSea",
  "vienna": "cathedral",
  "warsaw": "skyline",
  "yangon": "stupa",
  "zagreb": "skyline",
  "zurich": "swiss"
}