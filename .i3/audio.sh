set -e
set -u

function get_index() {

    declare -a my_array
    my_array=($2)
    value=$1

    for i in ${!my_array[@]}; do
       if [[ "${my_array[$i]}" = "${value}" ]]; then
           echo "${i}";
       fi
    done
}

# get card list
# declare -A CARDS
CARDS=( $(pactl list sinks short | awk '{print $1}') )
num_cards=$(( ${#CARDS[@]} -1)) # for using with index

# dump "${CARDS[*]}"

# get last active sink (application which use the sound card)
LAST_SINK_LINE=$(pactl list sink-inputs short | tail -n1)

# output example
# 329 1   16  protocol-native.c   float32le 2ch 44100Hz
# 1st - 329 in this case is the sink stream
# 2nd - 1   is the sound card
# 3rd - 16  is the application
# we basically like to move the application output to a new card.
 
if [[ -z ${LAST_SINK_LINE} ]];
then
    notify-send 'Error' 'was not able to get last sink line'
else
    last_sink_app_index=$( echo "${LAST_SINK_LINE}" | awk '{print $3}' )
    last_sink_card=$(      echo "${LAST_SINK_LINE}" | awk '{print $2}' )
    last_sink_out_index=$( echo "${LAST_SINK_LINE}" | awk '{print $1}' )
fi


if [[ ! -z ${last_sink_card} ]];
then

    current_card_index=$(get_index "${last_sink_card}" "${CARDS[*]}")
    if [[ ${current_card_index} == ${num_cards} ]]; then
        switch_to_card_index=0
    else
        switch_to_card_index=$((current_card_index+1))
    fi

    pactl move-sink-input "${last_sink_out_index}" ${CARDS[${switch_to_card_index}]}

fi
