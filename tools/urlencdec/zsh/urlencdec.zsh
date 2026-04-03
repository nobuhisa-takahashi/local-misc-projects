#!/bin/zsh
# urlencdec — URLエンコード/デコード (zsh関数版)
# 使用方法: echo "文字列" | urlencdec [-d]

urlencdec() {
    local decode=0

    while getopts "dh" opt; do
        case $opt in
            d) decode=1 ;;
            h)
                echo "Usage: urlencdec [-d] [-h]"
                echo ""
                echo "URL encode/decode filter (RFC 3986)."
                echo "Reads from stdin, writes to stdout."
                echo ""
                echo "Options:"
                echo "  -d    Decode (default: encode)"
                echo "  -h    Show this help"
                return 0
                ;;
            *) echo "Usage: urlencdec [-d] [-h]" >&2; return 1 ;;
        esac
    done

    local input
    input=$(cat)

    if [[ $decode -eq 1 ]]; then
        # URLデコード: %XX を対応する文字に変換
        local result=""
        local i=1
        local len=${#input}
        while [[ $i -le $len ]]; do
            local char="${input[$i]}"
            if [[ "$char" = "%" ]] && [[ $((i + 2)) -le $len ]]; then
                local hex="${input[$((i+1)),$((i+2))]}"
                # printf で16進数をバイトに変換
                result+=$(printf "\\x${hex}")
                i=$((i + 3))
            elif [[ "$char" = "+" ]]; then
                result+=" "
                i=$((i + 1))
            else
                result+="$char"
                i=$((i + 1))
            fi
        done
        printf '%s' "$result"
    else
        # URLエンコード: RFC 3986 準拠
        # 英数字と -._~ 以外をパーセントエンコード
        local LC_ALL=C
        local byte
        local -a bytes
        # 入力をバイト列として処理
        bytes=( $(printf '%s' "$input" | od -An -tx1) )
        local result=""
        for byte in "${bytes[@]}"; do
            local dec=$((16#$byte))
            # A-Z: 0x41-0x5A, a-z: 0x61-0x7A, 0-9: 0x30-0x39
            # '-': 0x2D, '.': 0x2E, '_': 0x5F, '~': 0x7E
            if (( (dec >= 0x41 && dec <= 0x5A) ||
                  (dec >= 0x61 && dec <= 0x7A) ||
                  (dec >= 0x30 && dec <= 0x39) ||
                  dec == 0x2D || dec == 0x2E ||
                  dec == 0x5F || dec == 0x7E )); then
                result+=$(printf "\\x${byte}")
            else
                result+="%${(U)byte}"
            fi
        done
        printf '%s' "$result"
    fi
}

# スクリプトとして直接実行された場合
if [[ "${(%):-%N}" = "$0" ]]; then
    urlencdec "$@"
fi
