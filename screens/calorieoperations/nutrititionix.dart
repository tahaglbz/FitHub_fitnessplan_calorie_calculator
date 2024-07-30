import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionixService {
  final String _apiUrl =
      "https://trackapi.nutritionix.com/v2/natural/nutrients";
  final Map<String, String> _headers = {
    "x-app-id": "ffd38b17",
    "x-app-key": "cbaa6db7a49150a894803f9f27a661e9",
    "Content-Type": "application/json"
  };

  Future<Map<String, dynamic>?> getCaloriesAndServingSize(
      String foodItem) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: _headers,
      body: json.encode({"query": foodItem}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final double calories =
          (data['foods'][0]['nf_calories'] as num).toDouble();
      final double servingSize =
          (data['foods'][0]['serving_weight_grams'] as num).toDouble();
      return {
        'calories': calories,
        'servingSize': servingSize,
      };
    } else {
      return null;
    }
  }

  double? calculateGramtoCalorie(Map<String, dynamic> foodData) {
    final double calories = foodData['calories'];
    final double servingSize = foodData['servingSize'];
    if (servingSize > 0) {
      return calories / servingSize;
    } else {
      return null;
    }
  }
}
