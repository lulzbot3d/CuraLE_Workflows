#!/bin/bash

echo "Install required system dependencies"
brew install autoconf automake ninja wget 2>&1 | grep -v "is already installed and up-to-date"
