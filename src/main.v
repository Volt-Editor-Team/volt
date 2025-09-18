module main

import core
import ui.tui
import os
import config_loader // configuration file

fn run_doctor() chan []string {
    ch := chan []string{cap: 1}

    go fn (ch chan []string) {
        v_doctor := os.execute('v doctor')
        stats := v_doctor.output.split_into_lines()
        ch <- stats
    }(ch)

    return ch
}

fn main() {
    // ---- Load config ----
    cfg := config_loader.load_config()
    println('Loaded config: $cfg') // debug print (safe to remove later)

    // ---- Set up TUI app ----
    width, height := tui.get_terminal_size()
    file_path := './testdata/simple.txt'
    mut core_app := core.App.new(file_path, width, height)

    mut tui_app := tui.TuiApp.new(core_app)

    // TODO: pass cfg into core_app/tui_app
    tui_app.tui.run()!
}

