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
    init_grid(grid)

    #
    player["head"] = 10
    player["length"] = 1
    grid[5,10] = 1


    # initial render of the screen
    render_screen()

    # main event loop
    for (;;) {
        input = get_input()

        if (input == "w")
            player["row"]--
        if (input == "s") 
            player["row"]++
        if (input == "a")
            player["column"]--
        if (input == "d")
            player["column"]++

        # Exit gracefully (so that END is run)
        if (input == "q")
            exit
        
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
    command = "read -n 1; echo $REPLY" 
    command | getline input
    close(command)

    return input
}

# ===
#
# ===
function render_screen() {
    print "\x1b[0;0H\x1b[J"

    for(position in grid) {
        #
        split(position, coords, SUBSEP)
        row = coords[1]
        column = coords[2]

        move_cursor = "\x1b[" row ";" column "H"

        if (grid[row,column] == 1)
            print move_cursor "X"
        else if (grid[row,column] == 2)
            print move_cursor "O"
        else
            print move_cursor "_"
    }

    # reset cursor to orignal position
    print "\x1b[0;0H"
}

END {
    # enable terminal cursor
    print "\x1b[?25h"
}