(function () {
    "use strict";

    const SIZE = 4;
    const GAP = 12; // must match --gap in style.css
    const START_TILES = 2;

    const gridEl = document.getElementById("grid");
    const scoreEl = document.getElementById("score");
    const bestEl = document.getElementById("best");
    const overlayEl = document.getElementById("overlay");
    const overlayMsgEl = document.getElementById("overlay-message");

    let grid = [];        // 2D array of tile objects or null
    let tileId = 0;
    let score = 0;
    let best = Number(localStorage.getItem("best-2048") || 0);
    let won = false;
    let over = false;

    // ---- Board setup ----------------------------------------------------

    function buildBackground() {
        for (let i = 0; i < SIZE * SIZE; i++) {
            const cell = document.createElement("div");
            cell.className = "cell";
            gridEl.appendChild(cell);
        }
    }

    function emptyGrid() {
        return Array.from({ length: SIZE }, () => Array(SIZE).fill(null));
    }

    function init() {
        grid = emptyGrid();
        score = 0;
        won = false;
        over = false;
        overlayEl.classList.add("hidden");
        // remove existing tile elements only (keep background cells)
        gridEl.querySelectorAll(".tile").forEach((t) => t.remove());
        for (let i = 0; i < START_TILES; i++) addRandomTile();
        updateScore(0);
        render();
    }

    // ---- Tiles ----------------------------------------------------------

    function addRandomTile() {
        const empties = [];
        for (let r = 0; r < SIZE; r++) {
            for (let c = 0; c < SIZE; c++) {
                if (!grid[r][c]) empties.push({ r, c });
            }
        }
        if (!empties.length) return;
        const { r, c } = empties[Math.floor(Math.random() * empties.length)];
        grid[r][c] = {
            id: ++tileId,
            value: Math.random() < 0.9 ? 2 : 4,
            row: r,
            col: c,
            isNew: true,
            merged: false,
            el: null,
        };
    }

    function positionStyle(el, row, col) {
        const span = `(100% - ${GAP * (SIZE + 1)}px) / ${SIZE}`;
        el.style.width = `calc(${span})`;
        el.style.height = `calc(${span})`;
        el.style.left = `calc((${span}) * ${col} + ${GAP * (col + 1)}px)`;
        el.style.top = `calc((${span}) * ${row} + ${GAP * (row + 1)}px)`;
    }

    function classForValue(v) {
        return v <= 2048 ? `tile-${v}` : "tile-super";
    }

    function render() {
        for (let r = 0; r < SIZE; r++) {
            for (let c = 0; c < SIZE; c++) {
                const tile = grid[r][c];
                if (!tile) continue;
                if (!tile.el) {
                    const el = document.createElement("div");
                    el.className = "tile " + classForValue(tile.value);
                    el.textContent = tile.value;
                    positionStyle(el, r, c);
                    gridEl.appendChild(el);
                    tile.el = el;
                    // force reflow so the "new" animation triggers
                    void el.offsetWidth;
                    if (tile.isNew) el.classList.add("new");
                } else {
                    tile.el.className = "tile " + classForValue(tile.value);
                    tile.el.textContent = tile.value;
                    positionStyle(tile.el, r, c);
                    if (tile.merged) tile.el.classList.add("merged");
                }
                tile.isNew = false;
                tile.merged = false;
            }
        }
    }

    // ---- Movement -------------------------------------------------------

    // direction: 'left','right','up','down'
    function move(direction) {
        if (over) return;

        const vector = {
            left: { r: 0, c: -1 },
            right: { r: 0, c: 1 },
            up: { r: -1, c: 0 },
            down: { r: 1, c: 0 },
        }[direction];

        const order = buildTraversalOrder(direction);
        let moved = false;

        // clear merged flags
        forEachTile((t) => (t.merged = false));

        for (const { r, c } of order) {
            const tile = grid[r][c];
            if (!tile) continue;

            let nr = r;
            let nc = c;
            // slide as far as possible
            while (true) {
                const tr = nr + vector.r;
                const tc = nc + vector.c;
                if (tr < 0 || tr >= SIZE || tc < 0 || tc >= SIZE) break;
                if (!grid[tr][tc]) {
                    nr = tr;
                    nc = tc;
                } else break;
            }

            // check merge with next tile
            const mr = nr + vector.r;
            const mc = nc + vector.c;
            let mergedInto = null;
            if (
                mr >= 0 && mr < SIZE && mc >= 0 && mc < SIZE &&
                grid[mr][mc] &&
                grid[mr][mc].value === tile.value &&
                !grid[mr][mc].merged
            ) {
                mergedInto = grid[mr][mc];
            }

            if (mergedInto) {
                grid[r][c] = null;
                mergedInto.value *= 2;
                mergedInto.merged = true;
                // remove the moving tile element after it slides in
                slideAndRemove(tile, mr, mc);
                updateScore(mergedInto.value);
                if (mergedInto.value === 2048 && !won) win();
                moved = true;
            } else if (nr !== r || nc !== c) {
                grid[r][c] = null;
                grid[nr][nc] = tile;
                tile.row = nr;
                tile.col = nc;
                moved = true;
            }
        }

        if (moved) {
            render();
            addRandomTile();
            render();
            if (!movesAvailable()) gameOver();
        }
    }

    function slideAndRemove(tile, r, c) {
        if (tile.el) {
            positionStyle(tile.el, r, c);
            const el = tile.el;
            setTimeout(() => el.remove(), 120);
        }
    }

    function buildTraversalOrder(direction) {
        const rows = [...Array(SIZE).keys()];
        const cols = [...Array(SIZE).keys()];
        if (direction === "right") cols.reverse();
        if (direction === "down") rows.reverse();
        const order = [];
        for (const r of rows) for (const c of cols) order.push({ r, c });
        return order;
    }

    function forEachTile(fn) {
        for (let r = 0; r < SIZE; r++)
            for (let c = 0; c < SIZE; c++)
                if (grid[r][c]) fn(grid[r][c]);
    }

    function movesAvailable() {
        for (let r = 0; r < SIZE; r++) {
            for (let c = 0; c < SIZE; c++) {
                if (!grid[r][c]) return true;
                const v = grid[r][c].value;
                if (c + 1 < SIZE && grid[r][c + 1] && grid[r][c + 1].value === v) return true;
                if (r + 1 < SIZE && grid[r + 1][c] && grid[r + 1][c].value === v) return true;
            }
        }
        return false;
    }

    // ---- Score & state --------------------------------------------------

    function updateScore(delta) {
        score += delta;
        scoreEl.textContent = score;
        if (score > best) {
            best = score;
            localStorage.setItem("best-2048", String(best));
        }
        bestEl.textContent = best;
    }

    function win() {
        won = true;
        overlayMsgEl.textContent = "You win!";
        overlayEl.classList.remove("hidden");
    }

    function gameOver() {
        over = true;
        overlayMsgEl.textContent = "Game over!";
        overlayEl.classList.remove("hidden");
    }

    // ---- Input ----------------------------------------------------------

    const keyMap = {
        ArrowLeft: "left", ArrowRight: "right", ArrowUp: "up", ArrowDown: "down",
        a: "left", d: "right", w: "up", s: "down",
    };

    document.addEventListener("keydown", (e) => {
        const dir = keyMap[e.key];
        if (dir) {
            e.preventDefault();
            move(dir);
        }
    });

    // touch / swipe
    let touchStart = null;
    gridEl.addEventListener("touchstart", (e) => {
        touchStart = { x: e.touches[0].clientX, y: e.touches[0].clientY };
    }, { passive: true });

    gridEl.addEventListener("touchend", (e) => {
        if (!touchStart) return;
        const dx = e.changedTouches[0].clientX - touchStart.x;
        const dy = e.changedTouches[0].clientY - touchStart.y;
        const absX = Math.abs(dx);
        const absY = Math.abs(dy);
        if (Math.max(absX, absY) > 24) {
            if (absX > absY) move(dx > 0 ? "right" : "left");
            else move(dy > 0 ? "down" : "up");
        }
        touchStart = null;
    });

    document.getElementById("new-game").addEventListener("click", init);
    document.getElementById("retry").addEventListener("click", init);

    window.addEventListener("resize", render);

    // ---- Start ----------------------------------------------------------

    bestEl.textContent = best;
    buildBackground();
    init();
})();
