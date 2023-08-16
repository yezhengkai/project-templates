"""Streamlit app."""

from importlib.metadata import version

import streamlit as st

st.title(f"{{ package_name }} v{version('{{ package_name | kebab_case }}')}")  # type: ignore[no-untyped-call]