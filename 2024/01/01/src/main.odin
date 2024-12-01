package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {
    r: bufio.Reader
    bufio.reader_init(&r, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&r)

    left_list: [dynamic]u32
    right_list: [dynamic]u32

    for {
        line, err := bufio.reader_read_string(&r, '\n')
        if err != nil {
            break
        }
        defer delete(line)

        // Remove windows endings, if necessary
        line = strings.trim_right(line, "\r\n")

        nums := strings.split(line, "   ")
        strings.trim_space(nums[0])
        strings.trim_space(nums[1])

        left_num, ok_left := strconv.parse_uint(nums[0])
        if !ok_left {
            fmt.printfln("Failed to parse: {}", nums[0])
            os.exit(1)
        }

        right_num, ok_right := strconv.parse_uint(nums[1])
        if !ok_right {
            fmt.printfln("Failed to parse: {}", nums[1])
            os.exit(1)
        }

        append(&left_list, u32(left_num))
        append(&right_list, u32(right_num))
    }

    sort.quick_sort(left_list[:])
    sort.quick_sort(right_list[:])

    rows := soa_zip(left_list[:], right_list[:])

    num_rows := len(&left_list)
    sum_diff: u32 = 0
    for left, i in left_list {
        right := right_list[i]

        if left > right {
            sum_diff += left - right
        } else {
            sum_diff += right - left
        }
    }

    fmt.printfln("total difference: {}", sum_diff)
}
