FROM python:3.11-slim

WORKDIR /app

RUN pip install poetry

COPY pyproject.toml poetry.lock ./
# Instala solo dependencias de producción sin instalar el proyecto
RUN poetry config virtualenvs.create false \
&& poetry install --only main --no-interaction --no-ansi --no-root

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]
