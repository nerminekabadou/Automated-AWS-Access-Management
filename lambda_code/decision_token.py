"""Signed, expiring tokens for the admin decision links sent by email.

The decision endpoint is public (it is opened from an email), so every link
carries an HMAC-SHA256 signature over (username, action, expiry). Without the
shared secret nobody can forge a link, and links stop working after expiry.
"""

import hashlib
import hmac
import time
import urllib.parse

ALLOWED_ACTIONS = ("disable", "delete")


def _signature(secret: str, username: str, action: str, expires: int) -> str:
    message = f"{username}\n{action}\n{expires}".encode()
    return hmac.new(secret.encode(), message, hashlib.sha256).hexdigest()


def build_link(base_url: str, secret: str, username: str, action: str, ttl_hours: int, now=None) -> str:
    if action not in ALLOWED_ACTIONS:
        raise ValueError(f"Unknown action: {action}")
    expires = int((now if now is not None else time.time()) + ttl_hours * 3600)
    query = urllib.parse.urlencode({
        "username": username,
        "action": action,
        "expires": expires,
        "token": _signature(secret, username, action, expires),
    })
    return f"{base_url}?{query}"


def verify(secret: str, username: str, action: str, expires: str, token: str, now=None) -> bool:
    if action not in ALLOWED_ACTIONS or not username or not token:
        return False
    try:
        expires_at = int(expires)
    except (TypeError, ValueError):
        return False
    if expires_at < (now if now is not None else time.time()):
        return False
    return hmac.compare_digest(_signature(secret, username, action, expires_at), token)
