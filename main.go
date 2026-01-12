package main

import (
	"os"
	"fmt"
	"golang.org/x/term"
)

type (
	Ball struct {
		X int
		Y int
	}
	Paddle struct {
		Pos int
		Height int
	}
	Game struct {
		Pre []string
		View []string
		Width int
		Height int
		P1 Paddle
		P2 Paddle
		Ball Ball
	}
)

var (
	termFd int
	game Game
)

func init() {
	termFd = int(os.Stdout.Fd())
	if !term.IsTerminal(termFd) {
		fmt.Println("err... you don't appear to be a terminal\ncan't render properly")
		os.Exit(1)
	};{
		w, h, e := term.GetSize(termFd)
		if e != nil { fmt.Printf("%v\n", e) ; os.Exit(1) }
		game = Game{
			Width: w,
			Height: h,
		} ; game.Ball = Ball{
		X: (h/2)-1,
		Y: (h/2)-1,
		} ; game.P1 = Paddle {
				Height: h/10,
		} ; game.P2 = Paddle {
				Height: h/10,
		}
	}
}

func main() {
	cls()

	w, h, _ := term.GetSize(termFd)
	var oW, oH int //tracks previous window size
	for {
		{ //reinit view if window size changed
			w, h, _ = term.GetSize(termFd)
			if oW != w || oH != h { reinitScreen() }
			oW, oH = w, h
		}
		for r := range game.Height {
			if game.View[r] == game.Pre[r] { continue }
			for c := range game.Width {
				if game.View[r][c] != game.Pre[r][c] {
					var char string
					if c == 0 &&
					   r >= game.P1.Pos &&
					   r <= game.P1.Pos+game.P1.Height-1 {
						char = "\033[48;2;255;199;119m \033[0m"
					} else if c == game.Width-1 &&
							   r >= game.P2.Pos &&
					       r <= game.P2.Pos+game.P2.Height {
						char = "\033[48;2;130;139;184m \033[0m"
					} else if c == game.Ball.X-1 && r == game.Ball.Y-1 {
						char = "\033[31;48;2;14;23;41m\033[0m"
					} else if c != game.Width/2 {
						char = string(game.View[r][c])
					} else { char = "\033[48;2;14;23;41m\ueb8a\033[0m" }


					//replace blank with background
					if char == " " { char = "\033[48;2;14;23;41m \033[0m" }
					fmt.Printf("\033[%d;%dH%s", r+1, c+1, char)
				} else { continue }
			} ; game.Pre[r] = game.View[r]
		}
	}
}

func reinitScreen() {
	cls()
	w, h, e := term.GetSize(termFd)
	if e != nil { fmt.Printf("%v\n", e) ; os.Exit(1) }
	game = Game{
		Width: w,
		Height: h,
	} ; game.Ball = Ball{
		X: (h/2)-1,
		Y: (h/2)-1,
	} ; game.P1 = Paddle {
			Height: h/10,
	} ; game.P2 = Paddle {
			Height: h/10,
	}
	game.P2.Pos = game.Height - game.P2.Height
	game.View, game.Pre = []string{}, []string{}
	for _ = range game.Height {
		var l, o string
		for _ = range game.Width { l += " " ; o += "." }
		game.View = append(game.View, l)
		game.Pre = append(game.Pre, o)
	}
}
