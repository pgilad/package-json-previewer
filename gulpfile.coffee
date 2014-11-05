'use strict'
path = require 'path'
gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
mergeStream = require 'merge-stream'
$ = require('gulp-load-plugins')()

APP_PORT = 1337

handleError = (error) ->
  $.util.log 'Gulp error', error.message
  @emit 'end'

gulp.task 'styles', ->
  stylus = gulp.src './src/stylesheets/*.styl'
    .pipe $.stylus().on 'error', handleError
  external = gulp.src './node_modules/bootswatch/flatly/bootstrap.min.css'
  mergeStream external, stylus
  .pipe $.concat 'style.css'
  .pipe $.autoprefixer 'last 2 versions'
  .pipe $.minifyCss()
  .pipe $.uncss({
    html: ['./dist/index.html', './dist/404.html']
  })
  .pipe gulp.dest 'dist/stylesheets'

gulp.task 'scripts', ->
  browserify
    entries: ['./src/scripts/main.coffee']
    extensions: ['.coffee', '.js']
  .transform 'coffeeify'
  .bundle().on 'error', handleError
  .pipe source 'app.js'
  .pipe $.streamify $.uglify()
  .pipe gulp.dest './dist/scripts'

gulp.task 'copy', ->
  gulp.src './src/*.xml'
  .pipe gulp.dest './dist'

gulp.task 'images', ->
  gulp.src './src/images/*'
  .pipe gulp.dest './dist/images'

gulp.task 'templates', ->
  gulp.src 'src/*.jade'
  .pipe $.jade pretty: true
  .on 'error', handleError
  .pipe gulp.dest './dist'

# Connect
gulp.task 'connect', ->
  $.connect.server
    root: 'dist'
    port: APP_PORT
    livereload: true

gulp.task 'watch', ['connect'], ->
  gulp.watch 'src/**/*', read:false, (event) ->
    ext = path.extname event.path
    taskname = null
    reloadasset = null
    switch ext
      when '.jade'
        taskname = 'templates'
        reloadasset = 'dist/**/*.html'
      when '.sass'
        taskname = 'styles'
        reloadasset = 'dist/**/*.css'
      when '.coffee', '.js'
        taskname = 'scripts'
        reloadasset = 'dist/**/*.js'
      else
        taskname = 'images'
        reloadasset = "dist/**/*#{path.basename event.path}"
    gulp.task 'reload', [taskname], ->
      gulp.src reloadasset
        .pipe $.connect.reload()
    gulp.start 'reload'

gulp.task 'build', [
  'scripts'
  'styles'
  'templates'
  'images'
  'copy'
]

gulp.task 'default', [
  'build'
  'watch'
]
