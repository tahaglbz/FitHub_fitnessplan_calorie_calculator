import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionixService {
  final String _apiUrl =
      "https://trackapi.nutritionix.com/v2/natural/nutrients";
  final Map<String, String> _headers = {
    "x-app-id": "ffd38b17",
    "x-app-key": "872ce405c9a0f80bc88fe53bef36b4a2",
    "Content-Type": "application/json"
  };

  Future<double?> getCalories(String foodItem) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: _headers,
      body: json.encode({"query": foodItem}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['foods'][0]['nf_calories'];
    } else {
      return null;
    }
  }
}
