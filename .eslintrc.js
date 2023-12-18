module.exports = {
  env: {
    browser: true,
    es2021: true,
    jquery: true,
  },
  extends: ["eslint:recommended"],
  parser: "@babel/eslint-parser",
  parserOptions: {
    ecmaVersion: 12,
    sourceType: "module",
  },
  ignorePatterns: ["app/front/javascripts/application/controllers/autocomplete_controller.js"],
  rules: {},
  globals: {
    $: true,
    require: true,
    _paq: true,
    Highcharts: true,
    Stimulus: true
  },
  overrides: [
    {
      files: ["config/webpack/**/*.js"],
      env: {
        node: true,
      },
    },
  ],
};
