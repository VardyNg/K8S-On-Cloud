#!/bin/bash

# Script to remove all .terraform folders in the repository

echo "Searching and removing all .terraform folders in the repository..."

# Find and remove all .terraform directories
find . -type d -name ".terraform" -exec rm -rf {} +

echo "Cleanup completed!"