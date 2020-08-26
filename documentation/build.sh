#!/usr/bin/env bash
SITE_DIR='crax_docs'
HOST=$(cat ../.creds | grep HOST | cut -d "=" -f2)
USER=$(cat ../.creds | grep USER | cut -d "=" -f2)
DIR=$(cat ../.creds | grep DIR | cut -d "=" -f2)
rm -rf ${SITE_DIR}
TEMPLATES=$(ls ../${SITE_DIR}/templates)
rm -rf ../${SITE_DIR}/_images
rm -rf ../${SITE_DIR}/_static

function cleanSite() {
    for t in ${TEMPLATES}
    do
        if [[ $t == *"home.html"* ]] || [[ $t == *"base.html"* ]] || [[ $t == *"404.html"* ]] || [[ $t == *"500.html"* ]]
            then
                echo "Skipping $t"
            else
                rm ../${SITE_DIR}/templates/"$t"
        fi
    done
}

cleanSite

sphinx-build -b html . ${SITE_DIR}

cp -r ${SITE_DIR}/_images ../${SITE_DIR}/
cp -r ${SITE_DIR}/_static ../${SITE_DIR}/

find ${SITE_DIR} -name '*.html' | xargs -I %% cp %% ../${SITE_DIR}/templates/$(cut %% -d '/' -f2)
find ${SITE_DIR}/_sources -name '*.rst.txt' | xargs -I %% cp %% ../${SITE_DIR}/templates/$(cut %% -d '/' -f2)
cp ${SITE_DIR}/'searchindex.js' ../${SITE_DIR}/_static/'searchindex.js'
perl -pi -e 's/searchindex.js/_static\/searchindex.js/' ../${SITE_DIR}/templates/search.html
find ../${SITE_DIR} -name "__pycache__" | xargs rm -rf
scp -r ../${SITE_DIR} ${USER}@${HOST}:${DIR}

cleanSite