import 'dart:convert';
import 'package:http/http.dart' as http;

/// Replace this with your actual API key from https://countrystatecity.in/
const String cscApiKey = 'YOUR_API_KEY_HERE';
const String cscBaseUrl = 'https://api.countrystatecity.in/v1';

Future<List<Map<String, dynamic>>> fetchCountries() async {
  final response = await http.get(
    Uri.parse('$cscBaseUrl/countries'),
    headers: {'X-CSCAPI-KEY': cscApiKey},
  );
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Failed to load countries');
  }
}

Future<List<Map<String, dynamic>>> fetchStates(String countryIso2) async {
  final response = await http.get(
    Uri.parse('$cscBaseUrl/countries/$countryIso2/states'),
    headers: {'X-CSCAPI-KEY': cscApiKey},
  );
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Failed to load states');
  }
}

Future<List<Map<String, dynamic>>> fetchCities(String countryIso2, String stateIso2) async {
  final response = await http.get(
    Uri.parse('$cscBaseUrl/countries/$countryIso2/states/$stateIso2/cities'),
    headers: {'X-CSCAPI-KEY': cscApiKey},
  );
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Failed to load cities');
  }
}
