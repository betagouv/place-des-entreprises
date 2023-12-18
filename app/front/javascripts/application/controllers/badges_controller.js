import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ 'form', 'list' ]

  toggleForm() {
    this.formTarget.classList.toggle("hide")
    this.listTarget.classList.toggle("hide")
  }
}
