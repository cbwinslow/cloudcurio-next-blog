#!/bin/bash
# Script to run Python worker tests

cd "$(dirname "$0")/../worker"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements-test.txt
else
    source venv/bin/activate
fi

# Run tests
echo "Running Python worker tests..."
python -m pytest tests/ -v

deactivate