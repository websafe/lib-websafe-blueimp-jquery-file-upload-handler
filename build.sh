#!/bin/bash
#
SCRIPT_DIR=$(dirname ${0});

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
    rm -rf ./build
    rm -rf ./vendor
}

#
make_clean() {
    make_distclean;
    rm -rf ./library
}

#
make_dirs() {
    mkdir ./build
    mkdir ./build/source-repo
    mkdir ./build/dest-repo
}

#
cd ${SCRIPT_DIR};

#
LASTSOURCECOMMIT=$(git ls-remote ${SOURCEREPO} ${SOURCEBRANCH} master | head -n1 | cut -f1)

#
composer update

#
if [ "${LASTSOURCECOMMIT}" = "$(cat ./COMMIT)" ];
then
    echo "No changes detected";
    exit 0;
else
    #
    make_clean;
    make_dirs;
    # Updating composer dev dependencies
    composer update
    #
    git clone ${SOURCEREPO} ./build/source-repo;
    # Detecting verion of new class.
    NEWLIBVERSION=$(
	grep -m1 -oE \
	    "[0-9]\.[0-9]{1,}\.[0-9]{1,}" \
	    ./build/source-repo/server/php/UploadHandler.php;
    );
    # Copying original class to build dir
    cp -v \
	./build/source-repo/server/php/UploadHandler.php \
	./build/${CLASSFILE};
    # Adding namespace and renaming class
    cat ./build/${CLASSFILE} \
	| sed \
	    -e "s/class UploadHandler/namespace ${NAMESPACE};\n\nclass ${CLASSNAME}/g" \
	    > ./build/${CLASSFILE}.tmp;
    # Fix formatting
    if ./vendor/bin/php-cs-fixer \
	--verbose fix ./build/${CLASSFILE}.tmp \
	--level=all;
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
    # Storing current commit and version in this repo
    echo ${LASTSOURCECOMMIT} > ./COMMIT
    echo ${NEWLIBVERSION} > ./VERSION
    # Adding files to repo (not really needed anymore)
    git add \
	.gitignore \
	COMMIT \
	LICENSE.txt \
	README.md \
	VERSION \
	build.conf \
	build.sh \
	composer.json \
	library
    # Commiting changes to local repo
    git commit ./COMMIT -m "Current relase is based on commit #${LASTSOURCECOMMIT}.";
    git commit ./VERSION -m "Current library version is ${NEWLIBVERSION}.";
    git commit ./library/Websafe/Blueimp/${CLASSFILE} -m "Updated class with #${LASTSOURCECOMMIT}.";
    git commit -a -m "Updated with commit #${LASTSOURCECOMMIT}";
    git push -u origin master
fi
#
make_distclean
