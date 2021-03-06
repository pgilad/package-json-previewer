# force the test environment to 'test'
process.env.NODE_ENV = 'test'
PORT = process.env.PORT or 8888
DIST_DIR = './dist'

# get the application server module
express = require 'express'
app = express()
serveStatic = require 'serve-static'
Browser = require 'zombie'
expect = require 'expect.js'
Browser.localhost 'localhost', PORT
browser = Browser.create()
browser.resources.mock '//platform.twitter.com/widgets.js', {
  statusCode: 200
}

describe 'Package.json Previewer', ->
  before (done) ->
    @server = app.use(serveStatic(DIST_DIR)).listen PORT, ->
      console.log "server launched on port #{PORT}"
      done()

  after 'running cleanup', (done) ->
    browser.close()
    @server.close(done)

  it 'should make sure head exists', (done) ->
    @timeout 10000
    browser.visit '/', (error) ->
      expect(browser.success).to.be.ok()
      expect(browser.query 'head').to.be.ok()
      done()

  it 'should make sure textareas are available', ->
    browser.assert.elements '#input-editor'
    browser.assert.elements '#output-editor'

  it 'click on load sample', (done) ->
    @timeout 10000
    browser.assert.elements 'button.load-sample'
    browser.pressButton 'button.load-sample', ->
      done()
