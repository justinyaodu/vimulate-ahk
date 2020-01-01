# Vimulate AHK

An [AutoHotkey](https://www.autohotkey.com/) script which **emulates Vim keybindings in any Windows application**. Want to use <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> in your word processor? Want a visual mode for editing spreadsheets? The possibilities are endless!

## Features

* **Fully modal**: _switch between command, insert, and visual modes with the customary keyboard shortcuts_
* **Extensive keybinding support**: _supports as many Vim keybindings as possible_
* **Extensive application support**: _translates Vim keybindings to widely used keyboard commands (<kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> becomes <kbd>←</kbd><kbd>↓</kbd><kbd>↑</kbd><kbd>→</kbd>, etc.)_
* **Unobtrusive status window** _which displays the current mode_
* **Easy to toggle on and off** _so it doesn't get in the way when you're actually using Vim_

## License

Vimulate AHK is licensed under the [MIT License](LICENSE.md).

## Download

Grab the latest release (as an AHK script or as a compiled executable) [here](https://github.com/justinyaodu/vimulate-ahk/releases).

## Keybinding Support

| Status                                  | Keys            |
| ----------------------------------------| --------------- |
| Supported, maybe with minor differences | `hjkl ←↓↑→ bw \|^0$ -+ G aAiIoO xX D sS C Y v` |
| Supported with noticeable differences   | `g p V`         |
| Implemented with external functionality | `/ n u`         |
| Partial support                         | `d c y J HL <>` |
| Used for other functionality            | `m`             |
| Supported, but disabled by default      | <kbd>Backspace</kbd> <kbd>Space</kbd> <kbd>Enter</kbd> |

### Quirks, Limitations, and Extra Features

* Multi-keystroke commands, counts, registers, and macros are not supported yet*
    * <kbd>g</kbd> commands are not supported yet, so <kbd>g</kbd> goes to the beginning of the file, like <kbd>g</kbd><kbd>g</kbd> in Vim*
* The <kbd>t</kbd><kbd>f</kbd><kbd>T</kbd><kbd>F</kbd> commands are not supported yet*
* All beginning-of-line commands (<kbd>|</kbd><kbd>^</kbd><kbd>0</kbd>) are "soft"
* Final cursor position after commands may not always match Vim behaviour
    * Paste behaviour especially; to support as many use-cases as possible, it simply uses <kbd>Ctrl</kbd>+<kbd>V</kbd>
* Visual line mode doesn't work as expected when selecting lines upward*
* Commands that are typically followed by a movement (<kbd>d</kbd><kbd>c</kbd><kbd>y</kbd>) only operate on selections*
* Joining multiple selected lines with <kbd>J</kbd> is not supported
* <kbd>Shift</kbd> is sometimes not registered properly if held down while multiple keystrokes are issued
    * Page up/down (<kbd>H</kbd><kbd>L</kbd>) and indent adjustment (<kbd>\<</kbd><kbd>></kbd>) commands don't work if pressed multiple times while Shift is held down
* Instead of being used for marking, <kbd>m</kbd> becomes a [menu key](https://en.wikipedia.org/wiki/Menu_key)
* Although supported, mappings for <kbd>Backspace</kbd>, <kbd>Space</kbd>, and <kbd>Enter</kbd> are disabled by default for improved functionality in web browsers and other applications

_*Will be fixed in future versions._

