import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:traveller_app/constants/api_constants.dart';
import 'package:traveller_app/models/advertisement.dart';

class AdvertisementApiServices {
  Future<List<Advertisement>> getAdvertisements() async{
    final url = Uri.parse("$baseUrl/advertisement/all");
    final response = await http.get(url);
    
    if (response.statusCode == 200){
      List<dynamic> advertisementData = response.body.isNotEmpty
        ? List<dynamic>.from(jsonDecode(response.body))
        : [];
        
      List<Advertisement> advertisements = advertisementData.map(
        (dynamic item) => Advertisement.fromJson(item as Map<String, dynamic>)
      ).toList();

      return advertisements;
    }
    else{
      // Handle non-200 status code
      print("API error: ${response.statusCode}");
      return []; // Return empty list in case of error
    }
  }
}