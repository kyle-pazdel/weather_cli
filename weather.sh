# Flag options and usage function
function usage() {
    cat <<USAGE

    Usage: $0 [-z --zipcode]

    Options:
        -z, --zipcode:        zipcode for regional temperatures
        --help:               information about options
USAGE
    exit 1
}

# if no arguments are provided, return usage function
if [ $# -eq 0 ]; then
    echo "Option Error: You must provide a zipcode"
    usage
    exit 1
fi

ZIPCODE=

while [ "$1" != "" ]; do
    case $1 in
    -z | --zipcode)
        shift
        ZIPCODE=$1
        ;;
    -h | --help)
        usage
        ;;
    *)  
        echo "Option Error: Unrecognized flag $1"
        usage
        exit 1
        ;;
    esac
    shift
done


# Geocode From Zip
ZIP_RESPONSE=$(curl -s --location --request GET https://geocoding-api.open-meteo.com/v1/search?name=$ZIPCODE&count=1&language=en&format=json)
LAT=$(echo $ZIP_RESPONSE | jq '.results[0].latitude')
TRIMMED_LAT=$(echo $LAT | bc -l | xargs printf "%.2f" )
LONG=$(echo $ZIP_RESPONSE | jq '.results[0].longitude')
TRIMMED_LONG=$(echo $LONG | bc -l | xargs printf "%.2f" )

WEATHER_RESPONSE=$(curl -s --location --request GET https://api.weather.gov/points/${TRIMMED_LAT},${TRIMMED_LONG})
FORECAST_DRILL_URL=$(echo $WEATHER_RESPONSE | jq '.properties.forecast')
CITY=$(echo $WEATHER_RESPONSE | jq '.properties.relativeLocation.properties.city')
STATE=$(echo $WEATHER_RESPONSE | jq '.properties.relativeLocation.properties.state')

# sed after pipe removes quotes for echo formatting to curl
FORECAST_RESPONSE=$(curl -s --location --request GET $(echo $FORECAST_DRILL_URL | sed -e 's/^"//' -e 's/"$//'))

HIGH_TEMP=$(echo $FORECAST_RESPONSE | jq '.properties.periods[0].temperature')
LOW_TEMP=$(echo $FORECAST_RESPONSE | jq '.properties.periods[1].temperature')

# Print out
echo $ZIPCODE
echo $CITY | sed -e 's/^"//' -e 's/"$//'
echo $STATE | sed -e 's/^"//' -e 's/"$//'

echo $LAT
echo $TRIMMED_LAT
echo $LONG
echo $TRIMMED_LONG

echo $HIGH_TEMP 
echo $LOW_TEMP 


