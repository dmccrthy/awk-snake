# Snake (written in AWK)

This project is my take on a terminal-based snake game in the AWK programming language. This isn't intended to be very practical (given the language it was written in), but it does show how AWK can be used for more than just basic text processing. 

## Requirements

- GNU Awk (v5.3.1)
- Bash (v5.2.37)
    - NOTE: Older versions of Bash (like v3.x which comes with MacOS) handle the "read" builtin differently which breaks this program.

*These are the versions I used while testing. Otheres will likely work fine, but these are the versions I've verified.*

## Playing the Game

The entire game is contained within `snake.awk`. Assuming you have AWK you should be able to run the game as shown below:

```shell
./snake.awk
```