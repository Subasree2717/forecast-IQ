import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from sklearn.preprocessing import LabelEncoder
from joblib import load
from tensorflow.keras.models import load_model  # type: ignore

# Load model and transformers
model = load_model("lstm_weather_model.h5", compile=False)
scaler = load("minmax_scaler.save")
le = load("label_encoder.save")

CSV_PATH = "chennai weather combined_dataset.csv"
FORECAST_CSV = "7_day_forecast_seoul.csv"

def preprocess_data():
    df = pd.read_csv(CSV_PATH)
    df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_")
    df["date"] = pd.to_datetime(df["date"], format="%d-%m-%Y", dayfirst=True)
    df.dropna(inplace=True)

    df["weather_enc"] = le.transform(df["icon"])
    df["month"] = df["date"].dt.month / 12.0  # ✅ add month like in training

    features = ["tempmax", "tempmin", "humidity", "windspeed", "weather_enc", "month"]
    X_scaled = scaler.transform(df[features])

    return df, X_scaled

def load_and_predict():
    _, X_scaled = preprocess_data()
    input_seq = X_scaled[-7:]
    pred_scaled = model.predict(input_seq.reshape(1, 7, 6))[0][0]  # ✅ use shape (1, 7, 6)

    last_known = input_seq[-1].copy()
    last_known[0] = pred_scaled
    inv = scaler.inverse_transform([last_known])

    predicted_tempmax = round(inv[0][0])
    humidity = round(inv[0][2])
    wind_speed = round(inv[0][3])
    weather_code = int(round(inv[0][4]))
    predicted_weather = le.inverse_transform([weather_code])[0]

    return {
        "predicted_tempmax": int(predicted_tempmax),
        "humidity": int(humidity),
        "wind_speed": int(wind_speed),
        "predicted_weather": predicted_weather,
        "date": datetime.now().strftime("%d-%m-%Y")
    }

def predict_next_7_days():
    _, X_scaled = preprocess_data()
    input_seq = X_scaled[-7:].tolist()
    results = []
    today = datetime.now().date()

    for i in range(7):
        input_array = np.array(input_seq[-7:]).reshape(1, 7, 6)  # ✅ shape (1, 7, 6)
        pred_scaled = model.predict(input_array)[0][0]

        last_known = input_seq[-1].copy()
        last_known[0] = pred_scaled
        inv = scaler.inverse_transform([last_known])

        predicted_tempmax = round(inv[0][0])
        humidity = round(inv[0][2])
        wind_speed = round(inv[0][3])
        weather_code = int(round(inv[0][4]))
        predicted_weather = le.inverse_transform([weather_code])[0]

        results.append({
            "date": (today + timedelta(days=i + 1)).strftime("%d-%m-%Y"),
            "predicted_tempmax": int(predicted_tempmax),
            "humidity": int(humidity),
            "wind_speed": int(wind_speed),
            "predicted_weather": predicted_weather
        })

        input_seq.append(last_known)

    pd.DataFrame(results).to_csv(FORECAST_CSV, index=False)
    return results
