(function () {
  addEventListener('turbo:load', function() {
    let subjectCells = document.querySelectorAll('tr.subjects th')
    if (subjectCells.length != 0) {
      const themeRowHeight = document.querySelector('tr').offsetHeight
      const subjectRowHeight = document.querySelector('tr.subjects').offsetHeight
      let countCells = document.querySelectorAll('tr.users-count th')

      for (let cell of subjectCells) {
        cell.style.top = `${themeRowHeight}px`
      }

      for (let cell of countCells) {
        cell.style.top = `${subjectRowHeight+themeRowHeight}px`
      }
    }
  })
})()
