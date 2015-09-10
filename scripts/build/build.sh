#!/bin/bash
#
# Copyright (c) 2013 Thomas Szteliga <ts@websafe.pl>, <https://websafe.pl>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#
SCRIPT_DIR=$(dirname ${0});
PROJECT_DIR=${SCRIPT_DIR}/../..

#
set -e;

#
source ${SCRIPT_DIR}/$(basename ${0} .sh).conf;

#
SOURCEREPO=https://github.com/blueimp/jQuery-File-Upload.git
SOURCEBRANCH=master
NAMESPACE=${NAMESPACE:-Websafe\\Blueimp};
CLASSNAME=${CLASSNAME:-JqueryFileUploadHandler};
CLASSFILE=${CLASSFILE:-JqueryFileUploadHandler.php};

#
make_distclean() {
    rm -rf ./build;
    rm -rf ./vendor;
}

#
make_clean() {
    make_distclean;
    rm -rf ./library;
    rm -rf ./autoload_classmap.php;
}

#
make_dirs() {
    mkdir -p ./build/source-repo;
    mkdir -p ./vendor/bin;
}

#
cd ${PROJECT_DIR};

#
LASTSOURCECOMMIT=$(git ls-remote ${SOURCEREPO} ${SOURCEBRANCH} master | head -n1 | cut -f1)

#
if [ "${LASTSOURCECOMMIT}" = "$(cat ${SCRIPT_DIR}/COMMIT)" ];
then
    echo "No changes detected";
    exit 0;
else
    #
    make_clean;
    make_dirs;
    #
    curl -sS https://getcomposer.org/installer \
	| php -- --install-dir=vendor/bin/
    # Updating composer dev dependencies
    COMPOSER_PROCESS_TIMEOUT=6000 ./vendor/bin/composer.phar update
    #
    git clone -b ${SOURCEBRANCH} ${SOURCEREPO} ./build/source-repo;
    # Detecting verion of new class.
    NEWLIBVERSION=$(
	grep -m1 -oE \
	    "[0-9]\.[0-9]{1,}\.[0-9]{1,}" \
	    ./build/source-repo/package.json;
    );
    # Copying original class to build dir
    cp -v \
	./build/source-repo/server/php/UploadHandler.php \
	./build/${CLASSFILE};
    # Adding namespace and renaming class, prefixing stdClass with \
    cat ./build/${CLASSFILE} \
	| sed \
	    -e "s/class UploadHandler/namespace ${NAMESPACE};\n\nclass ${CLASSNAME}/g" \
	    > ./build/${CLASSFILE}.tmp;
    # Fixing formatting
    if ./vendor/bin/php-cs-fixer \
	--verbose fix ./build/${CLASSFILE}.tmp \
	--level=psr2;
    then
	echo "Fixing done, but no changes made?";
    else
	echo "Fixing done and changes made.";
    fi
    # Renaming tmp to .php
    mv -v \
	./build/${CLASSFILE}.tmp \
	./build/${CLASSFILE};
    # Creating dir for lib
    if [ ! -d ./library/Websafe/Blueimp ];
    then
	mkdir -p ./library/Websafe/Blueimp;
    fi
    # Copying lib to final dest.
    cp -v ./build/${CLASSFILE} ./library/Websafe/Blueimp/;
    #
    md5sum \
	library/Websafe/Blueimp/JqueryFileUploadHandler.php \
	> ${SCRIPT_DIR}/CHECKSUM.md5;
    #
    #
    # Generate classmap
    ./vendor/bin/zf.php classmap generate ./library ./autoload_classmap.php
    #
    #make_distclean;
    # Storing current commit and version in this repo
    echo ${LASTSOURCECOMMIT} > ${SCRIPT_DIR}/COMMIT
    echo ${NEWLIBVERSION} > ${SCRIPT_DIR}/VERSION
    # Adding files to repo (not really needed anymore)
    git add \
	scripts/build/CHECKSUM.md5 \
	scripts/build/COMMIT \
	scripts/build/VERSION \
	scripts/build/build.conf \
	scripts/build/build.sh \
	.gitignore \
	LICENSE.txt \
	README.md \
	autoload_classmap.php \
	composer.json \
	library
    # Commiting changes to local repo
    echo "CHECKSUM"
    if git commit ${SCRIPT_DIR}/CHECKSUM.md5 -m "Current library version is ${NEWLIBVERSION}.";
    then
	echo "Changed.";
    fi
    echo "COMMIT"
    if git commit ${SCRIPT_DIR}/COMMIT -m "Current relase is based on commit #${LASTSOURCECOMMIT}.";
    then
	echo "Changed.";
    fi
    echo "VERSION"
    if git commit ${SCRIPT_DIR}/VERSION -m "Current library version is ${NEWLIBVERSION}.";
    then
	echo "Changed.";
    fi
    echo "LIB"
    if git commit ./library/Websafe/Blueimp/${CLASSFILE} -m "Updated class with #${LASTSOURCECOMMIT}.";
    then
	echo "Changed."
    fi
    echo "-a"
    if git commit -a -m "Updated with commit #${LASTSOURCECOMMIT}";
    then
	echo "Changed."
    fi
    #
    echo "PUSHING to GitHub..."
    git push -u origin develop
fi
#
#make_distclean
