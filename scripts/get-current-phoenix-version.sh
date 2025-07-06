#!/bin/bash
# Get current Phoenix Framework version from mix.exs dependencies
grep '{:phoenix, "~>' mix.exs | grep -o '[0-9]\.[0-9]\.[0-9][0-9]*' | head -1 || echo "none"
