package main

import (
	"flag"
	"fmt"
	"io"
	"net/url"
	"os"
	"strings"
)

// RFC 3986 に準拠した URLエンコード
// 英数字と -._~ 以外をパーセントエンコード
func urlEncode(input string) string {
	var b strings.Builder
	for _, c := range []byte(input) {
		switch {
		case c >= 'A' && c <= 'Z',
			c >= 'a' && c <= 'z',
			c >= '0' && c <= '9',
			c == '-', c == '.', c == '_', c == '~':
			b.WriteByte(c)
		default:
			fmt.Fprintf(&b, "%%%02X", c)
		}
	}
	return b.String()
}

func urlDecode(input string) (string, error) {
	// + をスペースに変換してから PathUnescape
	replaced := strings.ReplaceAll(input, "+", " ")
	return url.PathUnescape(replaced)
}

func main() {
	decode := flag.Bool("d", false, "Decode (default: encode)")
	help := flag.Bool("h", false, "Show this help")
	flag.Usage = func() {
		fmt.Fprintln(os.Stderr, "Usage: urlencdec [-d] [-h]")
		fmt.Fprintln(os.Stderr)
		fmt.Fprintln(os.Stderr, "URL encode/decode filter (RFC 3986).")
		fmt.Fprintln(os.Stderr, "Reads from stdin, writes to stdout.")
		fmt.Fprintln(os.Stderr)
		fmt.Fprintln(os.Stderr, "Options:")
		fmt.Fprintln(os.Stderr, "  -d    Decode (default: encode)")
		fmt.Fprintln(os.Stderr, "  -h    Show this help")
	}
	flag.Parse()

	if *help {
		flag.Usage()
		return
	}

	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		fmt.Fprintln(os.Stderr, "エラー: 標準入力の読み取りに失敗")
		os.Exit(1)
	}

	s := string(input)

	if *decode {
		decoded, err := urlDecode(s)
		if err != nil {
			fmt.Fprintf(os.Stderr, "エラー: %v\n", err)
			os.Exit(1)
		}
		fmt.Print(decoded)
	} else {
		fmt.Print(urlEncode(s))
	}
}
