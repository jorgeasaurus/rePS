/* reps-rept-loop: the rePS loop. `rept` runs Pester on an exercise, one test fails,
 * the learner fixes it, and the next `rept` passes.
 * Adapted for rePS from test-runner-dots by ASCII Magic (MIT, see ../LICENSE). */
import { Grid, palette } from "../lib/kit.js";

export const meta = {
  slug: "reps-rept-loop",
  name: "rePS Practice Loop",
  category: "screens",
  note: "rept runs Pester on an exercise: one test fails, the fix goes in, and the next run passes.",
  tags: ["tests", "terminal", "powershell", "pester"],
  cols: 72, rows: 24, fps: 24,
  palette: palette(["#e6edf3", "#8b949e", "#7ee787", "#79c0ff", "#ffa657", "#ff7b72", "#d2a8ff", "#484f58", "#30363d", "#f2cc60"]),
};

// Colours: 0 text, 1 dim, 2 green, 3 blue, 5 red, 6 purple, 7 border.
const TYPE = 0.05;   // seconds per typed character
const LINE = 0.28;   // seconds between streamed output lines

// [kind, text, colour]. "type" lines are typed after a PS prompt; "out" lines stream in;
// "test" lines are [kind, name, passed, ms]; "gap" adds a pause.
const SCRIPT = [
  ["type", "rept"],
  ["out", "Describing Get-FizzBuzz", "2"],
  ["test", "returns Max items", true, 14],
  ["test", "produces the first 15 correctly", true, 9],
  ["test", "outputs strings, not integers", false, 6],
  ["out", "    Expected type [string], but got 1 [int].", "5"],
  ["test", "handles Max = 1", true, 3],
  ["out", "Tests Passed: 3, Failed: 1", "1"],
  ["out", "  NOT YET - 1 failing, 3 passing. Stuck? reph", "5"],
  ["gap", 1.4],
  ["type", "# fix: else { \"$i\" } instead of else { $i }", "1"],
  ["type", "rept"],
  ["out", "Describing Get-FizzBuzz", "2"],
  ["test", "returns Max items", true, 12],
  ["test", "produces the first 15 correctly", true, 8],
  ["test", "outputs strings, not integers", true, 4],
  ["test", "handles Max = 1", true, 3],
  ["out", "Tests Passed: 4, Failed: 0", "1"],
  ["out", "  PASSED - 4/4 tests. Next rep: reps", "2"],
];

// Pre-compute when each line starts and how long it takes.
const TIMELINE = [];
let clock = 0.4;
for (const step of SCRIPT) {
  if (step[0] === "gap") { clock += step[1]; continue; }
  const duration = step[0] === "type" ? step[1].length * TYPE + 0.35 : LINE;
  TIMELINE.push({ step, start: clock, duration });
  clock += duration;
}
const RUN = clock;
const PERIOD = RUN + 4;

export default function create() {
  const g = new Grid(meta.cols, meta.rows);
  const W = meta.cols, H = meta.rows;

  return (t) => {
    g.clear();
    const lt = t % PERIOD;
    g.box(0, 0, W, H, "round", "7");
    g.text(2, 0, " ~/.reps/workspace ", "1");

    let y = 1;
    for (const { step, start, duration } of TIMELINE) {
      if (lt < start) break;
      const [kind] = step;
      if (kind === "type") {
        const [, text, colour] = step;
        g.text(2, y, "PS>", "3");
        const shown = Math.min(text.length, Math.floor((lt - start) / TYPE));
        g.text(6, y, text.slice(0, shown), colour || "0");
        if (lt < start + duration && Math.floor(lt * 3) % 2 === 0) g.set(6 + shown, y, "█", "0");
      } else if (kind === "test") {
        const [, name, passed, ms] = step;
        g.text(4, y, passed ? "[+]" : "[-]", passed ? "2" : "5");
        g.text(8, y, name, passed ? "0" : "5");
        g.text(9 + name.length, y, `${ms}ms`, "1");
      } else {
        const [, text, colour] = step;
        g.text(2, y, text, colour);
      }
      y++;
      if (y >= H - 1) break;
    }

    if (lt >= RUN && y < H - 1) {
      g.text(2, y, "PS>", "3");
      if (Math.floor(lt * 3) % 2 === 0) g.set(6, y, "█", "0");
    }
    return g.frame();
  };
}
