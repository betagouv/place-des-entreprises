/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/front and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Compatibilité navigateurs anciens dont IE11
import "core-js/stable";
import "whatwg-fetch";
import "@hotwired/turbo-rails";

require('remixicon/fonts/remixicon.css')
require('@gouvfr/dsfr/dist/dsfr.min.css')
require('@gouvfr/dsfr/dist/utility/icons/icons.main.min.css')
require('@gouvfr/dsfr/dist/utility/colors/colors.min.css')
require('stylesheets/application.sass')

require("jquery");
require("@selectize/selectize");

import "javascripts/shared";
import "javascripts/application";
