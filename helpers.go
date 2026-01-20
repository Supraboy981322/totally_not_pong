package main

import (
	"os"
	"fmt"
	"golang.org/x/term"
)

func cls() { fmt.Print("\033[H\033[2J\033c") }

func chkTermChg(w, h, oW, oH int) {
	//reinit view if window size changed
	w, h, _ = term.GetSize(termFd)
	if oW != w || oH != h { reinitScreen() }
}

func alt_buf() { fmt.Print("\033[?1049h") }
func restore_buf() { fmt.Print("\033[?1049l") }

func exit(c int) {
	cls()
	restore_buf()
	term.Restore(termFd, old_term_state)
	os.Exit(c)
}
