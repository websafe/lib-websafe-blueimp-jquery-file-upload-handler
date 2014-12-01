jQuery File Upload PHP backend / upload handler
===============================================================================

This project contains the PHP backend from the [jQuery File Upload Plugin]
repackaged as an [PSR-0]/[PSR-1]/[PSR-2] compatible library for easier
automated installation using [Composer]. This package does not contain any
of the frontend assets (js/css/img) - You should install them separately,
using [bower] or other tools.



What happens during the build process?
--------------------------------------

The buildprocess makes a few small changes to the original 
`server/php/UploadHandler.php` and publishes back to GitHub:

 + a namespace is being added (`Websafe\Blueimp`),
 + The class is being renamed (`UploadHandler` => `JqueryFileUploadHandler`),
 + the code is being formatted using [php-cs-fixer],
 + an autoload classmap is generated ([autoload_classmap.php]).



TODO
----

 + Update version in `composer.json` after build
 + Check if newer [jQuery File Upload Plugin] really affects the lib.
 + Travis
 + [CodeSniffer]
 + PSR-2 - camel case methods!
 + Unit Testing
 + Count builds?



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


[jQuery File Upload Plugin]: https://github.com/blueimp/jQuery-File-Upload
[Composer]: http://getcomposer.org/
[PSR-0]: https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-0.md
[PSR-1]: https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-1-basic-coding-standard.md
[PSR-2]: https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-2-coding-style-guide.md
[bower]: https://github.com/bower/bower
[autoload_classmap.php]: https://github.com/websafe/lib-websafe-blueimp-jquery-file-upload-handler/blob/master/autoload_classmap.php
[library/Websafe/Blueimp/JqueryFileUploadHandler.php]: https://github.com/websafe/lib-websafe-blueimp-jquery-file-upload-handler/blob/master/library/Websafe/Blueimp/JqueryFileUploadHandler.php
[PHP-CS-Fixer]: https://github.com/fabpot/PHP-CS-Fixer
[CodeSniffer]: https://github.com/squizlabs/PHP_CodeSniffer
