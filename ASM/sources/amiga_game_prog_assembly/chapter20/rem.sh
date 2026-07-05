#!/bin/bash

find . -type f -name "*.s" -exec \
sed -Ei 's|incdir[[:space:]]+"include"|incdir "../include"|g' {} +
