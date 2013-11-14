jQuery File Upload Handler for PHP
===============================================================================

This project contains the PHP backend for the [jQuery File Upload Plugin]
repackaged as an PSR-0/1/2 compatible library for easier automated installation
using [Composer]. This package does not contain any of the frontend assets
(js/css/img) - You should install them separately, using [bower] or other
tools.



What happens during the build process?
--------------------------------------

The buildprocess makes a few small changes to the original 
`server/php/UploadHandler.php` and publishes back to GitHub:

 + a namespace is being added (`Websafe\Blueimp`),
 + The class is being renamed (`UploadHandler` => `JqueryFileUploadHandler`),
 + `stdClass` is being prefixed with `\`,
 + the code is being formatted using [php-cs-fixer],
 + an autoload classmap is generated ([autoload_classmap.php]).



TODO
----

 + Update version in composer.json after build
 + Check if newer [jQuery File Upload Plugin] really affects the lib.
 + Unit Testing



Usage
-----

~~~~ php
<?php
//
require 'vendor/autoload.php';
//
use Websafe\Blueimp\JqueryFileUploadHandler;
//
$uh = new JqueryFileUploadHandler();
~~~~
