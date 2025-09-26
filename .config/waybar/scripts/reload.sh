#!/bin/bash

pkill waybar

waybar &

hyprctl reload

