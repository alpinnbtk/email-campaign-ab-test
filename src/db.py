"""Shared database connection for scripts and notebooks.

Usage:
    from src.db import get_engine
    engine = get_engine()
"""

import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine

ROOT = Path(__file__).resolve().parents[1]  # repository root
CA_FILE = ROOT / "ca.pem"                   # optional CA certificate


def get_engine():
    """Create a SQLAlchemy engine that uses at most one connection.

    The pool is kept small on purpose: the free MySQL plan allows only a few
    simultaneous connections.
    """
    load_dotenv(ROOT / ".env")

    connect_args = {}
    if CA_FILE.exists():
        connect_args["ssl"] = {"ca": str(CA_FILE)}

    return create_engine(
        os.environ["MYSQL_URL"],
        pool_size=1,
        max_overflow=0,
        pool_recycle=300,
        connect_args=connect_args,
    )
