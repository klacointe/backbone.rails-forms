module.exports = (grunt)->

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha'
  grunt.loadNpmTasks 'grunt-bower-task'

  grunt.initConfig
    coffeelint:
      app:
        files:
          src: ['Gruntfile.coffee', 'src/js/*/**.coffee', 'test/**/*.coffee']
        options:
          max_line_length:
            level: 'warn'
          no_backticks:
            level: 'warn'
    jshint:
      manifest: ['*.json']
    coffee:
      assets:
        options:
          join: true
        files:
          'dist/js/backbone.rails-forms.js': [
            'src/js/namespace.coffee',
            'src/js/csrf_token.coffee',
            'src/js/ajax_form.coffee',
            'src/js/backbone_form.coffee'
          ]
      test:
        expand: true
        flatten: true
        cwd: 'test/src/'
        src: ['**/*.coffee']
        dest: 'test/dist/js'
        ext: '.js'
    mocha:
      options:
        run: true
      test:
        src: ['test/**/*.html']
    watch:
      files: ['src/**/*.coffee', 'test/**/*.coffee']
      tasks: ['coffeelint', 'coffee', 'mocha']
    bower:
      install:
        targetDir: 'bower_components'
        copy: no

  grunt.registerTask 'default', ['bower', 'jshint', 'coffeelint', 'coffee', 'mocha']
