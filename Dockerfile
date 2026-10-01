FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

RUN python -m pip install --upgrade pip \
    && python -m pip install ".[ml]"

EXPOSE 8000

CMD ["sh", "-c", "uvicorn criterivox.app:app --app-dir src --host 0.0.0.0 --port ${PORT:-8000}"]
