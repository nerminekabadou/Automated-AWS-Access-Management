import json
from urllib.parse import parse_qs, urlparse

import pytest

import admin_action
from decision_token import build_link


class FakeLambda:
    def __init__(self):
        self.calls = []

    def invoke(self, **kwargs):
        self.calls.append(kwargs)


@pytest.fixture
def fake_lambda(monkeypatch):
    monkeypatch.setenv("DECISION_SECRET", "s3cret")
    monkeypatch.setenv("CLEANUP_FUNCTION_NAME", "iam-cleanup-lambda")
    fake = FakeLambda()
    monkeypatch.setattr(admin_action, "lambda_client", fake)
    return fake


def event_for(link):
    return {"queryStringParameters": {k: v[0] for k, v in parse_qs(urlparse(link).query).items()}}


def test_signed_link_starts_cleanup(fake_lambda):
    link = build_link("https://api/decision", "s3cret", "alice", "delete", 24)
    response = admin_action.lambda_handler(event_for(link), None)
    assert response["statusCode"] == 200
    assert json.loads(fake_lambda.calls[0]["Payload"]) == {"username": "alice", "action": "delete"}


def test_forged_link_is_refused(fake_lambda):
    link = build_link("https://api/decision", "wrong-secret", "alice", "delete", 24)
    assert admin_action.lambda_handler(event_for(link), None)["statusCode"] == 403
    assert fake_lambda.calls == []


def test_missing_query_string_is_refused(fake_lambda):
    assert admin_action.lambda_handler({"queryStringParameters": None}, None)["statusCode"] == 403
