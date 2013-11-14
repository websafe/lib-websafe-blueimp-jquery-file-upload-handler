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
cd ${SCRIPT_DIR};

#
LASTSOURCECOMMIT=$(git ls-remote ${SOURCEREPO} ${SOURCEBRANCH} master | head -n1 | cut -f1)

#
if [ "${LASTSOURCECOMMIT}" = "$(cat ./COMMIT)" ];
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
    ./vendor/bin/composer.phar update
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
    # Adding namespace and renaming class, prefixing stdClass with \
    cat ./build/${CLASSFILE} \
	| sed \
	    -e "s/class UploadHandler/namespace ${NAMESPACE};\n\nclass ${CLASSNAME}/g" \
	    -e 's/stdClass(/\\stdClass\(/g' \
	    > ./build/${CLASSFILE}.tmp;
    # Fixing formatting
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
    #
    md5sum \
	library/Websafe/Blueimp/JqueryFileUploadHandler.php \
	> CHECKSUM.md5;
    #
    #
    # Generate classmap
    ./vendor/bin/zf.php classmap generate ./library ./autoload_classmap.php
    #
    #make_distclean;
    # Storing current commit and version in this repo
    echo ${LASTSOURCECOMMIT} > ./COMMIT
    echo ${NEWLIBVERSION} > ./VERSION
    # Adding files to repo (not really needed anymore)
    git add \
	.gitignore \
	CHECKSUM.md5 \
	COMMIT \
	LICENSE.txt \
	README.md \
	VERSION \
	autoload_classmap.php \
	build.conf \
	build.sh \
	composer.json \
	library
    # Commiting changes to local repo
    echo "COMMIT"
    if git commit ./COMMIT -m "Current relase is based on commit #${LASTSOURCECOMMIT}.";
    then
	echo "Changed.";
    fi
    echo "VERSION"
    if git commit ./VERSION -m "Current library version is ${NEWLIBVERSION}.";
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
    git push -u origin master
fi
#
#make_distclean
