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
    print "\x1b[?25l\x1b[2J" 
    srand()

    # Game configuration
    TICK_SPEED = 0.3

    # Display title screen (before loading real game)
    display_title()

    print "\x1b[H" "'Q' TO EXIT ---- 'WASD' TO MOVE"

    # Global variables define size of grid/offset on screen
    # this could be updated to use the terminal size (but for now doing this statically works)
    GRID_HEIGHT = 15
    GRID_WIDTH = 30
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
    player["direction"] = "w"
    player["length"] = 0

    generate_fruit(fruit)

    # initial render of the screen
    render_screen()

    # main event loop
    for (;;) {
        # input is read continuously every half second
        input = get_input()

        # previous location needs to be tracked so we can update MAP
        x = player["x"]
        y = player["y"]

        # update player direction if input is perpendicular to current direction
        if ((player["direction"] ~ "[ws]" && input ~ "[ad]") || (player["direction"] ~ "[ad]" && input ~ "[ws]")) {
            player["direction"] = input
        }

        # update position based on player direction
        if (player["direction"] == "w")
            player["x"]--
        if (player["direction"] == "s") 
            player["x"]++
        if (player["direction"] == "a")
            player["y"]--
        if (player["direction"] == "d")
            player["y"]++

        check_collision()

        if (player["x"] == fruit["x"] && player["y"] == fruit["y"]) {
            update_length(x, y)
            generate_fruit(fruit)
        } else {
            # Coordinates of the players taill is added to QUEUE.
            # When moving we add the new position and remove the end
            MAP[x, y] = 1
            enqueue(x, y)

            dequeue()
            MAP[QUEUE_TMP[1], QUEUE_TMP[2]] = 0
        }

        # Exit gracefully (so that END is run)
        if (input == "q") exit

        render_screen()
    }
}

function display_title() {
    # Title text is ASCII so chars like \ need to be escaped
    # This looks extremely ugly, but there isn't a good way to do this.
    print"\x1b[2;30H\n" \
"                           oooo\n" \
"                           `888\n" \
".oooo.   oooo oooo    ooo   888  oooo\n" \
"`P  )88b   `88. `88.  .8'   888 .8P'\n" \
" .oP\"888    `88..]88..8'    888888.\n" \
"d8(  888     `888'`888'     888 `88b.\n" \
"`Y888\"\"8o     `8'  `8'     o888o o888o\n" \
"\n" \
"                               oooo\n" \
"                               `888\n" \
" .oooo.o ooo. .oo.    .oooo.    888  oooo   .ooooo.\n" \
"d88(  \"8 `888P\"Y88b  `P  )88b   888 .8P'   d88' `88b\n" \
"`\"Y88b.   888   888   .oP\"888   888888.    888ooo888\n" \
"o.  )88b  888   888  d8(  888   888 `88b.  888    .o\n" \
"8\"\"888P' o888o o888o `Y888\"\"8o o888o o888o `Y8bod8P'"

    print "\x1b[2B\x1b[13CCreated By: Dan McCarthy\x1b[0m"
    print "\x1b[1B\x1b[13C\x1b[47;30mPRESS ANY KEY TO CONTINUE\x1b[0m"

    command = "read -s -n 1" 
    command | getline TMP
    close(command)

    print "\x1b[2J"

}

# ===
# Populates a 2D array with 0's. Indices represent the board
# and are updated to 1 when the snake is in them.
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
}

function dequeue() {
    split(QUEUE[QUEUE_END], QUEUE_TMP, ",")
    delete QUEUE[QUEUE_END++]
}

# ===
# Read and return input from stdin. This reads the next input 
# character and returns it (this is used to handle player movement)
# ===
function get_input() {
    # Wait the full tick, then drain the entire input buffer
    # keeping only the most recently pressed key
    command = \
"sleep " TICK_SPEED "; " \
"while read -s -t 0.001 -n 1 CHAR 2>/dev/null; do " \
"  LAST=\"$CHAR\"" \
"; done; " \
"echo \"$LAST\""
    command | getline input
    close(command)

    return input
}

# ===
# Update position of cursor using ANSI escape sequences.
# Updates with offset so we don't delete header.
#
# Parameters:
#   x - Row of cursor
#   y - Column of cursor
#
# Returns:
#   escape sequence - String containing ANSI escape
# ===
function update_cursor(x, y) {
    # x is offset by GRID_OFFSET to fit the header message
    # y is offset by 1 as terminal columns start at 1 and we want to begin at 0
    return "\x1b[" x+GRID_OFFSET ";" y+1 "H"
}

# ===
# Increase the snakes length and update tail position in the MAP.
# ===
function update_length(x, y) {
    player["length"]++
    MAP[x, y] = 1
    enqueue(x, y)
}

# ===
# Regenerate the fruit at a random location within the map.
#
# Parameters:
#   fruit - the fruit object (with x/y coords)
# ===
function generate_fruit(fruit) {
    fruit["x"] = int(rand() * 10) + 1
    fruit["y"] = int(rand() * 10) + 1
}

# ===
# Checks collisions based on player location. If the player
# is in the wall or inside itself the program will trigger END.
# ===
function check_collision() {
    # based on player x/y we can check if there in bounds
    out_of_bounds = player["x"] == 0 ||
        player["x"] == GRID_HEIGHT ||
        player["y"] == 0 ||
        player["y"] == GRID_WIDTH

    # if they exit the bounds (or hit themselves) the program exits and END is run
    if (MAP[player["x"],player["y"]] == 1 || out_of_bounds) {
        exit
    }
}

# ===
# Handle rerendering the screen when called. Loops over the
# MAP and fills in the snake, regular tiles, and fruit.
# ===
function render_screen() {
    for(position in MAP) {
        # Have to split up the data of the 2d array (since AWK is weird)
        # explanation here: https://www.gnu.org/software/gawk/manual/html_node/Multiscanning.html
        split(position, coords, SUBSEP)
        row = coords[1]
        column = coords[2]

        move_cursor = update_cursor(row, column)

        if (row == 0 || column == 0 || row == GRID_HEIGHT || column == GRID_WIDTH) {
            print move_cursor "#"
        } else if (row == player["x"] && column == player["y"]) {
            print move_cursor "O"
        } else if (MAP[row,column] == 1) {
            print move_cursor "o"
        } else {
            print move_cursor "_"
        }
    }

    print update_cursor(player["x"], player["y"]) "O"
    print update_cursor(fruit["x"], fruit["y"]) "*"
}

END {
    # Print ending message once game has ended
    print "\x1b[" GRID_HEIGHT + GRID_OFFSET ";0H\n"
    print "GAME OVER!\n"
    print "Final Score: " player["length"]

    # enable terminal cursor
    print "\x1b[?25h"
}