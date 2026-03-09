#!/bin/bash

set -e

apt update && apt upgrade -y
apt install -y cowsay
cowsay ""Nice Repo. Take my number. 347 429 4231""