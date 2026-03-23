# Use official Python image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_ROOT_USER_ACTION=ignore
ENV IS_COLLECTSTATIC=True  # Add this line

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the full Django project
COPY . /app/

# Run only static files collection during build (with dummy database)
RUN python manage.py collectstatic --no-input

# Expose port
EXPOSE 8000

# Start server (IS_COLLECTSTATIC not set here)
CMD ["gunicorn", "bank_site.wsgi:application", "--bind", "0.0.0.0:8000"]