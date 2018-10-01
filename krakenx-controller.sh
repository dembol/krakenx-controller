#!/bin/bash

function read_current_cpu_temperature() {
    #echo `sensors | grep temp1 | sed 1d | awk '{print $2}' | cut -c 2-3`
    echo `sensors | grep Tdie | awk '{print $2}' | cut -c 2-3`
}

function read_current_liquid_temperature() {
    var=$(colctl -s | grep liquid | cut -d' ' -f2)
    echo ${var%.*}
}

function get_best_fan_speed() {
    current_cpu_temp=$(read_current_cpu_temperature)
    current_liqiod_temp=$(read_current_liquid_temperature)
    
    if (( ${current_cpu_temp} >= 75 )); then
	fan_speed=100
    elif (( ${current_cpu_temp} >= 70 )); then
	fan_speed=100
    elif (( ${current_cpu_temp} >= 65 )); then
	fan_speed=100
    elif (( ${current_cpu_temp} >= 60 )); then
	fan_speed=100
    elif (( (${current_cpu_temp} >= 55) || (${current_liquid_temp} >= 40))); then
	fan_speed=100
    elif (( (${current_cpu_temp} >= 55) || (${current_liquid_temp} >= 38))); then
	fan_speed=75
    elif (( ${current_cpu_temp} >= 50 )); then
	fan_speed=50
    elif (( (${current_cpu_temp} >= 30) || (${current_liquid_temp} >= 35))); then
	fan_speed=50
    else
	fan_speed=25
    fi
    
    echo $fan_speed
}

function get_best_pump_speed() {
    current_cpu_temp=$(read_current_cpu_temperature)
    current_liquid_temp=$(read_current_liquid_temperature)
    
    if (( ${current_cpu_temp} >= 75 )); then
	pump_speed=100
    elif (( ${current_cpu_temp} >= 70 )); then
	pump_speed=100
    elif (( ${current_cpu_temp} >= 60 )); then
	pump_speed=100
    elif (( ${current_cpu_temp} >= 40 )); then
	pump_speed=75
    elif (( (${current_cpu_temp} >= 35) || (${current_liquid_temp} >= 35))); then
	pump_speed=75
    else
	pump_speed=75
    fi
    
    echo $pump_speed
}

function set_fan_and_pump_speed() {
    echo "Setting fan speed to $1 and pump speed to $2"
    colctl -fs $1 -ps $2
    echo
}

die() {
    echo "$@" 1>&2 
    exit 1
}

STEP_DELAY_SECONDS=2

function fan_control {
    FAN_STATUS="on"
    while [ true ];
    do
	current_cpu_temp=$(read_current_cpu_temperature)
	current_liquid_temp=$(read_current_liquid_temperature)
	
	echo "Current CPU temperature $current_cpu_temp"
	echo "Current liquid temperature $current_liquid_temp"
	
	best_fan_speed=$(get_best_fan_speed)
	best_pump_speed=$(get_best_pump_speed)
	
	set_fan_and_pump_speed $best_fan_speed $best_pump_speed

	sleep $STEP_DELAY_SECONDS
    done
}

fan_control

