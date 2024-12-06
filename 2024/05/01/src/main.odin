package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Ordering :: struct {
    first:  int,
    second: int,
}

Update :: [dynamic]int

main :: proc() {
    r: bufio.Reader
    bufio.reader_init(&r, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&r)

    orderings := read_orderings(&r)
    defer delete(orderings)

    updates := read_updates(&r)
    defer for &update in updates {
        delete(update)
    }
    defer delete(updates)

    middle_value_sum := 0

    for update in updates {
        if is_update_valid(update, orderings[:]) {
            middle_value := update_get_middle_value(update)
            middle_value_sum += middle_value
        }
    }

    fmt.printfln("{}", middle_value_sum)
}

read_orderings :: proc(r: ^bufio.Reader) -> [dynamic]Ordering {
    orderings: [dynamic]Ordering

    for {
        line, err := bufio.reader_read_string(r, '\n')
        defer delete(line)
        if err != nil {
            break
        }

        // Remove windows endings, if necessary
        line = strings.trim_right(line, "\r\n")

        if len(line) == 0 {
            break
        }

        number_strings := strings.split(line, "|")
        defer delete(number_strings)

        left_num, left_num_ok := strconv.parse_int(number_strings[0])
        if !left_num_ok {
            fmt.eprintln("Failed to parse: {}", number_strings[0])
            os.exit(1)
        }

        right_num, right_num_ok := strconv.parse_int(number_strings[1])
        if !right_num_ok {
            fmt.eprintln("Failed to parse: {}", number_strings[1])
            os.exit(1)
        }

        append(&orderings, Ordering{first = left_num, second = right_num})
    }

    return orderings
}

read_updates :: proc(r: ^bufio.Reader) -> [dynamic]Update {
    updates: [dynamic]Update

    for {
        line, err := bufio.reader_read_string(r, '\n')
        defer delete(line)
        if err != nil {
            break
        }

        line = strings.trim_right(line, "\r\n")

        page_number_strings := strings.split(line, ",")
        new_update: Update

        for s in page_number_strings {
            num, num_ok := strconv.parse_int(s)
            if !num_ok {
                fmt.eprintln("Failed to parse: {}", s)
                os.exit(1)
            }

            append(&new_update, num)
        }

        append(&updates, new_update)
    }

    return updates
}

is_update_valid :: proc(update: Update, orderings: []Ordering) -> bool {
    for ordering in orderings {
        if !is_ordering_respected(update, ordering) {
            return false
        }
    }

    return true
}

is_ordering_respected :: proc(update: Update, ordering: Ordering) -> bool {
    second_found := false

    for page_number in update {
        if page_number == ordering.second {
            second_found = true
        }

        if second_found && page_number == ordering.first {
            return false
        }
    }

    return true
}

update_get_middle_value :: proc(update: Update) -> int {
    length := len(update)

    if length % 2 == 0 {
        fmt.eprintln(
            "Cannot get middle value of update with even number of pages: {}",
            update,
        )
        os.exit(1)
    }

    return update[(length - 1) / 2]
}
