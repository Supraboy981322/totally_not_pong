package main

import (
	"fmt"
	"golang.org/x/term"
)

func cls() { fmt.Print("\033[H[033[2J\033c") }

func chkTermChg(w, h, oW, oH int) {
	//reinit view if window size changed
	w, h, _ = term.GetSize(termFd)
	if oW != w || oH != h { reinitScreen() }
}
