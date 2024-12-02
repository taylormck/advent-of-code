package main

import "core:bufio"
import "core:fmt"
import "core:math"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"

MAX_DIFFERENCE :: 3

main :: proc() {
    r: bufio.Reader
    bufio.reader_init(&r, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&r)

    reports: [dynamic][dynamic]int

    for {
        line, err := bufio.reader_read_string(&r, '\n')
        if err != nil {
            break
        }
        defer delete(line)

        // Remove windows endings, if necessary
        line = strings.trim_right(line, "\r\n")

        nums := strings.split(line, " ")

        report: [dynamic]int

        for num in nums {
            n, ok := strconv.parse_int(num)
            if !ok {
                fmt.printfln("Failed to parse: {}", num)
                os.exit(1)
            }

            append(&report, n)
        }

        append(&reports, report)
    }

    safe_report_count := 0

    for report in reports {
        if report_is_safe_damp(report[:]) {
            safe_report_count += 1
        }
    }

    fmt.printfln("{}", safe_report_count)
}

report_is_safe_damp :: proc(report: []int) -> bool {
    for i in 0 ..< len(report) {
        if report_is_safe_damp_skip(report, i) {
            return true
        }
    }

    return false
}

report_is_safe_damp_skip :: proc(report: []int, skip: int) -> bool {
    end := skip == len(report) - 1 ? skip - 1 : len(report) - 1
    len := skip >= 0 && skip < len(report) ? len(report) - 2 : len(report) - 1

    sum_change := 0
    safe := true

    for i in 0 ..< end {
        if i != skip {
            j := skip != i + 1 ? i + 1 : i + 2
            sum_change += slope(report[i], report[j])

            diff := math.abs(report[i] - report[j])

            if diff <= 0 || diff > 3 {
                return false
            }
        }
    }

    return math.abs(sum_change) == len
}

slope :: proc(a: int, b: int) -> int {
    if a < b {
        return 1
    } else if a > b {
        return -1
    }

    return 0
}
