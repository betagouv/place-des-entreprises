import { exists, debounce } from '../shared/utils.js'
import accessibleAutocomplete from 'accessible-autocomplete';

(function () {
  addEventListener('turbo:load', setupCityAutocomplete)

  const SEARCH_URL = 'https://api-adresse.data.gouv.fr/search/?type=municipality&q='

  function setupCityAutocomplete () {
    const targetField = document.querySelector("[data-target='insee-code']")
    const autocompleteField = document.querySelector("[data-action='city-autocomplete']")

    if (exists(autocompleteField)) {

      accessibleAutocomplete({
        element: autocompleteField,
        id: 'city_autocomplete',
        showNoOptionsFound: false,
        minLength: 3,
        templates: {
          inputValue: inputValueTemplate,
          suggestion: suggestionTemplate
        },
        tAssistiveHint: () => autocompleteField.dataset.assistiveHint,
        source: debounce(async (query, populateResults) => {
          // display autocomplete suggestions
          const res = await fetchSource(query, SEARCH_URL).catch(displayError)
          const results = res.features
          populateResults(results)
        }, 300),
        onConfirm: (val) => {
          if (val) {
            targetField.value = val.properties.citycode
          }
        }
      })

      const defaultValue = autocompleteField.dataset.defaultValue
      if (exists(defaultValue)) {
        document.querySelector('#city_autocomplete').value = defaultValue
      }
    }
  }

  // Récupération des résultats ----------------------------------------------------

  async function fetchSource (query, url) {
    query = query.trim().toLowerCase().replace(/[^a-zA-Z0-9 -]/, "").replace(/\s/g, "-");
    const res = await fetch(`${url}${encodeURIComponent(query)}`)
    if (res.ok) {
      const data = await res.json()
      return data
    } else {
      return Promise.reject(res);
    }
  }

  // Traitement des résultats --------------------------------------------

  function suggestionTemplate (result) {
    if (!result) return
    const properties = result.properties
    return result && `<span></span><strong> ${properties.city} </strong> - ${properties.postcode}</p>`
  }

  function inputValueTemplate (result) {
    if (!result) return
    return `${result.properties.city} - ${result.properties.postcode}`
  }

  function displayError (err) {
    console.warn(err);
    alert(`Désolée, un problème a été rencontré, vous pouvez réessayer un peu + tard` );
  }
})()

