FROM python:3.9.1-slim-buster

COPY . /app
WORKDIR /app

RUN pip install --upgrade pip
RUN pip install -r /app/scanner/requirements.txt

ENV PYTHONPATH "${PYTHONPATH}:/app"