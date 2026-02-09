package main

import (
	"os"
	"fmt"
)

const user_char = "\033[48;2;255;199;119m \033[0m"

var fd int
var y_pos = 1
var term_spec struct {
	height int
	width int
}

func main() {
	state, sig := init_term()
	go wait_clean_and_close(state, sig)
	
	for {
		cls()
		for i := range 4 {
			fmt.Printf("\033[%d;2H%s", y_pos+i, user_char)
		}

		b := make([]byte, 1)
		_, e := os.Stdin.Read(b)
		if e != nil {
			go func() { sig <- os.Interrupt }()
			fmt.Fprintf(os.Stderr, "failed to get keypress: %v", e)
		}

		switch b[0] {
		 case 'q', 3: sig <- os.Interrupt
		 case 'j': if y_pos < term_spec.height-3 { y_pos++ }
		 case 'k': if y_pos > 1 { y_pos-- }
		 default:
//			fmt.Printf("char: %c (decimal: %d)\r\n", b[0], b[0])
		}
	}
}
