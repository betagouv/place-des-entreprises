import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "blockContent" ]

  close() {
    // pour que le cookie soit valable sur toutes les pages (par défaut : que la page en cours)
    document.cookie = "bandeau_info_read=true; path=/";
    this.blockContentTarget.remove()
  }
}
