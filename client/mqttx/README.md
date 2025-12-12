# MQTTX CLI Shell Scripts

MQTT publisher and subscriber shell scripts using MQTTX CLI.

## Dependencies

- **MQTTX CLI** - MQTT command line client
- **jq** - JSON parser (optional, for pretty printing)

## Installation

### Quick Install (Recommended)
```bash
./install.sh
```

The install script will automatically detect your platform and install:
- MQTTX CLI (via Homebrew or curl fallback on macOS)
- jq (for JSON parsing)

**Note:** On macOS, if Homebrew is not available, the script will automatically download binaries using curl. No additional setup required!

### Manual Installation

#### macOS with Homebrew
```bash
brew install emqx/mqttx/mqttx-cli
brew install jq
```

#### macOS with curl (no Homebrew)
```bash
# For Apple Silicon
curl -LO https://www.emqx.com/zh/downloads/MQTTX/v1.10.1/mqttx-cli-macos-arm64
sudo install ./mqttx-cli-macos-arm64 /usr/local/bin/mqttx

# For Intel
curl -LO https://www.emqx.com/zh/downloads/MQTTX/v1.10.1/mqttx-cli-macos-x64
sudo install ./mqttx-cli-macos-x64 /usr/local/bin/mqttx

# Install jq
curl -LO https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-arm64
sudo install ./jq-macos-arm64 /usr/local/bin/jq
```

#### Linux / Other
```bash
npm install -g @emqx/mqttx-cli
# Then install jq via your package manager
```

## Usage

### Publisher
```bash
./mqttx_publish.sh
```

### Subscriber
```bash
./mqttx_subscribe.sh
```

## Tier Structure

- **Tier 0 (MVP):** Single publish, no database persistence
- **Tier 1:** Enable database persistence with `--retain` flag
- **Tier 2:** Continuous publishing every 5 seconds
