normalize = require 'normalize-package-data'
domready = require 'domready'
debounce = require 'lodash.debounce'
fixture = require '../../package.json'

outputConverted = (data, elm) ->
  elm.value = JSON.stringify(data, null, 2)

domready ->
  elmInput = document.querySelector 'textarea.input'
  elmOutput = document.querySelector('textarea.output')

  onInputChange = debounce (e) ->
    value = e.target.value
    value = JSON.stringify fixture

    try
      data = JSON.parse value
      normalize data
    catch error
      return console.warn error

    outputConverted data, elmOutput
  , 200

  elmInput.oninput = onInputChange
