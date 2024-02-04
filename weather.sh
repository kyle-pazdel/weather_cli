ZIP_CODE=92264
ZIP_RESPONSE=$(curl -s --location --request GET https://geocoding-api.open-meteo.com/v1/search?name=$ZIP_CODE&count=1&language=en&format=json)
LAT=$(echo $ZIP_RESPONSE | jq '.results[0].latitude')
LONG=$(echo $ZIP_RESPONSE | jq '.results[0].longitude')





echo $ZIP_CODE
echo $LAT 
echo $LONG