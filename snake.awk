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

    # Init grid variable with map
    #
    init_grid(tail_grid)

    #
    player["x"] = 10
    player["y"] = 10
    player["length"] = 1

    fruit["x"] = 2
    fruit["y"] = 2


    # initial render of the screen
    render_screen()

    # main event loop
    for (;;) {
        input = get_input()

        if (input == "w")
            player["x"]--
        if (input == "s") 
            player["x"]++
        if (input == "a")
            player["y"]--
        if (input == "d")
            player["y"]++

        # Exit gracefully (so that END is run)
        if (input == "q")
            exit
        
        #
        update_length()
        render_screen()
    }
}

# ===
#
# ===
function init_grid(grid) {
    grid_height = 10
    grid_width = 20

    for (i = 0; i <= grid_height; i++) {
        for (j = 0; j <= grid_width; j++) {
            grid[i, j] = 0
        }
    }
}

# ===
#
# ===
function get_input() {
    command = "read -s -n 1; echo $REPLY" 
    command | getline input
    close(command)

    return input
}

# ===
#
# ===
function update_length() {
    if (player["x"] == fruit["x"] && player["y"] == fruit["y"])
        player["length"]++
        fruit["x"] = 10
        fruit["y"] = 10
}

# ===
#
# ===
function render_screen() {
    print "\x1b[0;0H\x1b[J"

    move_cursor = "\x1b[" row ";" column "H"

    for(position in tail_grid) {
        #
        split(position, coords, SUBSEP)
        row = coords[1]
        column = coords[2]


        if (row == player["x"] && column == player["y"])
            print move_cursor "O"
        
        if (tail_grid[row,column] == 1)
            print move_cursor "o"
        else
            print move_cursor "_"
    }

    row = player["x"]
    column = player["y"]
    print move_cursor "O"

    # reset cursor to orignal position
    print "\x1b[0;0H"
}

END {
    # enable terminal cursor
    print "\x1b[?25h"
}
