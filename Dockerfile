# ------------------- Stage 1: Building Stage ------------------------------
FROM python:3.9 AS builder

WORKDIR /app/backend

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/backend/

# Install app dependencies
RUN pip install mysqlclient
RUN pip install --no-cache-dir -r requirements.txt


# ------------------- Stage 2: Final Stage ------------------------------
FROM python:3.9-slim 

WORKDIR /app/backend

# Install runtime dependencies only
RUN apt-get update && \
    apt-get install -y --no-install-recommends libmariadb3 && \
    rm -rf /var/lib/apt/lists/*

# Copy dependencies and application code from the builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages/ /usr/local/lib/python3.9/site-packages/
# Copies only Python packages, not the actual gunicorn binary, which is installed in /usr/local/bin/

# Copy binaries (like gunicorn) from builder
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY . /app/backend

EXPOSE 8000
#RUN python manage.py migrate
#RUN python manage.py makemigrations
