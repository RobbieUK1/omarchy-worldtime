# World Times

A clock and world-times panel for the Omarchy shell bar.

The bar shows a clock whose format you can cycle through six layouts.
Right-clicking opens a searchable, scrollable list of world clocks, and you can
add new cities by searching the IANA timezone database from inside the panel.

## Formats

Left-click or scroll to cycle:

| # | Format                     | Example        |
|---|----------------------------|----------------|
| 0 | time                       | `14:32`        |
| 1 | time + seconds             | `14:32:15`     |
| 2 | abbreviated day + time     | `Mon 14:32`    |
| 3 | full day + time            | `Monday 14:32` |
| 4 | time + timezone            | `14:32 BST`    |
| 5 | time + seconds + timezone  | `14:32:15 BST` |

The hour is always 24-hour regardless of your locale, and `t` is the timezone
abbreviation (BST, GMT, ...). Modes that show seconds tick at 20Hz so the
seconds actually move; the others tick once a second.

## Requirements

- Omarchy shell
- `python3`

## Install

```sh
omarchy plugin add https://github.com/RobbieUK1/omarchy-worldtime.git --enable
omarchy restart shell
```

The panel shells out to a helper script that ships in `bin/` but has to live
outside the plugin directory:

```sh
mkdir -p ~/.config/omarchy/bar/scripts
install -m 755 bin/world-times ~/.config/omarchy/bar/scripts/world-times
```

Then right-click your bar -> **Configure bar** (or edit
`~/.config/omarchy/shell.json`) and add the widget:

```json
"left": [
  { "id": "robbie.worldtime" }
]
```

## How it works

`world-times` is a Python script that prints one JSON object with an `entries`
array, one per city, each with `city`, `time`, `day`, `offset` and a `local`
flag for the machine's own timezone. The panel polls it once a second while
open.

Entries are updated **in place** when the city count is unchanged, rather than
replacing the array. That keeps the `ListView` model reference stable so the
list never jumps back to the top while you are reading or scrolling it. A full
replacement only happens on first load or when you actually add or remove a
city.

### Adding a city

Press Enter in the search box and the script scans the IANA timezone database
for matches (`pacific` or `argentina` work well as queries). Matches appear as
a picker list; click one or press Enter to add it. Added cities are written to
`~/.config/omarchy/bar/scripts/world-times-custom.json` and survive restarts.

### Icons

`world-icons.js` maps city names to inline SVG flags, falling back to a
generated monogram when a city has no flag. Keeping the SVGs inline avoids a
network round-trip per row.

## A note on the panel surface

This panel is a `KeyboardPanel`, so it primes keyboard focus on open and the
search box is immediately typeable. That is deliberate: the search field is the
main interaction, and making the user click once more before they could type
was the wrong trade. Escape clears the query first and only closes the panel on
a second press.

## License

MIT
