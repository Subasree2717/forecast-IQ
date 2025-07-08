from flask import Flask, jsonify, request
from flask_cors import CORS
import requests
from model_utils import predict_next_7_days, load_and_predict  # Import both ML functions
from datetime import datetime

app = Flask(__name__)
CORS(app)

import os
API_KEY = os.getenv("WEATHER_API_KEY")


@app.route("/today", methods=["GET"])
def get_today_weather():
    try:
        # Get latitude and longitude from frontend if available
        lat = request.args.get("lat")
        lon = request.args.get("lon")

        if lat and lon:
            url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric"
        else:
            # Fallback city
            city = "Chennai,IN"
            url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric"

        res = requests.get(url)
        data = res.json()

        result = {
            "date": datetime.fromtimestamp(data["dt"]).strftime("%d-%m-%Y"),
            "city": data["name"],
            "temp": round(data["main"]["temp"]),
            "humidity": data["main"]["humidity"],
            "wind_speed": data["wind"]["speed"],
            "weather": data["weather"][0]["main"]
        }
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/predict", methods=["GET"])
def predict_today():
    try:
        result = load_and_predict()
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/predict-week", methods=["GET"])
def predict_week():
    try:
        result = predict_next_7_days()
        return jsonify(result), 200
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
