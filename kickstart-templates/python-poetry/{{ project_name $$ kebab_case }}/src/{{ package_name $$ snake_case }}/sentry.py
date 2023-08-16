"""Sentry configuration."""

import os
from importlib.metadata import version

import sentry_sdk


def configure_sentry() -> None:
    """Configure Sentry."""
    environment = os.environ.get("ENVIRONMENT", "local")
    sentry_sdk.init(
        dsn=os.environ["SENTRY_DSN"],
        traces_sample_rate=0.1 if environment != "production" else 0.001,
        release=f"{{ package_name | kebab_case }}@{version('{{ package_name | kebab_case }}')}",
        environment=environment,
    )