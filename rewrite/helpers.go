package main

import (
	"os"
	"fmt"
	"syscall"
	"os/signal"
	"golang.org/x/term"
)

func cls() { fmt.Print("\033c") }

func init_term() (*term.State, chan os.Signal) {
	fd = int(os.Stdin.Fd())
	if !term.IsTerminal(fd) {
		fmt.Fprintln(os.Stderr, "not a terminal")
		os.Exit(1)
	}

	init_stat, e := term.MakeRaw(fd)
	if e != nil { fmt.Fprintf(os.Stderr, "couldn't make term raw: %v", e) }

	term_spec.width, term_spec.height, e = term.GetSize(fd)
	if e != nil {
		term.Restore(fd, init_stat)
		fmt.Fprintf(os.Stderr, "couldn't get term size: %v", e)
		os.Exit(1)
	}

	//alt term buf
	fmt.Print("\u001b[?1049h")

	//move cursor to top left
	fmt.Print("\033[1;1H")

	//hide cursor
	fmt.Print("\033[?25l")

	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	return init_stat, c
}

func wait_clean_and_close(state *term.State, c chan os.Signal) {
	<-c
	//restore term buf
	fmt.Print("\u001b[?1049l")

	//restore cursor
	fmt.Print("\033[?25h")

	term.Restore(fd, state) 
	os.Exit(0)
}
