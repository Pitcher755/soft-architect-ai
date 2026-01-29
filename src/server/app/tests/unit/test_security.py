import pytest

from app.core.security import InputSanitizer, TokenValidator


def test_sanitize_string_ok():
    s = "  hello world  "
    assert InputSanitizer.sanitize_string(s) == "hello world"


def test_sanitize_string_length_exceeded():
    long = "a" * 2000
    with pytest.raises(ValueError):
        InputSanitizer.sanitize_string(long, max_length=10)


def test_sanitize_string_dangerous_pattern():
    with pytest.raises(ValueError):
        InputSanitizer.sanitize_string("<script>alert(1)</script>")


def test_sanitize_prompt_calls_string():
    assert InputSanitizer.sanitize_prompt("prompt") == "prompt"


def test_validate_api_key_none():
    assert TokenValidator.validate_api_key(None) is False


def test_validate_api_key_short():
    assert TokenValidator.validate_api_key("short") is False


def test_validate_api_key_ok():
    assert TokenValidator.validate_api_key("longenoughkey") is True
