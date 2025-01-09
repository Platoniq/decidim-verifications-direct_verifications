document.addEventListener("DOMContentLoaded", () => {
  const checkbox = document.querySelector('[type="checkbox"]#register');

  if (checkbox) {
    checkbox.addEventListener("change", (event) => {
      const label = event.target.closest("label");
      if (label) {
        const callout = label.querySelector(".callout");
        if (callout) {
          callout.classList.toggle("hide", !event.target.checked);
        }
      }
    });
  }
});
