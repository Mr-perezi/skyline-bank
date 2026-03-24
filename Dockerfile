FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy application
COPY . .

# Create static directory and collect static files
RUN mkdir -p /app/staticfiles && \
    python manage.py collectstatic --no-input

# Expose port
EXPOSE 8000

# Run gunicorn
CMD ["gunicorn", "bank_site.wsgi:application", "--bind", "0.0.0.0:8000"]