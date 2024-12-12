FROM apache/airflow:2.9.1-python3.9

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

    
RUN apt-get update && apt-get install -y git

RUN groupadd -g 1000 airflow && \
    usermod -g airflow airflow

USER airflow

RUN pip install --upgrade pip

RUN mkdir -p /opt/airflow/dbt/ecommerce/logs && \
    chown -R airflow /opt/airflow/dbt/ecommerce


COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

