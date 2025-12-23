#!/usr/bin/env bash
# Run each publisher and verify all subscribers received the message

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/test-logs"
PID_FILE="$LOG_DIR/subscribers.pids"
TIMEOUT=10

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results directory
RESULTS_DIR=$(mktemp -d)
trap "rm -rf $RESULTS_DIR" EXIT

echo "========================================="
echo "Cross-Protocol Pub/Sub Test Suite"
echo "========================================="
echo ""

# Check if subscribers are running
if [ ! -f "$PID_FILE" ]; then
    echo -e "${RED}Error: Subscribers not running${NC}"
    echo "Start subscribers first: ./run-all-subscribers.sh"
    exit 1
fi

echo "Found subscriber logs in: $LOG_DIR"
echo "Timeout per test: ${TIMEOUT}s"
echo ""

# Function to run a publisher test
run_publisher_test() {
    local lang="$1"
    local protocol="$2"
    local pub_name="${lang}-${protocol}"

    echo "========================================="
    echo -e "${BLUE}Testing: ${pub_name}${NC}"
    echo "========================================="

    # Generate unique message payload
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local temp=$(awk -v min=68 -v max=75 'BEGIN{srand(); printf "%.4f", min+rand()*(max-min)}')
    local location="test-lab-publisher-${pub_name}"
    local payload="{\"temp\":${temp},\"location\":\"${location}\",\"publisher\":\"${pub_name}\",\"timestamp\":\"${timestamp}\"}"

    echo "Payload: $payload"
    echo ""

    # Determine which publisher to use
    if [ "$lang" = "nodejs" ]; then
        local cmd="node ${PROJECT_ROOT}/client/nodejs/${protocol}-publish.js"
    elif [ "$lang" = "python" ]; then
        local cmd="python3 ${PROJECT_ROOT}/client/python/${protocol}-publish.py"
    elif [ "$lang" = "mqttx" ]; then
        local cmd="${PROJECT_ROOT}/client/mqttx/mqttx-publish.sh"
    fi

    # Publish the message
    echo "Publishing..."
    if ! $cmd "$payload" 2>&1; then
        echo -e "${RED}✗ Publish failed${NC}"
        echo "FAIL|0|7|Publish error" > "$RESULTS_DIR/$pub_name"
        return 1
    fi

    echo ""
    echo "Waiting ${TIMEOUT}s for message propagation..."
    sleep "$TIMEOUT"

    # Check all log files for the message
    echo "Checking subscriber receipts..."
    local received_count=0
    local missing_subs=()
    local sub_results=()

    local subscribers=(
        "nodejs-mqtt"
        "nodejs-ws"
        "nodejs-sse"
        "python-mqtt"
        "python-ws"
        "python-sse"
        "mqttx-mqtt"
    )

    for sub_name in "${subscribers[@]}"; do
        local log_file="$LOG_DIR/${sub_name}.log"

        if [ ! -f "$log_file" ]; then
            missing_subs+=("$sub_name (no log)")
            sub_results+=("$sub_name:❌")
            continue
        fi

        # Look for the location string in the log (unique identifier)
        if grep -q "$location" "$log_file"; then
            ((received_count++))
            sub_results+=("$sub_name:✅")
        else
            missing_subs+=("$sub_name")
            sub_results+=("$sub_name:❌")
        fi
    done

    # Store per-subscriber results (pipe-separated)
    local results_line=$(IFS='|'; echo "${sub_results[*]}")
    echo "$results_line" > "$RESULTS_DIR/$pub_name"

    # Report results
    echo ""
    if [ "$received_count" -eq 7 ]; then
        echo -e "${GREEN}✓ SUCCESS: All 7 subscribers received message${NC}"
    else
        echo -e "${RED}✗ FAILED: Only ${received_count}/7 subscribers received message${NC}"
        echo -e "${YELLOW}Missing: ${missing_subs[*]}${NC}"
    fi
    echo ""
}

# Run all publisher tests
run_publisher_test "nodejs" "mqtt"
run_publisher_test "nodejs" "ws"
run_publisher_test "python" "mqtt"
run_publisher_test "python" "ws"
run_publisher_test "mqttx" "mqtt"

# Print final summary
echo ""
echo "========================================="
echo "Test Summary Matrix"
echo "========================================="
echo ""

# Subscriber names for header
subscribers=(
    "nodejs-mqtt"
    "nodejs-ws"
    "nodejs-sse"
    "python-mqtt"
    "python-ws"
    "python-sse"
    "mqttx-mqtt"
)

# Print table header
printf "%-40s" "Publisher (rows) / Subscriber (columns)"
for sub in "${subscribers[@]}"; do
    printf " %-12s" "$sub"
done
echo ""

printf "%-40s" "----------------------------------------"
for sub in "${subscribers[@]}"; do
    printf " %-12s" "------------"
done
echo ""

# Get publisher labels
get_pub_label() {
    case "$1" in
        "nodejs-mqtt") echo "Node.js MQTT" ;;
        "nodejs-ws") echo "Node.js WS" ;;
        "python-mqtt") echo "Python MQTT" ;;
        "python-ws") echo "Python WS" ;;
        "mqttx-mqtt") echo "MQTTX MQTT" ;;
    esac
}

# Count successes
total_tests=0
passed_tests=0

# Print results for each publisher
for pub_name in "nodejs-mqtt" "nodejs-ws" "python-mqtt" "python-ws" "mqttx-mqtt"; do
    ((total_tests++))
    pub_label=$(get_pub_label "$pub_name")
    printf "%-40s" "$pub_label"

    if [ -f "$RESULTS_DIR/$pub_name" ]; then
        # Read per-subscriber results
        results=$(cat "$RESULTS_DIR/$pub_name")

        # Check if all passed
        all_passed=true
        for sub in "${subscribers[@]}"; do
            # Extract status for this subscriber
            status=$(echo "$results" | grep -o "$sub:[^|]*" | cut -d: -f2)

            if [ -z "$status" ]; then
                printf " %-12s" "⚪️"
                all_passed=false
            elif [ "$status" = "✅" ]; then
                # Green for success
                printf " ${GREEN}%-12s${NC}" "$status"
            else
                # Red for failure
                printf " ${RED}%-12s${NC}" "$status"
                all_passed=false
            fi
        done

        if [ "$all_passed" = true ]; then
            ((passed_tests++))
        fi
    else
        # No results file
        for sub in "${subscribers[@]}"; do
            printf " ${RED}%-12s${NC}" "⚪️"
        done
    fi
    echo ""
done

echo ""
echo "Overall: ${passed_tests}/${total_tests} publishers fully successful"
echo ""

# Update README with results
"$PROJECT_ROOT/client/update-test-results.sh" "$RESULTS_DIR" || echo "Warning: Could not update README"

if [ "$passed_tests" -eq "$total_tests" ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
    exit 1
fi
