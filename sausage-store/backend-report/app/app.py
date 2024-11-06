from flask import Flask, jsonify
import os
import requests
import pymongo
from apscheduler.schedulers.background import BackgroundScheduler
from flask import Flask

app = Flask(__name__)

DB = os.environ.get('DB') if os.environ.get('DB') else "mongodb://localhost:27017/test"
client = pymongo.MongoClient(DB)
parsedUri = pymongo.uri_parser.parse_uri(DB)
db = client[parsedUri['database']]


@app.route('/health')
@app.route('/')
def home():
    return jsonify("I'm alive")


def load_report():
    response = requests.get("https://d5dg7f2abrq3u84p3vpr.apigw.yandexcloud.net/report")
    db.reports.insert_one(response.json())
    print("Inserted a new report to the database: " + response.text)


if __name__ == "__main__":
    sched = BackgroundScheduler(daemon=True)
    sched.add_job(load_report, 'interval', minutes=5)
    sched.start()
    load_report()
    app.run(host='0.0.0.0', debug=True, port=os.environ.get('PORT'), use_reloader=False)
