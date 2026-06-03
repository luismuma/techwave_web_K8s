FROM python:3.11-slim
# Crear usuario no root
RUN useradd -m desarrollador
WORKDIR /app

# Instalar poetry y asegurar una versión limpia y segura de wheel
RUN pip install --no-cache-dir --upgrade pip wheel poetry

COPY pyproject.toml poetry.lock ./

# Instalar dependencias sin crear virtualenv
RUN poetry config virtualenvs.create false \
    && poetry install --only main --no-interaction --no-ansi --no-root

COPY app/ .

# Dar permisos al usuario no root
RUN chown -R desarrollador:desarrollador /app
# Cambiar al usuario no root
USER desarrollador
EXPOSE 5000
CMD ["python", "app.py"]
