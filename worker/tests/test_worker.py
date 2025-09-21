"""
Tests for the CloudCurio review worker.
"""

import sys
import os
import pytest

# Add the worker directory to the path so we can import the worker module
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

def test_worker_import():
    """Test that the worker module can be imported without errors."""
    try:
        import review_worker_v2
        assert True
    except ImportError as e:
        pytest.fail(f"Failed to import worker module: {e}")

def test_device_class():
    """Test the Device class initialization."""
    try:
        import review_worker_v2
        device = review_worker_v2.Device("test", "0", "quick")
        assert device.label == "test"
        assert device.index == "0"
        assert device.klass == "quick"
        assert device.busy == False
        assert device.healthy == True
    except Exception as e:
        pytest.fail(f"Failed to create Device instance: {e}")