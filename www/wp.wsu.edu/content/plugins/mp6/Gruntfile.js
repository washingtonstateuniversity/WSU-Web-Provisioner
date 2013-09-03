module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    meta: {
      path: 'components/color-schemes/schemes'
    },

    sass: {
      admin: {
        options: {
          style: 'compact',
          lineNumbers: false
        },
        files : {
          'components/color-schemes/picker/style.css' : 'components/color-schemes/picker/style.scss',
        }
      },
      colors: {
      	options: {
      	  style: 'compact',
      	  lineNumbers: false
      	},
        files : {
          '<%= meta.path %>/blue/colors.css' : '<%= meta.path %>/blue/colors.scss',
          '<%= meta.path %>/malibu-dreamhouse/colors.css' : '<%= meta.path %>/malibu-dreamhouse/colors.scss',
          '<%= meta.path %>/seaweed/colors.css' : '<%= meta.path %>/seaweed/colors.scss',
          '<%= meta.path %>/pixel/colors.css' : '<%= meta.path %>/pixel/colors.scss',
          '<%= meta.path %>/ectoplasm/colors.css' : '<%= meta.path %>/ectoplasm/colors.scss',
          '<%= meta.path %>/80s-kid/colors.css' : '<%= meta.path %>/80s-kid/colors.scss',
          '<%= meta.path %>/lioness/colors.css' : '<%= meta.path %>/lioness/colors.scss',
          '<%= meta.path %>/mp6-light/colors.css' : '<%= meta.path %>/mp6-light/colors.scss',
        }
      }
    },

    watch: {
      sass: {
        files: ['<%= meta.path %>/**/*.scss', ],
        tasks: ['sass:colors']
      },
      sass: {
        files: ['components/color-schemes/picker/style.scss', ],
        tasks: ['sass:admin']
      }
    }

  });

  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default task(s).
  grunt.registerTask('default', ['sass']);

};
