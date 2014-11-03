normalize = require 'normalize-package-data'
domready = require 'domready'
debounce = require 'lodash.debounce'
clone = require 'lodash.clone'
fixture = require '../fixtures/_package.json'
ace = require 'brace'
require 'brace/mode/json'
require 'brace/theme/monokai'
INPUT_DEBOUNCE_TIME = 100

prettyJSON = (json) -> JSON.stringify json, null, 2

initAce = (elm) ->
  editor = ace.edit elm
  editor.getSession().setMode 'ace/mode/json'
  editor.setTheme 'ace/theme/monokai'
  editor

# similiar to jquery document.ready
domready ->
  btnLoadSample = document.querySelector 'button.load-sample'
  btnClearInput = document.querySelector 'button.clear-input'

  inputEditor = initAce 'input-editor'
  outputEditor = initAce 'output-editor'
  outputEditor.getSession().setUseWorker false

  onInputClear = ->
    inputEditor.setValue ''
    outputEditor.setValue ''

  onInputChange = debounce () ->
    value = inputEditor.getValue().trim()
    return unless value
    try
      data = JSON.parse value
      # this replaces the data passed in
      normalize data
    catch err
      return outputEditor.setValue "Error parsing or normalizing #{err}"
    outputEditor.setValue prettyJSON data
  INPUT_DEBOUNCE_TIME

  onLoadSample = ->
    # get a clone of fixture as to not to mutate it
    inputEditor.setValue prettyJSON clone fixture

  # set event handlers
  btnLoadSample.onclick = onLoadSample
  btnClearInput.onclick = onInputClear
  inputEditor.on 'change', onInputChange
