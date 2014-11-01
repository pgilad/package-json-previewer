'use strict'
path = require 'path'
gulp = require 'gulp'

# this is an arbitrary object that loads all gulp plugins in package.json.
$ = require('gulp-load-plugins')()
browserify = require 'browserify'
express = require 'express'
source = require 'vinyl-source-stream'
tiny = require 'tiny-lr'
server = tiny()
app = express()

gulp.task 'styles', ->
  gulp.src './src/stylesheets/*.styl'
  .on 'error', handleError
  .pipe $.stylus()
  .pipe gulp.dest 'dist/stylesheets'
  .pipe $.livereload server

handleError = (error) ->
  $.util.log 'Gulp error', error.message
  @emit 'end'

gulp.task 'scripts', ->
  browserify
    entries: ['./src/scripts/main.coffee']
    extensions: ['.coffee', '.js']
  .transform 'coffeeify'
  .bundle().on 'error', handleError
  .pipe source 'app.js'
  .pipe $.streamify $.uglify()
  .pipe gulp.dest './dist/scripts'
  .pipe $.livereload server

gulp.task 'images', ->
  gulp.src './src/images/*'
  .pipe gulp.dest './dist/images'

gulp.task 'templates', ->
  gulp.src 'src/*.jade'
  .on 'error', handleError
  .pipe $.jade pretty: true
  .pipe gulp.dest './dist'
  .pipe $.livereload server

gulp.task 'static-server', ->
  app.use express.static path.resolve './dist'
  app.listen 1337
  $.util.log 'Listening on port: 1337'

gulp.task 'watch', ->
  server.listen 35729, (err) ->
    if err then return $.util.log err
    gulp.watch 'src/stylesheets/*.styl', ['styles']
    gulp.watch 'src/scripts/*.coffee', ['scripts']
    gulp.watch 'src/*.jade', ['templates']

# Default Task
gulp.task 'default', [
  'scripts'
  'styles'
  'templates'
  'images'
  'static-server'
  'watch'
]
