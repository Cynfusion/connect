/**
 * Module dependencies
 */

var util = require('util');


/**
 * InvalidTokenError
 */

function InvalidTokenError(description) {
  this.name = 'InvalidTokenError';
  this.error = 'invalid_token';
  this.error_description = description;
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(InvalidTokenError, Error);


/**
 * Exports
 */

module.exports = InvalidTokenError;
