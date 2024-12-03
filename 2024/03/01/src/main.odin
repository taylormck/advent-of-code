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

    for {
        c, _, err := bufio.reader_read_rune(&r)
        if err != nil {
            break
        }

        switch (current_state) {
        case .M:
            if c == 'm' {
                current_state = .U
            }
        case .U:
            if c == 'u' {
                current_state = .L
            } else {
                current_state = .M
            }
        case .L:
            if c == 'l' {
                current_state = .LeftParen
            } else {
                current_state = .M
            }
        case .LeftParen:
            if c == '(' {
                current_state = .LeftNumber
            } else {
                current_state = .M
            }
        case .LeftNumber:
            if unicode.is_digit(c) {
                if len(left_digit_buffer) < 3 {
                    append(&left_digit_buffer, c)
                } else {
                    clear(&left_digit_buffer)
                    current_state = .M
                }
            } else if c == ',' {
                current_state = len(left_digit_buffer) > 0 ? .RightNumber : .M
            } else {
                clear(&left_digit_buffer)
                current_state = .M
            }

        case .RightNumber:
            if unicode.is_digit(c) {
                if len(right_digit_buffer) < 3 {
                    append(&right_digit_buffer, c)
                } else {
                    clear(&left_digit_buffer)
                    clear(&right_digit_buffer)
                    current_state = .M
                }
            } else if c == ')' {
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

                // fmt.printfln("left_num: {}", left_num)
                // fmt.printfln("right_num: {}", right_num)
                // fmt.printfln("total: {}\n", total)

                clear(&left_digit_buffer)
                clear(&right_digit_buffer)
                current_state = .M
            } else {
                clear(&left_digit_buffer)
                clear(&right_digit_buffer)
                current_state = .M
            }
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
}
