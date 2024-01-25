import { Controller } from "stimulus";

export default class extends Controller {
  collapse(event) {
    let button = event.currentTarget;
    const collapsible = document.getElementById(
      button.getAttribute("aria-controls")
    );
    const state = button.getAttribute("aria-expanded");
    if (state == "true") {
      button.setAttribute("aria-expanded", false);
      collapsible.style.setProperty("max-height", "");
      collapsible.style.setProperty("--collapse", "-3px");
      collapsible.classList.remove("fr-collapse--expanded");
    } else {
      button.setAttribute("aria-expanded", true);
      collapsible.classList.add("fr-collapse--expanded");
      const height = collapsible.offsetHeight;
      collapsible.style.setProperty("--collapse", -height + "px");
      collapsible.style.setProperty("max-height", "none");
    }
  }
}
