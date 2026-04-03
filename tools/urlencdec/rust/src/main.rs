use std::env;
use std::io::{self, Read};

fn url_encode(input: &str) -> String {
    let mut result = String::new();
    for byte in input.as_bytes() {
        match *byte {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'.' | b'_' | b'~' => {
                result.push(*byte as char);
            }
            _ => {
                result.push_str(&format!("%{:02X}", byte));
            }
        }
    }
    result
}

fn url_decode(input: &str) -> Result<String, String> {
    let mut bytes = Vec::new();
    let input_bytes = input.as_bytes();
    let mut i = 0;
    while i < input_bytes.len() {
        match input_bytes[i] {
            b'%' => {
                if i + 2 >= input_bytes.len() {
                    return Err("不正なパーセントエンコーディング".to_string());
                }
                let hex = std::str::from_utf8(&input_bytes[i + 1..i + 3])
                    .map_err(|_| "不正な16進数".to_string())?;
                let byte = u8::from_str_radix(hex, 16)
                    .map_err(|_| format!("不正な16進数: {}", hex))?;
                bytes.push(byte);
                i += 3;
            }
            b'+' => {
                bytes.push(b' ');
                i += 1;
            }
            _ => {
                bytes.push(input_bytes[i]);
                i += 1;
            }
        }
    }
    String::from_utf8(bytes).map_err(|e| format!("不正なUTF-8: {}", e))
}

fn print_usage() {
    eprintln!("Usage: urlencdec [-d] [-h]");
    eprintln!();
    eprintln!("URL encode/decode filter (RFC 3986).");
    eprintln!("Reads from stdin, writes to stdout.");
    eprintln!();
    eprintln!("Options:");
    eprintln!("  -d    Decode (default: encode)");
    eprintln!("  -h    Show this help");
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.iter().any(|a| a == "-h") {
        print_usage();
        return;
    }

    let decode = args.iter().any(|a| a == "-d");

    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("標準入力の読み取りに失敗");

    if decode {
        match url_decode(&input) {
            Ok(decoded) => print!("{}", decoded),
            Err(e) => {
                eprintln!("エラー: {}", e);
                std::process::exit(1);
            }
        }
    } else {
        print!("{}", url_encode(&input));
    }
}
