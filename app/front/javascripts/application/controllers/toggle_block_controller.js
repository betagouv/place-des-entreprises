import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "itemId" ]

  show(event) {
    event.preventDefault();
    let button = event.currentTarget;
    let itemId = button.dataset.itemId
    button.setAttribute('aria-expanded', true)
    this.itemIdTarget.value = itemId

    let togglable = document.getElementById(
      button.getAttribute("aria-controls")
    );
    let newTurboFrameSelector = togglable.querySelector('form').dataset.turboFrame.replace('XXX', itemId)
    togglable.querySelector('form').dataset.turboFrame = newTurboFrameSelector
    togglable.classList.remove("hidden");
  }
}
