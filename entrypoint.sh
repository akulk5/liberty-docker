#!/bin/sh
set -e
git clone $GIT_SOURCE_REPO
cd /my-first-liberty-blog
projectid=$(curl -X POST -H "Authorization: Bearer $SANITY_AUTH_TOKEN"  -H "Content-Type: application/json" -d '{"displayName": "'$PROJECT'"}' https://api.sanity.io/v1/projects | jq -r '.id')
sed -i -e 's/"PROJECT_ID"/"'$projectid'"/g' studio/sanity.json
sed -i -e 's/DATASET_ID/'$DATASET'/g' studio/sanity.json
sed -i -e 's/PROJECT_NAME/'$PROJECT'/g' studio/sanity.json
sed -i -e 's/"PROJECT_ID"/"'$projectid'"/g' web/.env.production
sed -i -e 's/DATASET_ID/'$DATASET'/g' web/.env.production
curl -X POST -H "Authorization: Bearer $SANITY_AUTH_TOKEN"  -H "Content-Type: application/json" -d '{"origin":"https://*.netlify.app","allowCredentials":true}' https://$projectid.api.sanity.io/v1/cors
git init
git add *
git remote set-url origin $GIT_TARGET_REPO
git commit -m "Initial Commit"
git push -u origin master
cd /my-first-liberty-blog/studio
sanity install
sanity dataset create $DATASET --visibility public
sanity dataset import production.tar.gz $DATASET
cd ../..
rm -r /my-first-liberty-blog
curl -X POST -H "Authorization: Bearer $SANITY_AUTH_TOKEN"  -H "Content-Type: application/json" -d '{"dataset": "'$DATASET'", "name": "content_update", "url": "'$WEBHOOK_ENDPOINT'"}' https://api.sanity.io/v1/hooks/projects/$projectid
echo "Sanity Project Provision Completed!!"
