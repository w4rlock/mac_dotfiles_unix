#!/usr/bin/env bash

local conn_name=${1:?'connection name is required'}
nmcli con up id $conn_name

