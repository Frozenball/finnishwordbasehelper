// Include gulp
var gulp = require('gulp'); 

// Include Our Plugins
var sass = require('gulp-sass');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var coffee = require('gulp-coffee');
var gutil = require('gulp-util');
var browserify = require('gulp-browserify');
var connect = require('gulp-connect');
var deploy = require('gulp-gh-pages');
 
 
gulp.task('default', ['webserver']);

// Compile Our Sass
gulp.task('sass', function() {
    return gulp.src('css/*.scss')
        .pipe(sass())
        .pipe(gulp.dest('build/css'));
});

// Compile Our Coffeescript
gulp.task('coffee', function() {
    return gulp.src('js/*.coffee')
        .pipe(
            coffee({bare: true}).on('error', gutil.log)
        )
        .pipe(gulp.dest('js'))
});

gulp.task('deploy', function () {
    return gulp.src([
        'index.html',
        'build',
        'bower_components',
        'words'
    ])
    .pipe(deploy({push: false}));
});

// Concatenate & Minify JS
gulp.task('scripts', ['coffee'], function() {
    return gulp.src('js/app.js')
        .pipe(browserify({
          insertGlobals : true,
          debug: !gulp.env.production
        }))
        //.pipe(uglify())
        .pipe(gulp.dest('build/js'));
});

// Watch Files For Changes
gulp.task('watch', function() {
    gulp.watch('js/*.coffee', ['scripts']);
    gulp.watch('css/*.scss', ['sass']);
});

gulp.task('serve', function() {
  connect.server();
});

// Default Task
gulp.task('default', ['sass', 'scripts', 'watch', 'serve']);