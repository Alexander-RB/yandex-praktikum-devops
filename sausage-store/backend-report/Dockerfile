FROM python:3.10.15-alpine3.20
ADD app /app
WORKDIR /app
RUN pip install -r requirements.txt
RUN apk add --no-cache wget
RUN wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" --output-document /app/YandexInternalRootCA.crt
ENTRYPOINT ["python"]
CMD ["app.py"]
EXPOSE 8080