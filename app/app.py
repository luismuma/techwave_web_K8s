from flask import Flask, render_template, request
import logging
from pythonjsonlogger import jsonlogger

from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.exporter.prometheus import PrometheusMetricReader
from opentelemetry.instrumentation.flask import FlaskInstrumentor

from werkzeug.middleware.dispatcher import DispatcherMiddleware
from prometheus_client import make_wsgi_app


# ---------------------------
# Logging estructurado
# ---------------------------
logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    "%(asctime)s %(levelname)s %(name)s %(message)s"
)
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)

# ---------------------------
# Flask App
# ---------------------------
app = Flask(__name__)

# --------------------------------
# OpenTelemetry → Prometheus
# --------------------------------
# Creamos la instancia correcta
prometheus_reader = PrometheusMetricReader()

metrics.set_meter_provider(
    MeterProvider(metric_readers=[prometheus_reader])
)

meter = metrics.get_meter("flask-app")

#FlaskInstrumentor().instrument()
FlaskInstrumentor().instrument_app(app)

division_errors = meter.create_counter(
    name="division_errors_total",
    description="Errores de división por cero"
)

operation_counter = meter.create_counter(
    name="operations_total",
    description="Número de operaciones realizadas",
)

# Funciones backend
def raiz (b, i):
    return b ** (1/i) 

def sumar(a, b):
    return a + b

def restar(a, b):
    return a - b

def multiplicar(a, b):
    return a * b

def dividir(a, b):
    if b == 0:
        division_errors.add(1)
        logger.error(
            "division_error",
            extra={"operation": "division", "num1": a, "num2": b}
        )
        return "Error: división por cero"
    return a / b

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/calcular', methods=['POST'])
def calcular():
    a = float(request.form['num1'])
    b = float(request.form['num2'])
    operacion = request.form['operacion']

    if operacion == 'suma':
        resultado = sumar(a, b)
    elif operacion == 'resta':
        resultado = restar(a, b)
    elif operacion == 'multiplicacion':
        resultado = multiplicar(a, b)
    elif operacion == 'division':
        resultado = dividir(a, b)
    else:
        resultado = 'Operación no válida'
    operation_counter.add(1, {"operation": operacion})

    return render_template('index.html', resultado=resultado)

# ---------------------------
# /metrics para Prometheus
# ---------------------------
app.wsgi_app = DispatcherMiddleware(
    app.wsgi_app,
    {"/metrics": make_wsgi_app()}
)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
