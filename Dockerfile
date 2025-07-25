FROM ruby:3.2.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    redis \
    git \
    nodejs \
    npm \
    tzdata \
    curl \
    ca-certificates

# Install wkhtmltopdf for PDF generation
RUN apk add --no-cache wkhtmltopdf

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle install

# Copy application code
COPY . .

# Generate Rails secret key
RUN bundle exec rake secret > /tmp/secret_key

# Create startup script
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'export SECRET_KEY_BASE=$(cat /tmp/secret_key)' >> /app/start.sh && \
    echo 'bundle exec rails db:create db:migrate || true' >> /app/start.sh && \
    echo 'bundle exec rails server -b 0.0.0.0 -p 3000' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 3000

CMD ["/app/start.sh"]