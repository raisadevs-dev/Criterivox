from __future__ import annotations

import json
import os
import secrets
import time
import urllib.parse
import urllib.request
from typing import Any

from .human_residence_local_store import human_residence_local

GOOGLE_AUTHORIZE = "https://accounts.google.com/o/oauth2/v2/auth"
GOOGLE_TOKEN = "https://oauth2.googleapis.com/token"
GOOGLE_USERINFO = "https://openidconnect.googleapis.com/v1/userinfo"
_PENDING: dict[str, float] = {}


def _config() -> tuple[str, str, str]:
    return (
        os.getenv("CRITERIVOX_GOOGLE_CLIENT_ID", "").strip(),
        os.getenv("CRITERIVOX_GOOGLE_CLIENT_SECRET", "").strip(),
        os.getenv("CRITERIVOX_GOOGLE_REDIRECT_URI", "").strip(),
    )


def configured() -> bool:
    client_id, secret, redirect = _config()
    return bool(client_id and secret and redirect)


def authorization_url() -> str:
    client_id, _, redirect = _config()
    if not client_id or not redirect:
        raise RuntimeError("Google account connection is not configured.")
    state = secrets.token_urlsafe(24)
    _PENDING[state] = time.time() + 600
    params = {
        "client_id": client_id,
        "redirect_uri": redirect,
        "response_type": "code",
        "scope": "openid email profile",
        "access_type": "offline",
        "prompt": "consent",
        "state": state,
    }
    return f"{GOOGLE_AUTHORIZE}?{urllib.parse.urlencode(params)}"


def _exchange(code: str) -> dict[str, Any]:
    client_id, secret, redirect = _config()
    body = urllib.parse.urlencode({
        "code": code,
        "client_id": client_id,
        "client_secret": secret,
        "redirect_uri": redirect,
        "grant_type": "authorization_code",
    }).encode()
    request = urllib.request.Request(
        GOOGLE_TOKEN,
        data=body,
        headers={"Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        return json.loads(response.read().decode())


def _userinfo(access_token: str) -> dict[str, Any]:
    request = urllib.request.Request(
        GOOGLE_USERINFO,
        headers={"Authorization": f"Bearer {access_token}", "Accept": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        return json.loads(response.read().decode())


def complete(code: str, state: str) -> dict[str, Any]:
    expiry = _PENDING.pop(state, None)
    if expiry is None or expiry < time.time():
        raise ValueError("Google OAuth state is invalid or expired.")
    token = _exchange(code)
    profile = _userinfo(str(token.get("access_token", "")))
    email = str(profile.get("email", "")).strip().lower()
    display_name = str(profile.get("name") or email.split("@")[0] or "Google user").strip()
    subject = str(profile.get("sub", "")).strip()
    if not email or not subject:
        raise ValueError("Google did not return a verified account identity.")
    identity, residence = human_residence_local.oauth_identity(
        provider="google",
        subject=subject,
        email=email,
        display_name=display_name,
        avatar_data_url=str(profile.get("picture") or ""),
    )
    session_token = human_residence_local.issue_session(identity["owner_id"])
    return {"identity": identity, "residence": residence, "session_token": session_token}


__all__ = ["configured", "authorization_url", "complete"]
