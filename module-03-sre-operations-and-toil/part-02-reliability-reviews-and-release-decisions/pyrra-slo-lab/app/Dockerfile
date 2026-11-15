FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir flask prometheus-client
COPY app.py traffic.py ./
CMD ["python", "app.py"]