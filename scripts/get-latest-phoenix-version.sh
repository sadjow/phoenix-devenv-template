#!/bin/bash
# Get latest stable Phoenix version (excluding release candidates)
mix hex.info phoenix | grep "Releases:" | head -1 | sed 's/.*Releases: //' | tr ',' '\n' | grep -v 'rc' | head -1 | tr -d ' '
