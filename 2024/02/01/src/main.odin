package main

import "core:bufio"
import "core:fmt"
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

    loop: for report in reports {
        if len(report) < 2 {
            continue
        }

        // Decreasing
        if report[0] > report[1] {
            for i := 0; i < len(report) - 1; i += 1 {
                diff := report[i] - report[i + 1]

                if diff > 3 || diff <= 0 {
                    continue loop
                }
            }
        } else {
            // Increasing
            for i := 0; i < len(report) - 1; i += 1 {
                diff := report[i + 1] - report[i]

                if diff > 3 || diff <= 0 {
                    continue loop
                }
            }
        }

        safe_report_count += 1
    }

    fmt.printfln("{}", safe_report_count)
}
