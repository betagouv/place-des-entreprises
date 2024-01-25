import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "checkboxes" ]

  autoUncheck(event) {
    let currentCheckbox = event.currentTarget
    for(let checkbox of this.checkboxesTargets) {
      if (checkbox !== currentCheckbox) {
        checkbox.checked = false
      }
    }
  }
}
