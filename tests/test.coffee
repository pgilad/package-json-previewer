# force the test environment to 'test'
process.env.NODE_ENV = 'test'

# get the application server module
express = require 'express'
app = express()
serveStatic = require 'serve-static'
Browser = require 'zombie'
expect = require 'expect.js'
PORT = process.env.PORT or 8002
DIST_DIR = './dist'

describe 'Package.json Previewer', ->
  before (done) ->
    @server = app.use(serveStatic(DIST_DIR)).listen PORT, done

  after (done) ->
    @browser.close()
    @server.close(done)

  it 'should visit the initial page', (done) ->
    @browser = new Browser(site: 'http://localhost:' + PORT)
    @browser.visit '/', done

  it 'should make sure head exists', ->
    expect(@browser.success).to.be.ok()
    expect(@browser.query 'head').to.be.ok()
