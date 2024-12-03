package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"

MAX_DIFFERENCE :: 3

main :: proc() {
    r: bufio.Reader
    bufio.reader_init(&r, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&r)

    total := 0

    left_digit_buffer: [dynamic]rune
    defer delete(left_digit_buffer)

    right_digit_buffer: [dynamic]rune
    defer delete(right_digit_buffer)

    current_state: ParserState = .M

    enabled := true

    for {
        c, _, err := bufio.reader_read_rune(&r)
        if err != nil {
            break
        }

        switch (current_state) {
        case .M:
            if enabled && c == 'm' {
                current_state = .U
            } else if c == 'd' {
                current_state = .O
            }

        case .U:
            current_state = c == 'u' ? .L : .M

        case .L:
            current_state = c == 'l' ? .LeftParen : .M

        case .LeftParen:
            current_state = c == '(' ? .LeftNumber : .M

        case .LeftNumber:
            switch {
            case unicode.is_digit(c):
                if len(left_digit_buffer) < 3 {
                    append(&left_digit_buffer, c)
                } else {
                    clear(&left_digit_buffer)
                    current_state = .M
                }

            case c == ',':
                current_state = len(left_digit_buffer) > 0 ? .RightNumber : .M

            case:
                clear(&left_digit_buffer)
                current_state = .M
            }

        case .RightNumber:
            switch {
            case unicode.is_digit(c):
                if len(right_digit_buffer) < 3 {
                    append(&right_digit_buffer, c)
                } else {
                    clear(&left_digit_buffer)
                    clear(&right_digit_buffer)
                    current_state = .M
                }

            case c == ')':
                if len(right_digit_buffer) == 0 {
                    clear(&left_digit_buffer)
                    current_state = .M
                    continue
                }

                left_str := utf8.runes_to_string(left_digit_buffer[:])
                right_str := utf8.runes_to_string(right_digit_buffer[:])

                left_num := strconv.atoi(left_str)
                right_num := strconv.atoi(right_str)

                total += left_num * right_num

                clear(&left_digit_buffer)
                clear(&right_digit_buffer)
                current_state = .M

            case:
                clear(&left_digit_buffer)
                clear(&right_digit_buffer)
                current_state = .M
            }

        case .O:
            current_state = c == 'o' ? .N : .M

        case .N:
            switch c {
            case '(':
                current_state = .DoRightParen
            case 'n':
                current_state = .Apostrophe
            case:
                current_state = .M
            }

        case .DoRightParen:
            if c == ')' {
                enabled = true
            }
            current_state = .M

        case .Apostrophe:
            current_state = c == '\'' ? .T : .M

        case .T:
            current_state = c == 't' ? .DontLeftParen : .M

        case .DontLeftParen:
            current_state = c == '(' ? .DontRightParen : .M

        case .DontRightParen:
            if c == ')' {
                enabled = false
            }
            current_state = .M
        }
    }

    fmt.printfln("{}", total)
}

ParserState :: enum {
    M,
    U,
    L,
    LeftParen,
    LeftNumber,
    RightNumber,
    O,
    N,
    DoRightParen,
    Apostrophe,
    T,
    DontLeftParen,
    DontRightParen,
}
