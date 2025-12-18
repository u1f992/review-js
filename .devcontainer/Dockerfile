FROM ruby:3.4.1

RUN apt-get update && apt-get install --yes --no-install-recommends \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
    && rm nodesource_setup.sh \
    && apt-get install --yes --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home review \
    # Configure bundler to install gems to user directory
    && bundle config set --local path '.bundle/gems'
