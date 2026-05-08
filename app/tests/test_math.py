from app.app import (
    sumar,
    restar,
    multiplicar,
    dividir,
    raiz
)

def test_sumar():
    assert sumar(2, 3) == 5

def test_restar():
    assert restar(10, 4) == 6

def test_multiplicar():
    assert multiplicar(3, 5) == 15

def test_dividir():
    assert dividir(10, 2) == 5

def test_dividir_por_cero():
    assert dividir(10, 0) == "Error: división por cero"

def test_raiz():
    assert raiz(27, 3) == 3

def test_raiz_indice_cero():
    assert raiz(10, 0) == "Error: el índice no puede ser 0"
