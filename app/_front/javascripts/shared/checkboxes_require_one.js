(function () {
  addEventListener('turbo:load', setupCheckboxesGroups)
  addEventListener('DOMContentLoaded', setupCheckboxesGroups)

  const checkboxes_attribute = 'data-checkboxes-require-one-with'
  function setupCheckboxesGroups () {
    const groups = document.querySelectorAll(`[${checkboxes_attribute}]:not([${checkboxes_attribute}=""])`)
    for (let i = 0; i < groups.length; ++i) { checkboxesRequireOne(groups[i]) }
  }

  function checkboxesRequireOne (group) {
    group.addEventListener('click', function (event) {
      if (event.target.matches('input[type=checkbox]')) { updateCheckboxesValidity(group) }
    })

    updateCheckboxesValidity(group)
  }

  function updateCheckboxesValidity (group) {
    const at_least_one_checked = !!group.querySelector('input[type=checkbox]:checked')
    const validity = at_least_one_checked ? '' : group.attributes[checkboxes_attribute].value
    const boxes = group.querySelectorAll('input[type=checkbox]')
    for (let i = 0; i < boxes.length; ++i) { boxes[i].setCustomValidity(validity) }
  }
})()
