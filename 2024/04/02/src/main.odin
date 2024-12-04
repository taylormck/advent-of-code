package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"


MATCH_RUNES: []rune = {'M', 'A', 'S'}

DIRECTIONS: [][2]int : {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}

rows: [dynamic][]rune

main :: proc() {
    r: bufio.Reader
    bufio.reader_init(&r, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&r)

    for {
        line, err := bufio.reader_read_string(&r, '\n')
        if err != nil {
            break
        }
        defer delete(line)

        // Remove windows endings, if necessary
        line = strings.trim_right(line, "\r\n")

        append(&rows, utf8.string_to_runes(line))
    }

    double_match_count := 0

    for row, row_index in rows {
        for c, column_index in row {
            double_match_count += matches({column_index, row_index})
        }
    }

    fmt.printfln("{}", double_match_count / 2)
}

matches :: proc(coordinates: [2]int) -> int {
    num_matches := 0
    for direction in DIRECTIONS {
        if match_direction(coordinates, direction, 0, false) {
            num_matches += 1
        }
    }

    return num_matches
}

match_direction :: proc(
    coordinates: [2]int,
    direction: [2]int,
    target_index: int,
    crossing: bool,
) -> bool {
    if target_index >= len(MATCH_RUNES) {
        if crossing {
            return true
        }

        end_coordinates := coordinates - direction
        offset := len(MATCH_RUNES) - 1

        if match_direction(
            {end_coordinates.x, end_coordinates.y + offset * -direction.y},
            {-direction.x, direction.y},
            0,
            true,
        ) {
            return true
        }

        return match_direction(
            {end_coordinates.x + offset * -direction.x, end_coordinates.y},
            {direction.x, -direction.y},
            0,
            true,
        )
    }

    if coordinates.x < 0 ||
       coordinates.y < 0 ||
       coordinates.y >= len(rows) ||
       coordinates.x >= len(rows[0]) {
        return false
    }

    if rows[coordinates.y][coordinates.x] == MATCH_RUNES[target_index] {
        return match_direction(
            coordinates + direction,
            direction,
            target_index + 1,
            crossing,
        )
    }

    return false
}
