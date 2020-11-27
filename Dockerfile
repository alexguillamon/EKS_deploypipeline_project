# Code refactored from https://sourcery.ai/blog/python-docker/
FROM python:3.8.6 AS base

## Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

## Dependencies image
FROM base AS python-deps
RUN pip install pipenv

COPY Pipfile .
COPY Pipfile.lock .

## Install dependencies with pipenv 
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

FROM base as runtime

## Copy virtualenv from python_deps stage
COPY --from=python-deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"

## Create new user
RUN useradd --create-home app
WORKDIR /home/app
USER app

## Copy application into container
COPY . .

## Run application in container
ENTRYPOINT ["gunicorn", "-b", ":8080", "main:APP"]
