#!/usr/bin/awk -f
#
# snake.awk - A snake game written in AWK
#
# Description:
#   ... 
#
# Author: Dan McCarthy
# Date: 3/16/2026

BEGIN {
    # disable terminal cursor
    print "\x1b[?25l"

    #
    GRID_HEIGHT = 10
    GRID_WIDTH = 20

    # Init grid variable with map
    # tracks position of trailing 
    init_grid(tail_grid)

    #
    player["x"] = 10
    player["y"] = 10
    player["direction"] = "w"
    player["length"] = 0

    generate_fruit(fruit)


    # initial render of the screen
    render_screen()

    # main event loop
    for (;;) {
        input = get_input()

        if (input ~ "[wasd]") {
            prev["x"] = player["x"]
            prev["y"] = player["y"]

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
                #
                update_length(prev)
                generate_fruit(fruit)
            } else {

            }
        }


        # Exit gracefully (so that END is run)
        if (input == "q")
            exit
        
        #
        #update_length()
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

# ===
#
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
    return "\x1b[" x ";" y "H"
}

# ===
#
# ===
function generate_fruit(fruit) {
    fruit["x"] = int(rand() * 10)
    fruit["y"] = int(rand() * 10)
}

# ===
#
# ===
function update_length() {
    if (player["x"] == fruit["x"] && player["y"] == fruit["y"]) {
        # player["length"]++
        # fruit["x"] = 10
        # fruit["y"] = 10
    }
}

# ===
#
# ===
function render_screen() {
    print "\x1b[0;0H\x1b[J"

    for(position in tail_grid) {
        #
        split(position, coords, SUBSEP)
        row = coords[1]
        column = coords[2]

        move_cursor = update_cursor(row, column)

        if (row == player["x"] && column == player["y"]) {
            print move_cursor "O"
        } else if (tail_grid[row,column] == 1) {
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
