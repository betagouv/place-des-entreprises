import { Controller } from "stimulus";

export default class extends Controller {
  open(event) {
    let button = event.currentTarget;
    const togglable = document.getElementById(
      button.getAttribute("aria-controls")
    );
    button.dataset.rfOpened = true;
    togglable.classList.add("fr-modal--opened");
    togglable.setAttribute("aria-modal", true);
    document.querySelector("html").classList.add("fr-no-scroll");
  }

  close(event) {
    let button = event.currentTarget;
    const togglable = document.getElementById(
      button.getAttribute("aria-controls")
    );
      togglable.classList.remove("fr-modal--opened");
      togglable.removeAttribute("aria-modal");
      button.dataset.rfOpened = false;
      document.querySelector("html").classList.remove("fr-no-scroll");
  }
}
