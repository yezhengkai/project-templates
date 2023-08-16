"""Test {{ package_name }}."""

import {{ package_name | snake_case }}


def test_import() -> None:
    """Test that the package can be imported."""
    assert isinstance({{ package_name | snake_case }}.__name__, str)