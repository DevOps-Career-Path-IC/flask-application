FROM python:3.9-slim AS build-stage

ENV PYTHONUNBUFFERED 1
WORKDIR /app/api

COPY requirements.txt /app/api/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.9-slim

ENV PYTHONUNBUFFERED 1
WORKDIR /app/api

COPY --from=build-stage /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=build-stage /usr/local/bin /usr/local/bin
RUN apt-get update \
    && apt-get install -y netcat-openbsd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV DB_HOST=http://mysql

COPY . .

ENTRYPOINT [ "python" ]

CMD [ "main.py" ]
