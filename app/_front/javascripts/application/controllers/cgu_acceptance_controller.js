import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "acceptedCheckbox", "acceptedAtField" ]

  connect() {
    this.toggleField()
  }

  toggleField() {
    let checkbox = this.acceptedCheckboxTarget;
    if(checkbox.checked) {
      this.acceptedAtFieldTarget.removeAttribute("disabled");
    } else {
      this.acceptedAtFieldTarget.setAttribute("disabled", "true");
    }
  }
}
