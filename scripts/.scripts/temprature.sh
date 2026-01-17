#!/usr/bin/env bash

# CPU temperature (sensors)
CPU_TEMP=$(awk '{print int($1/1000)}' /sys/class/hwmon/hwmon2/temp1_input)

# GPU temperature
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)

# echo "<span color='#7CFC98'></span>${CPU_TEMP}°C"
#
# # Second line → tooltip
# echo -e "CPU: ${CPU_TEMP}°C\nGPU: ${GPU_TEMP}°C"
echo "{\"text\":\"${CPU_TEMP}\", \"tooltip\":\"CPU: ${CPU_TEMP}°C\\nGPU: ${GPU_TEMP}°C\"}"
