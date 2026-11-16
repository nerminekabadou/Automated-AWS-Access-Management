from urllib.parse import parse_qs, urlparse

from decision_token import build_link, verify

SECRET = "test-secret"
NOW = 1_700_000_000


def params(link):
    return {k: v[0] for k, v in parse_qs(urlparse(link).query).items()}


def test_valid_link_is_accepted():
    p = params(build_link("https://api/decision", SECRET, "alice", "disable", 24, now=NOW))
    assert verify(SECRET, p["username"], p["action"], p["expires"], p["token"], now=NOW + 60)


def test_expired_link_is_rejected():
    p = params(build_link("https://api/decision", SECRET, "alice", "disable", 24, now=NOW))
    assert not verify(SECRET, p["username"], p["action"], p["expires"], p["token"], now=NOW + 25 * 3600)


def test_tampered_link_is_rejected():
    p = params(build_link("https://api/decision", SECRET, "alice", "disable", 24, now=NOW))
    assert not verify(SECRET, "bob", p["action"], p["expires"], p["token"], now=NOW)
    assert not verify(SECRET, p["username"], "delete", p["expires"], p["token"], now=NOW)
    assert not verify(SECRET, p["username"], p["action"], str(int(p["expires"]) + 3600), p["token"], now=NOW)
    assert not verify("other-secret", p["username"], p["action"], p["expires"], p["token"], now=NOW)


def test_unknown_action_and_bad_input_are_rejected():
    assert not verify(SECRET, "alice", "promote", str(NOW + 100), "x", now=NOW)
    assert not verify(SECRET, "alice", "disable", "not-a-number", "x", now=NOW)
    assert not verify(SECRET, "", "disable", str(NOW + 100), "x", now=NOW)
