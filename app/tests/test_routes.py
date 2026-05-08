from app.app import app

import pytest

@pytest.fixture
def client():
    app.config['TESTING'] = True

    with app.test_client() as client:
        yield client

def test_index(client):
    response = client.get('/')

    assert response.status_code == 200

def test_calcular_suma(client):
    response = client.post(
        '/calcular',
        data={
            'num1': '5',
            'num2': '3',
            'operacion': 'suma'
        }
    )

    assert response.status_code == 200
    assert b'8' in response.data

def test_calcular_division_por_cero(client):
    response = client.post(
        '/calcular',
        data={
            'num1': '5',
            'num2': '0',
            'operacion': 'division'
        }
    )

    assert response.status_code == 200
    assert b'Error: divisi' in response.data
