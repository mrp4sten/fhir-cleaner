#!/bin/bash
# author mrp4sten (Mauricio Pasten)

DATA_STORE_URL=$(gum input --placeholder "Enter your DataStore: ")
AUTHORED_ON_FILTER=$(gum input --placeholder "Enter date of authored-on: ")
BEARER_TOKEN=$(gum input --placeholder "Enter your Bearer Token: ")

curl --location $DATA_STORE_URL"/?_count=1000&authored-on=$AUTHORED_ON_FILTER" \
--header "Authorization: Bearer $BEARER_TOKEN" > task-bundle-response.json

TASKS_ID=$(jq '[.entry[].resource.id]' task-bundle-response.json)

ARRAY_TASKS_ID=($(echo "$TASKS_ID" | jq -r '.[]'))

for ID in "${ARRAY_TASKS_ID[@]}"; do
  curl --location --request DELETE $DATA_STORE_URL/$ID \
--header "Authorization: Bearer $BEARER_TOKEN"
done