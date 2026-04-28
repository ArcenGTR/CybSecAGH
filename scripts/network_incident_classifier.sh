#!/bin/bash


PORT_AUDIT="./listening_service_audit.sh"
CONN_AUDIT="./established_connection_audit.sh"
CPU_AUDIT="./resource_usage_detector.sh 10 10"    # From Task 3
PROC_AUDIT="./unauthorized_process_audit.sh" # From Task 4
LOG_AUDIT="./log_anomaly_detector.sh 5"
status_port="INACTIVE"
status_conn="INACTIVE"
status_cpu="INACTIVE"
status_log="INACTIVE"
active_count=0

check_status() {
    local script=$1
    local success_msg=$2
    local status_var=$3

    output=$($script)

    if ! echo "$output" | grep -q "$success_msg"; then
        eval "$status_var='ACTIVE'"
        ((active_count++))
    fi
}

check_status "$PORT_AUDIT" "NO UNEXPECTED EXPOSED PORTS" "status_port"
check_status "$CONN_AUDIT" "NO SUSPICIOUS REMOTE CONNECTIONS" "status_conn"
check_status "$CPU_AUDIT" "NO HIGH CPU PROCESSES" "status_cpu"
check_status "$PROC_AUDIT" "NO UNAUTHORIZED PROCESSES" "status_proc"
check_status "$LOG_AUDIT" "NO LOG ANOMALIES" "status_log"

echo "--- SYSTEM INCIDENT SUMMARY ---"
echo "Unexpected Exposed Ports:  $status_port"
echo "Suspicious Remote Conns:   $status_conn"
echo "High CPU Process:          $status_cpu"
echo "Unauthorized Processes:    $status_proc"
echo "Log Anomalies:             $status_log"
echo "-------------------------------"
echo "Total Active Indicators:   $active_count"

if [ $active_count -eq 0 ]; then
    echo "CLASSIFICATION: NORMAL"
elif [ $active_count -eq 1 ]; then
    echo "CLASSIFICATION: WARNING"
else
    echo "CLASSIFICATION: CRITICAL"
fi