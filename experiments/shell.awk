

BEGIN {
    print shell(              \
        "sleep 1; echo 1 &\n" \
        "sleep 2; echo 2 &\n" \
        "sleep 3; echo 3 &\n" \
        "wait"                \
    )
}

function shell(code,   line, output) {
    while (code | getline line)
        output = output ? output "\n" line : line
    close(code)
    return output
}