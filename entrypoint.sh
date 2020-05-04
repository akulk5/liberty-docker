#!/bin/sh
set -e
git clone $GIT_SOURCE_REPO
cd /my-first-liberty-blog/studio
sanity init -y --create-project $PROJECT --dataset $DATASET --output-path ../temp
cd /my-first-liberty-blog
sed -i -e 's/"PROJECT_ID"/'$(jq .api.projectId temp/sanity.json)'/g' studio/sanity.json
sed -i -e 's/"DATASET_ID"/'$(jq .api.dataset temp/sanity.json)'/g' studio/sanity.json
sed -i -e 's/"PROJECT_NAME"/'$(jq .project.name temp/sanity.json)'/g' studio/sanity.json
sed -i -e 's/"PROJECT_ID"/'$(jq .api.projectId temp/sanity.json)'/g' web/.env.production
sed -i -e 's/"DATASET_ID"/'$(jq .api.dataset temp/sanity.json)'/g' web/.env.production
curl -X POST -H "Authorization: Bearer $SANITY_AUTH_TOKEN"  -H "Content-Type: application/json" -d '{"origin":"https://*.netlify.app","allowCredentials":true}' https://$(jq -r .api.projectId temp/sanity.json).api.sanity.io/v1/cors
rm -r temp
git init
git add *
git remote set-url origin $GIT_TARGET_REPO
git commit -m "Initial Commit"
git push -u origin master
cd /my-first-liberty-blog/studio
sanity dataset import production.tar.gz $DATASET
echo "Sanity Project Provision Completed!!"