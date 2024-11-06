# Sausage Reporter

## Installation

1. Install `Python` and `pip`
2. Go to `app` folder
3. Run `pip install -r requirements.txt`
4. Set environment variables `PORT` and `DB`
5. Run `python app.py`

Example: `PORT=8080 DB=mongodb://localhost:27017/reports python3 app.py`

Or with TLS and certificate ignore:

Example: `PORT=8080 DB=mongodb://localhost:27017/reports?tls=true&tlsAllowInvalidCertificates=true python3 app.py`

## Health endpoint

Application exposes `/health` endpoint according to the 12-factors app

## Testing

Run unit tests via `python3 -m unittest`

## Local run with docker and local mongoDB

```bash
docker build -t sausage-reporter .
docker run -d --name mongo -p 27017:27017 mongo
docker run --name sausage-reporter -ti -e PORT=8080 -e DB=mongodb://host.docker.internal:27017/reports -p 8080:8080 sausage-reporter
```
