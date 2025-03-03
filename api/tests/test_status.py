import pytest
from api.main import app

@pytest.fixture
def client():
    app.testing = True
    return app.test_client()

def test_status(client):
    response = client.get('/status')
    assert response.status_code == 200
    data = response.get_json()
    assert data == {'message': 'OK!!!', 'statusCode': '200'}

def test_hurray(client):
    response = client.get('/hurray')
    assert response.status_code == 200
    data = response.get_json()
    assert data == {'message': 'Hurray we made it!!!'}
