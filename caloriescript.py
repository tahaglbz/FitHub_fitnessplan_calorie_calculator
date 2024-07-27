from flask import Flask, request, jsonify
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)

def get_calories(food_item):
    api_url = "https://trackapi.nutritionix.com/v2/natural/nutrients"
    headers = {
        "x-app-id": "ffd38b17",
        "x-app-key": "872ce405c9a0f80bc88fe53bef36b4a2",
        "Content-Type": "application/json"
    }
    data = {"query": food_item}
    response = requests.post(api_url, headers=headers, json=data)
    if response.status_code == 200:
        nutrients = response.json()
        return nutrients['foods'][0]['nf_calories']
    else:
        return None

@app.route('/get_calories', methods=['POST'])
def fetch_calories():
    data = request.get_json()
    food_item = data['food_item']
    calories = get_calories(food_item)
    if calories is not None:
        return jsonify({"calories": calories})
    else:
        return jsonify({"error": "Food item not found"}), 404

if __name__ == '__main__':
    app.run(debug=True)
