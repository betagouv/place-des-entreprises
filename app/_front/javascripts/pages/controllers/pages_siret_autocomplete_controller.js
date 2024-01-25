import  SiretAutocompleteController from "../../shared/controllers/siret_autocomplete_controller.js"


export default class extends SiretAutocompleteController {
  static targets = [ "field", "loader", "siretField", "codeRegionField", "noResultLink" ]

  addListeners() {
    this.fieldTarget.addEventListener('input', () => {
      if (this.siretFieldTarget.value != this.fieldTarget.value) { this.siretFieldTarget.value = '' }
    })
  }

  onConfirm(option) {
    if (option) {
      this.fillCodeRegionField(option.code_region);
      this.fillSiretField(option);
    }
  }

  manageSourceError(results) {
    this.loaderTarget.style.display = 'none'
    this.noResultLinkTarget.style.display = 'block'
    this.statusMessage = results.error
  }

  manageSourceSuccess(items) {
    this.loaderTarget.style.display = 'none'
    if (items.length == 0) {
      this.noResultLinkTarget.style.display = 'block'
      this.statusMessage = "Aucune entreprise trouvée"
    } else {
      this.statusMessage = null
    }
  }

  // Récupération des résultats ----------------------------------------------------

  displayNonDiffusableSiret() {
    return false;
  }

  // Traitement des résultats --------------------------------------------

  fillCodeRegionField(code_region) {
    if (code_region) {
      this.codeRegionFieldTarget.value = parseInt(code_region)
    }
  }
}
