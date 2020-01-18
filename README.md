# Vimulate AHK

An [AutoHotkey](https://www.autohotkey.com/) script which **emulates Vim keybindings in any Windows application**. Want to use <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> in your word processor? Want a visual mode for editing spreadsheets? The possibilities are endless!

## Features

* **Fully modal:** switch between command, insert, and visual modes with the customary keyboard shortcuts
* **Extensive keybinding support**
* **Extensive application support** achieved by translating Vim keybindings to existing keyboard commands (<kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> becomes <kbd>←</kbd><kbd>↓</kbd><kbd>↑</kbd><kbd>→</kbd>, etc.)
* **Counts, compound commands, multi-letter commands**: commands like `7x`, `d3w`, and `gg` are fully supported
* **Unobtrusive status window** which displays the mode and partially entered commands
* **Easy to toggle on and off** so it doesn't get in the way when you're actually using Vim
* **Easily extensible:** add new modes for application-specific functionality or exotic things like mouse control

## License

Vimulate AHK is licensed under the [MIT License](LICENSE.md).

## Download

Grab the latest release (as an AHK script or as a compiled executable) [here](https://github.com/justinyaodu/vimulate-ahk/releases).

## Keybinding Support

| Status                                  | Keys      |
| ----------------------------------------| --------- |
| Supported, maybe with minor differences | `hjkl bw \|^0$ -+ gg G aAiIoO xXdDsScC yY p vV` |
| Implemented with external functionality | `/ n u`   |
| Partial support                         | `J HL <>` |
| Used for other functionality            | `m U`     |

### Quirks, Limitations, and Extra Features

* The <kbd>t</kbd><kbd>f</kbd><kbd>T</kbd><kbd>F</kbd> commands are not supported yet*
* All beginning-of-line commands (<kbd>|</kbd><kbd>^</kbd><kbd>0</kbd>) are implemented with the <kbd>Home</kbd> key, so they all behave the same
* Cursor placement doesn't always match Vim behaviour
* Joining multiple selected lines with <kbd>J</kbd> is not supported
* Visual line mode doesn't work as expected when selecting lines upward*
* <kbd>Shift</kbd> is sometimes not registered properly if held down while multiple keystrokes are issued*
    * Page up/down (<kbd>H</kbd><kbd>L</kbd>) and indent adjustment (<kbd>\<</kbd><kbd>></kbd>) commands don't work if pressed multiple times while Shift is held down
* Instead of being used for marking, <kbd>m</kbd> becomes a [menu key](https://en.wikipedia.org/wiki/Menu_key)

_*May be fixed in future versions._

## Version History

* **0.2:** Complete rewrite, with a full-blown command parser and improved extensibility
* **0.1:** Demonstration release, supporting single-keystroke commands only
