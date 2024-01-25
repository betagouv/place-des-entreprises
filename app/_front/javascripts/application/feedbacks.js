(function () {
  addEventListener('turbo:load', function() {
    let feedbackLinks = document.getElementsByClassName( 'show-feedbacks-form' )
    for ( let i = 0; i < feedbackLinks.length; i++ ) {
      const feedbackLink = feedbackLinks[i];
      feedbackLink.onclick = function() {
        const feedbackableId = feedbackLink.dataset.feedbackable
        const forms = document.getElementsByClassName("feedback-form-" + feedbackableId)
        for (const form of forms) {
          form.style.display = 'block'
        }
      }
    }
  })
})()
