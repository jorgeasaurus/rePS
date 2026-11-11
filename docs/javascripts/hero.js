// rePS docs: pause/play control for the animated hero (WCAG 2.2.2).
// Pausing sets the `still` attribute, which shows the finished transcript.
(() => {
  const reduced = () => window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  const sync = () => {
    for (const button of document.querySelectorAll("[data-reps-hero-toggle]")) {
      const art = button.closest(".reps-hero")?.querySelector("ascii-art");
      if (!art) continue;
      // Nothing moves when the OS asks for reduced motion, so there is nothing to pause.
      button.hidden = reduced();
      const paused = art.hasAttribute("still");
      button.textContent = paused ? "Play animation" : "Pause animation";
    }
  };

  document.addEventListener("click", (event) => {
    const button = event.target.closest("[data-reps-hero-toggle]");
    if (!button) return;
    const art = button.closest(".reps-hero")?.querySelector("ascii-art");
    if (!art) return;
    art.toggleAttribute("still");
    sync();
  });

  // Follow OS reduced-motion changes while the page is open. Re-setting `piece` makes the
  // element restart and re-read the preference; a manual pause (`still`) is left alone.
  // One page-level listener, so there is nothing per element to clean up.
  window.matchMedia("(prefers-reduced-motion: reduce)").addEventListener("change", () => {
    for (const art of document.querySelectorAll(".reps-hero ascii-art")) {
      if (!art.hasAttribute("still")) art.setAttribute("piece", art.getAttribute("piece"));
    }
    sync();
  });

  // Material's instant navigation swaps pages without a reload; document$ fires on each.
  if (window.document$) window.document$.subscribe(sync);
  else document.addEventListener("DOMContentLoaded", sync);
})();
