# Flag options and usage functions
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
LONG=$(echo $ZIP_RESPONSE | jq '.results[0].longitude')

# Truncates lat and lang to first two decimal places
TRIMMED_LAT=$(echo $LAT | bc -l | xargs printf "%.2f" )
TRIMMED_LONG=$(echo $LONG | bc -l | xargs printf "%.2f" )

# Calls NWS API to gain point data and url for location
WEATHER_RESPONSE=$(curl -s --location --request GET https://api.weather.gov/points/${TRIMMED_LAT},${TRIMMED_LONG})
FORECAST_DRILL_URL=$(echo $WEATHER_RESPONSE | jq '.properties.forecast')
CITY=$(echo $WEATHER_RESPONSE | jq '.properties.relativeLocation.properties.city')
STATE=$(echo $WEATHER_RESPONSE | jq '.properties.relativeLocation.properties.state')

# Makes second call to NWS API to get temp data for location
FORECAST_RESPONSE=$(curl -s --location --request GET $(echo $FORECAST_DRILL_URL | sed -e 's/^"//' -e 's/"$//')) # sed after pipe removes quotes for echo formatting to curl

HIGH_TEMP=$(echo $FORECAST_RESPONSE | jq '.properties.periods[0].temperature')
LOW_TEMP=$(echo $FORECAST_RESPONSE | jq '.properties.periods[1].temperature')

# Print out
echo $ZIPCODE

nq_CITY=$(echo $CITY | sed -e 's/^"//' -e 's/"$//')
nq_STATE=$(echo $STATE | sed -e 's/^"//' -e 's/"$//')


echo $HIGH_TEMP 
echo $LOW_TEMP

# FLASHING_YELLOW='\033[5;33m'
FLASHING_YELLOW='\033[5;43m'
BOLD_BLUE='\033[1;35m'
ITALICIZED='\033[3m'
ENDCOLOR='\033[0m'

echo "             🌎 
            "
echo "   In ${FLASHING_YELLOW} ${nq_CITY}, ${nq_STATE} ${ENDCOLOR} today "
echo "☀️    The ${ITALICIZED}high${ENDCOLOR} temperature will be ${BOLD_BLUE}${HIGH_TEMP}°F${ENDCOLOR}.🌡️"
echo "🌙   The ${ITALICIZED}low${ENDCOLOR} will be ${BOLD_BLUE}${LOW_TEMP}°F${ENDCOLOR}.🌡️"
