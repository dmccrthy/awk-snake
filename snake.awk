#!/usr/bin/awk -f
#
# snake.awk - A snake game written in AWK
#
# Description:
#   This is my take on Snake implemented in the AWK programming
#   language. This isn't intended to be good or even fun but instead
#   a test to see if its possible.
#
# Author: Dan McCarthy
# Date: 3/16/2026

BEGIN {
    # disable terminal cursor and print header messages
    print "\x1b[?25l" 
    print "\x1b[0;0H\x1b[J" "PRESS 'q' TO EXIT ---- WASD TO MOVE"

    #
    GRID_HEIGHT = 10
    GRID_WIDTH = 20
    GRID_OFFSET = 3

    # QUEUE is a global var that tracks coordinates of the players tail segments
    # QUEUE_START/END track the index of elements in queue (as internally it uses an array)
    QUEUE_START = 0
    QUEUE_END = 0

    # MAP tracks which tiles the snake is in (when rendering)
    init_grid(MAP)

    # player is an array that tracks 
    player["x"] = 5
    player["y"] = 10
    player["length"] = 0

    generate_fruit(fruit)

    # initial render of the screen
    render_screen()

    # main event loop
    for (;;) {
        input = get_input()

        if (input ~ "[wasd]") {
            # previous location needs to be tracked so we can update MAP
            x = player["x"]
            y = player["y"]

            if (input == "w")
                player["x"]--
            if (input == "s") 
                player["x"]++
            if (input == "a")
                player["y"]--
            if (input == "d")
                player["y"]++

            # check_collision()

            if (player["x"] == fruit["x"] && player["y"] == fruit["y"]) {
                update_length(x, y)
                generate_fruit(fruit)
            } else {
                MAP[x, y] = 1
                enqueue(x, y)

                dequeue()
                MAP[QUEUE_TMP[1], QUEUE_TMP[2]] = 0
            }
        }

        # Exit gracefully (so that END is run)
        if (input == "q") exit

        render_screen()
    }
}

# ===
#
# ===
function init_grid(grid) {
    for (i = 0; i <= GRID_HEIGHT; i++) {
        for (j = 0; j <= GRID_WIDTH; j++) {
            grid[i, j] = 0
        }
    }
}

function enqueue(x, y) {
    QUEUE[QUEUE_START] = x "," y
    QUEUE_START++

    # debug(x, y)
}

function dequeue() {
    split(QUEUE[QUEUE_END], QUEUE_TMP, ",")
    delete QUEUE[QUEUE_END++]

    debug(QUEUE_TMP[1] QUEUE_TMP[2])

    #
}

function debug(var1, var2) {
    print "\x1b[" LINE_ROW ";30H" var1 " " var2
    LINE_ROW++
}

# ===
# Read and return input from stdin. This reads the next input 
# character and returns it (this is used to handle player movement)
# ===
function get_input() {
    command = "read -n 1; echo $REPLY" 
    command | getline input
    close(command)

    return input
}

# ===
# Update position of cursor using ANSI escape sequences.
#
# Parameters:
#   x - Row of cursor
#   y - Column of cursor
# ===
function update_cursor(x, y) {
    return "\x1b[" x+GRID_OFFSET ";" y "H"
}

# ===
# Regenerate the fruit at a random location within the map.
#
# Parameters:
#   fruit - the fruit object (with x/y coords)
# ===
function generate_fruit(fruit) {
    fruit["x"] = int(rand() * 10)
    fruit["y"] = int(rand() * 10)
}

# ===
#
# ===
function update_length(x, y) {
    player["length"]++
    MAP[x, y] = 1
    enqueue(x, y)
}

# ===
#
#
# Parameters:
#   prev - the previous tail coordinates
# ===
function update_tail(prev) {

}

# ===
#
# ===
function render_screen() {
    for(position in MAP) {
        #
        split(position, coords, SUBSEP)
        row = coords[1]
        column = coords[2]

        move_cursor = update_cursor(row, column)

        if (row == player["x"] && column == player["y"]) {
            print move_cursor "O"
        } else if (MAP[row,column] == 1) {
            print move_cursor "o"
        } else {
            print move_cursor "_"
        }
    }

    #
    print update_cursor(player["x"], player["y"]) "O"
    print update_cursor(fruit["x"], fruit["y"]) "*"
}

END {
    # clear screen/enable terminal cursor
    print "\x1b[J\x1b[?25h"
}
