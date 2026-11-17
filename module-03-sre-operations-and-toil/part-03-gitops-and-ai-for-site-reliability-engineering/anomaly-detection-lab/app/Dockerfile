FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir flask prometheus-client
COPY app.py normal_traffic.py spike_traffic.py ./
CMD ["python", "app.py"]