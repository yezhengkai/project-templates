# syntax=docker/dockerfile:1
ARG PYTHON_VERSION={{ python_version }}
FROM python:$PYTHON_VERSION-slim AS base
{%- if development_environment == "strict" %}

# Configure Python to print tracebacks on crash [1], and to not buffer stdout and stderr [2].
# [1] https://docs.python.org/3/using/cmdline.html#envvar-PYTHONFAULTHANDLER
# [2] https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED
ENV PYTHONFAULTHANDLER 1
ENV PYTHONUNBUFFERED 1
{%- endif %}

# Install Poetry.
ENV POETRY_VERSION 1.4.2
RUN --mount=type=cache,target=/root/.cache/pip/ \
    pip install poetry~=$POETRY_VERSION

# Install compilers that may be required for certain packages or platforms.
RUN rm /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,target=/var/cache/apt/ \
    --mount=type=cache,target=/var/lib/apt/ \
    apt-get update && \
    apt-get install --no-install-recommends --yes build-essential

# Create a non-root user and switch to it [1].
# [1] https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
ARG UID=1000
ARG GID=$UID
RUN groupadd --gid $GID user && \
    useradd --create-home --gid $GID --uid $UID user --no-log-init && \
    chown user /opt/
USER user

# Create and activate a virtual environment.
RUN python -m venv /opt/{{ package_name | slugify | kebab_case }}-env
ENV PATH /opt/{{ package_name | slugify | kebab_case }}-env/bin:$PATH
ENV VIRTUAL_ENV /opt/{{ package_name | slugify | kebab_case }}-env

# Set the working directory.
WORKDIR /workspaces/{{ package_name | slugify | kebab_case }}/

# Install the run time Python dependencies in the virtual environment.
COPY --chown=user:user poetry.lock* pyproject.toml /workspaces/{{ package_name | slugify | kebab_case }}/
RUN mkdir -p /home/user/.cache/pypoetry/ && mkdir -p /home/user/.config/pypoetry/ && \
    mkdir -p src/{{ package_name | snake_case }}/ && touch src/{{ package_name | snake_case }}/__init__.py && touch README.md
RUN --mount=type=cache,uid=$UID,gid=$GID,target=/home/user/.cache/pypoetry/ \
    {%- if private_package_repository_name %}
    --mount=type=secret,id=poetry-auth,uid=$UID,gid=$GID,target=/home/user/.config/pypoetry/auth.toml \
    {%- endif %}
    poetry install --only main --no-interaction



FROM base as ci

# Allow CI to run as root.
USER root

# Install git so we can run pre-commit.
RUN --mount=type=cache,target=/var/cache/apt/ \
    --mount=type=cache,target=/var/lib/apt/ \
    apt-get update && \
    apt-get install --no-install-recommends --yes git

# Install the CI/CD Python dependencies in the virtual environment.
RUN --mount=type=cache,target=/root/.cache/pypoetry/ \
    {%- if private_package_repository_name %}
    --mount=type=secret,id=poetry-auth,target=/root/.config/pypoetry/auth.toml \
    {%- endif %}
    poetry install --only main,test --no-interaction



FROM base as dev

# Install development tools: curl, git, gpg, ssh, starship, sudo, vim, and zsh.
USER root
RUN --mount=type=cache,target=/var/cache/apt/ \
    --mount=type=cache,target=/var/lib/apt/ \
    apt-get update && \
    apt-get install --no-install-recommends --yes curl git gnupg ssh sudo vim zsh && \
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- "--yes" && \
    usermod --shell /usr/bin/zsh user && \
    echo 'user ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/user && chmod 0440 /etc/sudoers.d/user
USER user

# Install the development Python dependencies in the virtual environment.
RUN --mount=type=cache,uid=$UID,gid=$GID,target=/home/user/.cache/pypoetry/ \
    {%- if private_package_repository_name %}
    --mount=type=secret,id=poetry-auth,uid=$UID,gid=$GID,target=/home/user/.config/pypoetry/auth.toml \
    {%- endif %}
    poetry install --no-interaction

# Persist output generated during docker build so that we can restore it in the dev container.
COPY --chown=user:user .pre-commit-config.yaml /workspaces/{{ package_name | slugify | kebab_case }}/
RUN mkdir -p /opt/build/poetry/ && cp poetry.lock /opt/build/poetry/ && \
    git init && pre-commit install --install-hooks && \
    mkdir -p /opt/build/git/ && cp .git/hooks/commit-msg .git/hooks/pre-commit /opt/build/git/

# Configure the non-root user's shell.
ENV ANTIDOTE_VERSION 1.8.6
RUN git clone --branch v$ANTIDOTE_VERSION --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote/ && \
    echo 'zsh-users/zsh-syntax-highlighting' >> ~/.zsh_plugins.txt && \
    echo 'zsh-users/zsh-autosuggestions' >> ~/.zsh_plugins.txt && \
    echo 'source ~/.antidote/antidote.zsh' >> ~/.zshrc && \
    echo 'antidote load' >> ~/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc && \
    echo 'HISTFILE=~/.history/.zsh_history' >> ~/.zshrc && \
    echo 'HISTSIZE=1000' >> ~/.zshrc && \
    echo 'SAVEHIST=1000' >> ~/.zshrc && \
    echo 'setopt share_history' >> ~/.zshrc && \
    echo 'bindkey "^[[A" history-beginning-search-backward' >> ~/.zshrc && \
    echo 'bindkey "^[[B" history-beginning-search-forward' >> ~/.zshrc && \
    mkdir ~/.history/ && \
    zsh -c 'source ~/.zshrc'
{%- if private_package_repository_name %}

# Enable Poetry to read the private package repository credentials.
RUN ln -s /run/secrets/poetry-auth /home/user/.config/pypoetry/auth.toml
{%- endif %}
{%- if with_fastapi_api or with_streamlit_app or with_typer_cli %}



FROM base AS app

# Copy the package source code to the working directory.
COPY --chown=user:user . .

# Expose the application.
{%- if with_fastapi_api or with_streamlit_app %}
ENTRYPOINT ["/opt/{{ package_name | slugify | kebab_case }}-env/bin/poe"]
CMD [{% if with_fastapi_api %}"api"{% else %}"app"{% endif %}]
{%- else %}
ENTRYPOINT ["/opt/{{ package_name | slugify | kebab_case }}-env/bin/{{ package_name | slugify | kebab_case }}"]
CMD []
{%- endif %}
{%- endif %}