#!/usr/bin/env bash

## This function determines which http get tool the system has installed and returns an error if there isnt one
getConfiguredClient()
{
  if  command -v curl &>/dev/null; then
    configuredClient="curl"
  elif command -v wget &>/dev/null; then
    configuredClient="wget"
  elif command -v http &>/dev/null; then
    configuredClient="httpie"
  elif command -v fetch &>/dev/null; then
    configuredClient="fetch"
  else
    echo "Error: This tool requires either curl, wget, httpie or fetch to be installed." >&2
    return 1
  fi
}

## Allows to call the users configured client without if statements everywhere
httpGet()
{
  case "$configuredClient" in
    curl)  curl -A curl -s "$@" ;;
    wget)  wget -qO- "$@" ;;
    httpie) http -b GET "$@" ;;
    fetch) fetch -q "$@" ;;
  esac
}

checkInternet()
{
  httpGet github.com > /dev/null 2>&1 || { echo "Error: no active internet connection" >&2; return 1; } # query github with a get request
}

## Funzione per ottenere informazioni sulla posizione di un IP
getIPLocation() {
  local ip=$1
  if ! [ -x "$(command -v jq)" ]; then
    echo 'Error: jq is not installed. Install via https://stedolan.github.io/jq/download/'
    return 1
  fi

  if [[ -z "$ip" ]]; then
    echo 'Provide an IP as a parameter. Usage: getIPLocation 15.45.0.1'
    return 1
  fi

  local link="http://ip-api.com/json/$ip"
  local data=$(curl $link -s) # -s for silent output

  local status=$(echo $data | jq '.status' -r)

  if [[ $status == "success" ]]; then
    local city=$(echo $data | jq '.city' -r)
    local regionName=$(echo $data | jq '.regionName' -r)
    local country=$(echo $data | jq '.country' -r)
    echo "$city, $regionName in $country."
  else
    echo "Failed to retrieve location for IP: $ip"
    return 1
  fi
}

check_remote_server() {
  #usage: check_remote_server <server> <port>
  local server=$1
  local port=$2
  local timeout=5

  if [ -z "$server" ] || [ -z "$port" ]; then
    return 1
  fi

  if ! command -v nc &> /dev/null; then
    return 2
  fi

  if nc -z -w$timeout $server $port; then
    return 3
  else
    return 4
  fi
}