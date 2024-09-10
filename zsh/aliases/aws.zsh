#!/bin/zsh

aws_select() {
    local PS3='Choose your profile: '
    local profiles=($(cat ~/.aws/config | perl -n -e'/\[profile ([A-z]+)]/ && print "$1 "') "(u)nset" "(q)uit")

    local length=${#profiles[@]}
    select opt in "${profiles[@]}"
    do
        if [[ $REPLY == $length ]]
        then
            break
        elif [[ $REPLY == "q" ]]
        then
            break
        elif [[ $REPLY == ($length - 1) ]]
        then
            unset AWS_PROFILE
            break
        elif [[ $REPLY == "u" ]]
        then
            unset AWS_PROFILE
            break
        elif [[ $REPLY -lt 1 ]]
        then
            echo "Invalid option."
        elif [[ $REPLY -gt $length ]]
        then
            echo "Invalid option."
        else
            echo "$opt set as AWS_PROFILE"
            export AWS_PROFILE=$opt
            break
        fi
    done
}