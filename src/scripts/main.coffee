normalize = require "normalize-package-data"
domready = require "domready"
debounce = require "lodash.debounce"
clone = require "lodash.clone"
fixture = require "../fixtures/_package.json"

prettyJSON = (json) -> JSON.stringify json, null, 2

domready ->
  elmInput = document.querySelector "textarea.input"
  elmOutput = document.querySelector "textarea.output"
  btnLoadSample = document.querySelector "button.load-sample"
  btnClearInput = document.querySelector "button.clear-input"

  onClearInput = -> elmInput.value = elmOutput.value = ""

  onInputChange = debounce (e) ->
    return onClearInput() unless e.target.value.trim()
    try
      data = JSON.parse e.target.value
      normalize data
    catch err
      return elmOutput.value = "Error parsing or normalizing #{err}"
    elmOutput.value = prettyJSON data
  , 100

  onLoadSample = ->
    # get a clone of fixture as to not to mutate it
    data = clone fixture
    normalize data
    elmInput.value = prettyJSON fixture
    elmOutput.value = prettyJSON data

  btnLoadSample.onclick = onLoadSample
  btnClearInput.onclick = onClearInput
  elmInput.oninput = onInputChange
