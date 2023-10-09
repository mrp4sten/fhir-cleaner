#!/bin/bash
# author mrp4sten (Mauricio Pasten)

figlet mrp4sten -f .font/banner3-D.flf -c -w 100 | lolcat
cowsay "Hi this is my custom Fhir Resource Cleaner, please enter the follow info needed" | lolcat
gum spin --spinner dot --title "Loading..." -- sleep 4

DATA_STORE_URL=$(gum input --placeholder "Enter your DataStore: ")
BEARER_TOKEN=$(gum input --placeholder "Enter your Bearer Token: ")

DATE_FILTER=""
CORRECT_OPTION=true
FHIR_RESOURCE=""

while $CORRECT_OPTION; do
FHIR_RESOURCE=$(cat option_fhir_resources.txt | gum filter --placeholder "Select a resource to clean:" --limit 1 )
  case $FHIR_RESOURCE in
    "Task")
    DATE_FILTER="authored-on"
    CORRECT_OPTION=false
    ;;
    "CarePlan")
    DATE_FILTER="_lastUpdated"
    CORRECT_OPTION=false
    ;;
    *)
    CORRECT_OPTION=true
    ;;
  esac
done

DATE=$(gum input --placeholder "Enter date of resources: ")

curl --location $DATA_STORE_URL"/$FHIR_RESOURCE/?_count=1000&$DATE_FILTER=$DATE" \
--header "Authorization: Bearer $BEARER_TOKEN" > bundle-resources.json

REMOVE_RESOURCES=0
TOTAL_RESOURCES_TO_REMOVE=$(jq '.total' bundle-resources.json)
gum confirm "$TOTAL_RESOURCES_TO_REMOVE resources going to removed, are you sure?" && REMOVE_RESOURCES=1 || echo "Resources not removed" | lolcat

if [ $REMOVE_RESOURCES -eq 1 ]; then
  RESOURCES_ID=$(jq '[.entry[].resource.id]' bundle-resources.json)
  ARRAY_OF_ID=($(echo "$RESOURCES_ID" | jq -r '.[]'))
  for ID in "${ARRAY_OF_ID[@]}"; do
    curl --location --request DELETE $DATA_STORE_URL/$FHIR_RESOURCE/$ID \
    --header "Authorization: Bearer $BEARER_TOKEN"
  done
  
  gum style \
    --foreground 212 --border-foreground 212 --border double \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    'Resources cleaned successfully!'
fi
