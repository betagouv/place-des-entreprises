import { Controller } from "@hotwired/stimulus";
import { debounce } from '../../shared/utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';

export default class extends Controller {
  static targets = [ "field", "loader", "expertField", "form" ]

  initialize() {
    this.statusMessage = null;
    this.accessibleAutocomplete = accessibleAutocomplete({
      element: this.fieldTarget,
      id: this.fieldTarget.dataset.name,
      name: 'expert',
      showNoOptionsFound: true,
      required: true,
      minLength: 3,
      templates: {
        inputValue: this.inputValueTemplate,
        suggestion: this.suggestionTemplate
      },
      tNoResults: () => this.statusMessage,
      tAssistiveHint: () => this.fieldTarget.dataset.assistiveHint,
      tStatusNoResults: () => this.statusMessage,
      tStatusSelectedOption: (selectedOption, length, index) => `${selectedOption} ${index + 1} sur ${length} est sélectionné`,
      tStatusResults: (length, contentSelectedOption) => {
        const baseSentence = (length === 1) ? "1 résultat trouvé" : `${length} résultats trouvés`
        return `${baseSentence}. ${contentSelectedOption}`
      },
      source: debounce(async (query, populateResults) => {
        const results = await this.searchResults(query);
        if(!results) return;
        if (results.error) {
          this.manageSourceError(results)
        } else {
          this.manageSourceSuccess(results.data)
          populateResults(results.data)
        }
      }, 300),
      onConfirm: (option) => {
        this.onConfirm(option)
      }
    })
  }

  manageSourceError(results) {
    this.loaderTarget.style.display = 'none'
    this.statusMessage = results.error
  }

  manageSourceSuccess(items) {
    this.loaderTarget.style.display = 'none'
    this.statusMessage = (items.length == 0) ? "Aucun résultat trouvé" : null
  }

  onConfirm(option) {
    if (option) {
      this.fillResultField(option);
    }
  }

  // Récupération des résultats ----------------------------------------------------

  async searchResults(query) {
    this.loaderTarget.style.display = 'block'
    let searchUrl = this.fieldTarget.dataset.searchUrl
    let params = `omnisearch=${query}`;
    let response = await fetch(`${searchUrl}.json?${params}`, {
      credentials: "same-origin",
    });
    // Au cas où autre chose que du json est renvoyé
    try {
      let data = await response.json();
      return data;
    } catch(err) {
      this.manageSourceError({error: "Problème de réception des données, veuillez réessayer avec d'autres paramètres"})
    }
  }

  // Traitement des résultats --------------------------------------------

  fillResultField(result) {
    if (result) {
      this.expertFieldTarget.value = parseInt(result.id)
      this.formTarget.requestSubmit()
    }
  }

  suggestionTemplate (result) {
    if (result) {
      let expertSubjects = result.experts_subjects.map(es => `<li>${es.institution_subject_description}</li>`).join('')
      return (
        `<div class="fr-grid-row">
        <div class="fr-col">
          <h3 class="fr-text--lead fr-m-0">${result.antenne_name}</h3>
          <p class="fr-text--sm bold fr-m-0">${result.full_name}</p>
          <p class="fr-text--sm fr-m-0">${result.job || ''}</p>
        </div>
        <div class="fr-col">
          <ul class="fr-m-0">
            ${expertSubjects}
          </ul>
        </div>
        </div>`
      );
    }
  }

  inputValueTemplate (result) {
    if (!result) return null;
    return "";
  }
}
