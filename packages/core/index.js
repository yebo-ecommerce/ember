/* jshint node: true */
'use strict';

module.exports = {
  name: 'yebo-ember-core',
  // isDevelopingAddon: function() {
  //   return true;
  // },
  included: function(app) {
    this._super.included(app);
    app.import('vendor/register-core.js');
  }
};
