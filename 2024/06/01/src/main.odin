package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Direction :: enum {
    Up,
    Down,
    Left,
    Right,
}

DirectionVector: [Direction][2]int = {
    .Up    = {0, -1},
    .Down  = {0, 1},
    .Left  = {-1, 0},
    .Right = {1, 0},
}

Status :: enum {
    Blocked,
    Empty,
    Visited,
}

Guard :: struct {
    position:  Position,
    direction: Direction,
}

Position :: [2]int
FloorMap :: [dynamic][dynamic]Status

main :: proc() {
    r: bufio.Reader
    bufio.reader_init(&r, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&r)

    floor_map, guard := read_floor_map(&r)

    count_spaces := 0
    left_board := false

    for !left_board {
        if floor_map[guard.position.y][guard.position.x] == .Empty {
            count_spaces += 1
            floor_map[guard.position.y][guard.position.x] = .Visited
        }
        guard, left_board = guard_move(&guard, floor_map)
    }

    fmt.printfln("{}", count_spaces)
}

read_floor_map :: proc(
    r: ^bufio.Reader,
) -> (
    floor_map: FloorMap,
    guard: Guard,
) {
    row_index := 0
    column_index := 0

    for {
        line, err := bufio.reader_read_string(r, '\n')
        defer delete(line)
        if err != nil {
            break
        }

        // Remove windows endings, if necessary
        line = strings.trim_right(line, "\r\n")

        row: [dynamic]Status
        column_index = 0

        for rune in utf8.string_to_runes(line) {
            status, has_guard, direction := status_from_char(rune)

            if has_guard {
                guard = {
                    position  = {column_index, row_index},
                    direction = direction,
                }
            }

            append(&row, status)
            column_index += 1
        }

        append(&floor_map, row)
        row_index += 1
    }

    return
}

status_from_char :: proc(
    c: rune,
) -> (
    status: Status,
    has_guard: bool,
    direction: Direction,
) {
    switch c {
    case '.':
        status = .Empty
    case '^':
        status = .Empty
        has_guard = true
        direction = .Up
    case '>':
        status = .Empty
        has_guard = true
        direction = .Right
    case 'V':
        status = .Empty
        has_guard = true
        direction = .Down
    case '<':
        status = .Empty
        has_guard = true
        direction = .Left
    case '#':
        status = .Blocked
    case 'X':
        status = .Visited
    case:
        fmt.eprintfln("Unsupported status code: {}", c)
        os.exit(1)
    }

    return
}

is_on_map :: proc(position: Position, floor_map: FloorMap) -> bool {
    max_y := len(floor_map)
    max_x := len(floor_map[0])

    return(
        position.x >= 0 &&
        position.x < max_y &&
        position.y >= 0 &&
        position.y < max_y \
    )
}

guard_move :: proc(
    guard: ^Guard,
    floor_map: FloorMap,
) -> (
    new_guard: Guard,
    left_map: bool,
) {
    new_guard.position = guard.position + DirectionVector[guard.direction]
    new_guard.direction = guard.direction

    for {
        if !is_on_map(new_guard.position, floor_map) {
            left_map = true
            break
        } else if floor_map[new_guard.position.y][new_guard.position.x] !=
           .Blocked {
            break
        }

        new_guard.direction = direction_turn_right(new_guard.direction)
        new_guard.position =
            guard.position + DirectionVector[new_guard.direction]
    }
    return
}

direction_turn_right :: proc(direction: Direction) -> Direction {
    switch (direction) {
    case .Up:
        return .Right
    case .Right:
        return .Down
    case .Down:
        return .Left
    case .Left:
        return .Up
    case:
        fmt.eprintfln("Unable to turn right: {}", direction)
        os.exit(1)
    }
}
