import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "dataSource", "destinationField" ]

  connect() {
    let content = this.dataSourceTarget.dataset.content;
    if (content != '') {
      this.destinationFieldTarget.value = content
    }
  }
}