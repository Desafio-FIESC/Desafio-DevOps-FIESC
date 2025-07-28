FROM python:3.10.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src ./src
COPY cron.sh .
COPY start.sh .
COPY .env .env

RUN mkdir -p ./uploads
RUN chmod +x *.sh

ENV PYTHONPATH=/app/src

CMD ["bash", "start.sh"]
