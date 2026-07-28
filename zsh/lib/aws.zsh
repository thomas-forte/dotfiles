#!/bin/zsh

# List AWS config profile names (includes "default").
_aws_select_profiles() {
  if command -v aws > /dev/null 2>&1; then
    aws configure list-profiles 2>/dev/null
    return $?
  fi

  local line
  [[ -r ~/.aws/config ]] || return 1
  while IFS= read -r line; do
    if [[ "$line" == '[default]' ]]; then
      print -r -- default
    elif [[ "$line" =~ '^\[profile (.+)\]$' ]]; then
      print -r -- "$match[1]"
    fi
  done < ~/.aws/config
}

aws_select() {
  case "$1" in
    -h|--help)
      echo "usage: aws_select [profile | -u|--unset]"
      echo "  (no args)  interactive profile picker"
      echo "  <profile>  set AWS_PROFILE directly"
      echo "  -u         unset AWS_PROFILE"
      return 0
      ;;
    -u|--unset)
      unset AWS_PROFILE
      echo "AWS_PROFILE unset"
      return 0
      ;;
  esac

  if (( $# )); then
    export AWS_PROFILE="$1"
    echo "AWS_PROFILE=$AWS_PROFILE"
    return 0
  fi

  local -a profiles choices
  profiles=("${(@f)$(_aws_select_profiles)}")
  if (( $#profiles == 0 )); then
    echo "no profiles found in ~/.aws/config"
    return 1
  fi

  choices=("${profiles[@]}" unset)
  echo "Choose profile${AWS_PROFILE:+ (current: $AWS_PROFILE)}:" >&2
  local idx
  idx="$(_picker -1 "${choices[@]}")" || return 1
  [[ -n "$idx" ]] || return 0

  local opt="${choices[idx]}"
  if [[ "$opt" == unset ]]; then
    unset AWS_PROFILE
    echo "AWS_PROFILE unset"
  else
    export AWS_PROFILE="$opt"
    echo "AWS_PROFILE=$AWS_PROFILE"
  fi
}
