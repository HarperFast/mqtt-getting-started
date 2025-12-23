#!/usr/bin/env bash
# Run each publisher and verify all subscribers received the message

set -euo pipefail

SESSION_NAME="mqtt-test-subscribers"
TIMEOUT=5
PROJECT_ROOT="/Users/ivan/Projects/mqtt-getting-started"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results (stored as temporary files for bash 3.2 compatibility)
RESULTS_DIR=$(mktemp -d)
trap "rm -rf $RESULTS_DIR" EXIT

echo "========================================="
echo "Cross-Protocol Pub/Sub Test Suite"
echo "========================================="
echo ""

# Check if tmux session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${RED}Error: Subscriber session not found${NC}"
    echo "Start subscribers first: ./run-all-subscribers.sh"
    exit 1
fi

echo "Found subscriber session: $SESSION_NAME"
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
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
    local temp=$(awk -v min=68 -v max=75 'BEGIN{srand(); print min+rand()*(max-min)}')
    local location="test-lab-publisher-${pub_name}"
    local payload="{\"temp\":${temp},\"location\":\"${location}\",\"publisher\":\"${pub_name}\",\"timestamp\":\"${timestamp}\"}"

    echo "Payload: $payload"
    echo ""

    # Determine which test publisher to use
    if [ "$lang" = "nodejs" ]; then
        local cmd="node ${PROJECT_ROOT}/client/nodejs/${protocol}-publish-test.js"
    else
        local cmd="python3 ${PROJECT_ROOT}/client/python/${protocol}-publish-test.py"
    fi

    # Publish the message
    echo "Publishing..."
    if ! $cmd "$payload" 2>&1; then
        echo -e "${RED}✗ Publish failed${NC}"
        echo "FAIL|0|6|Publish error" > "$RESULTS_DIR/$pub_name"
        return 1
    fi

    echo ""
    echo "Waiting ${TIMEOUT}s for message propagation..."
    sleep "$TIMEOUT"

    # Capture all tmux panes and look for RECEIVED lines
    echo "Checking subscriber receipts..."
    local received_count=0
    local missing_subs=()

    # Check each of the 6 panes
    for pane_id in 0 1 2 3 4 5; do
        local pane_content=$(tmux capture-pane -t "${SESSION_NAME}:0.${pane_id}" -p)

        # Look for RECEIVED line matching our publisher
        if echo "$pane_content" | tail -20 | grep -q "RECEIVED|.*|${pub_name}|"; then
            ((received_count++))
        else
            # Determine which subscriber this pane is
            case $pane_id in
                0) missing_subs+=("nodejs-mqtt") ;;
                1) missing_subs+=("nodejs-ws") ;;
                2) missing_subs+=("nodejs-sse") ;;
                3) missing_subs+=("python-mqtt") ;;
                4) missing_subs+=("python-ws") ;;
                5) missing_subs+=("python-sse") ;;
            esac
        fi
    done

    # Report results
    echo ""
    if [ "$received_count" -eq 6 ]; then
        echo -e "${GREEN}✓ SUCCESS: All 6 subscribers received message${NC}"
        echo "PASS|6|6|" > "$RESULTS_DIR/$pub_name"
    else
        echo -e "${RED}✗ FAILED: Only ${received_count}/6 subscribers received message${NC}"
        echo -e "${YELLOW}Missing: ${missing_subs[*]}${NC}"
        echo "FAIL|${received_count}|6|Missing: ${missing_subs[*]}" > "$RESULTS_DIR/$pub_name"
    fi
    echo ""
}

# Run all publisher tests
run_publisher_test "nodejs" "mqtt"
run_publisher_test "nodejs" "ws"
run_publisher_test "python" "mqtt"
run_publisher_test "python" "ws"

# Print final summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo ""

total_tests=0
passed_tests=0

for pub_name in "nodejs-mqtt" "nodejs-ws" "python-mqtt" "python-ws"; do
    ((total_tests++))

    if [ -f "$RESULTS_DIR/$pub_name" ]; then
        IFS='|' read -r status received total details < "$RESULTS_DIR/$pub_name"

        if [ "$status" = "PASS" ]; then
            ((passed_tests++))
            echo -e "${GREEN}✓${NC} ${pub_name}: ${received}/${total} subscribers"
        else
            echo -e "${RED}✗${NC} ${pub_name}: ${received}/${total} subscribers ($details)"
        fi
    else
        echo -e "${RED}✗${NC} ${pub_name}: No results found"
    fi
done

echo ""
echo "Overall: ${passed_tests}/${total_tests} publishers fully successful"
echo ""

if [ "$passed_tests" -eq "$total_tests" ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}Some tests failed${NC}"
    exit 1
fi
