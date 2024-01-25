(function () {
  // Make external links work properly when the site is inside an iframe.
  // This adds target="_parent" to all <a> whose url isn't ours.
  // See also iframe_prefix.rb

  this.onload = function () {
    if (inIframe()) {
      makeExternalLinksOpenInParent()
    }
  }

  function inIframe () {
    try {
      return window.self !== window.top
    } catch (e) {
      return true
    }
  }

  function makeExternalLinksOpenInParent () {
    const links = document.getElementsByTagName('a')
    for (let i = 0; i < links.length; ++i) {
      targetParentIfExternal(links[i])
    }
  }

  function targetParentIfExternal (link) {
    if (link.host !== window.location.host) {
      // Note: TODO: this is partially broken.
      // We only change the target if the link host is different from the iframe host;
      // However, sometimes we need to open in the parent even when opening a link to the iframe host.
      // Typically, this would be a PDE iframe with a footer that links to some about pages on PDE.
      // Currently, this link would not be changed.
      // This could probably fixed by checking if the link path begins with the iframe prefix (/e/),
      // however this means that the iframe prefix needs to be configured both in routes.rb and here.
      link.target = '_parent'
    }
  }
})()
