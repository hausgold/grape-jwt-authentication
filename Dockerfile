FROM hausgold/ruby:3.3
LABEL org.opencontainers.image.authors="containers@hausgold.de"

# Update system gem
RUN gem update --system '3.7.2'

# Install system packages and the latest bundler
RUN apt-get update -yqqq && \
  apt-get install -y \
    build-essential locales sudo vim \
    ca-certificates \
    bash-completion inotify-tools && \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && /usr/sbin/locale-gen && \
  gem install bundler -v '~> 2.7.2' --no-document --no-prerelease

# Add new web user
RUN mkdir /app && \
  adduser web --home /home/web --shell /bin/bash \
    --disabled-password --gecos ""
COPY config/docker/* /home/web/
RUN chown web:web -R /app /home/web /usr/local/bundle && \
  mkdir -p /home/web/.ssh

# Set the root password and grant root access to web
RUN echo 'root:root' | chpasswd
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

WORKDIR /app
