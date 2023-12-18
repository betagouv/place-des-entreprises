import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "prefilledField" ]

  prefill(event) {
    event.preventDefault()
    let button = event.currentTarget
    let content = button.dataset.content

    this.prefilledFieldTarget.value = content
  }

  reset(event) {
    event.preventDefault()
    this.prefilledFieldTarget.value = ""
  }
}
