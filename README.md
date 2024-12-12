# Android Mining

Quick installation and setup of ccminer on Android Phones.

## Installation

1. Visit this repo on your mobile device via a browser
2. Download and install the latest arm64-v8a [Termux](https://github.com/termux/termux-app/releases/download/v0.118.0/termux-app_v0.118.0+github-debug_arm64-v8a.apk):
```
https://github.com/termux/termux-app/releases/download/v0.118.0/termux-app_v0.118.0+github-debug_arm64-v8a.apk
```
3. Launch Termux:
4. Run the following command:
```bash
curl -o- -k https://raw.githubusercontent.com/tkashro/verus-mining/main/install.sh | bash
```

## Usage

1. Modify `config.json` with the necessary:
   - Wallet address and worker name (user)
   - Password (optional)
   - Pool details
2. Start mining with `~/ccminer/start.sh`

## Monitoring Miners (on a linux host)
See [MONITORING](/monitoring/MONITORING.md).
