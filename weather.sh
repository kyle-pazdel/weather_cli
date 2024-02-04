# Geocode From Zip
ZIP_CODE=92264
ZIP_RESPONSE=$(curl -s --location --request GET https://geocoding-api.open-meteo.com/v1/search?name=$ZIP_CODE&count=1&language=en&format=json)
LAT=$(echo $ZIP_RESPONSE | jq '.results[0].latitude')
TRIMMED_LAT=$(echo $LAT | bc -l | xargs printf "%.2f" )
LONG=$(echo $ZIP_RESPONSE | jq '.results[0].longitude')
TRIMMED_LONG=$(echo $LONG | bc -l | xargs printf "%.2f" )

WEATHER_RESPONSE=$(curl --location --request GET https://api.weather.gov/points/${TRIMMED_LAT},${TRIMMED_LONG})
FORECAST_DRILL_URL=$(echo $WEATHER_RESPONSE | jq '.properties.forecast')

# sed after pipe removes quotes for echo formatting to curl
FORECAST_RESPONSE=$(curl --location --request GET $(echo $FORECAST_DRILL_URL | sed -e 's/^"//' -e 's/"$//'))



# Print out
echo $ZIP_CODE

echo $LAT
echo $TRIMMED_LAT
echo $LONG
echo $TRIMMED_LONG

echo $FORECAST_DRILL_URL
echo $FORECAST_RESPONSE | jq '.'