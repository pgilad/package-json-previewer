path = require 'path'
gulp = require 'gulp'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
mergeStream = require 'merge-stream'
buffer = require 'vinyl-buffer'
$ = require('gulp-load-plugins')()
bundleMap = './dist/scripts/app.js.map'

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
  .pipe $.minifyCss
    processImport: false
  .pipe $.uncss({
    html: ['./dist/index.html', './dist/404.html']
  })
  .pipe gulp.dest 'dist/stylesheets'

gulp.task 'scripts', ->
  browserify
    entries: ['./src/scripts/main.coffee']
    extensions: ['.coffee', '.js']
    debug: true
  .transform 'coffeeify'
  .bundle().on 'error', handleError
  .pipe source 'app.js'
  .pipe buffer()
  .pipe $.sourcemaps.init loadMaps: true
  .pipe $.uglify()
  .pipe $.sourcemaps.write './'
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

gulp.task 'watch', ['connect'], ->
  gulp.watch 'src/**/*', read:false, (event) ->
    ext = path.extname event.path
    taskname = null
    reloadasset = null
    switch ext
      when '.jade'
        taskname = 'templates'
        reloadasset = 'dist/**/*.html'
      when '.styl', '.css'
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

gulp.task 'gh-pages', ['build'], ->
  gulp.src './dist/**/*'
  .pipe $.ghPages
    push: true

# Connect
gulp.task 'connect', ->
  $.connect.server
    root: 'dist'
    port: APP_PORT
    livereload: true

gulp.task 'default', [
  'build'
  'watch'
]

gulp.task 'build', [
  'scripts'
  'styles'
  'templates'
  'images'
  'copy'
]

gulp.task 'deploy', [
  'build',
  'gh-pages'
]
