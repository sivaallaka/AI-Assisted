# 2048

A small, dependency-free implementation of the classic **2048** sliding-tile
puzzle game — plain HTML, CSS, and vanilla JavaScript (no build step, no
frameworks).

## Play

Open `index.html` in any modern browser, or serve the folder:

```bash
cd 2048
python3 -m http.server 8080
# then visit http://localhost:8080
```

## How to play

- Use the **arrow keys** (or `WASD`) to slide all tiles in a direction.
- On touch devices, **swipe** in the direction you want to move.
- Tiles with the same number **merge** into their sum when they collide.
- Reach the **2048** tile to win; the game ends when no moves remain.
- Your best score is saved locally via `localStorage`.

## Files

| File | Purpose |
|------|---------|
| `index.html` | Page markup and layout |
| `style.css`  | Board, tile colors, and animations |
| `game.js`    | Game logic: grid state, movement, merging, scoring, input |
