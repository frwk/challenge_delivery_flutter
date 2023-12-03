import 'dart:convert';

import 'autocomplete_prediction.dart';

class PlaceAutocompleteResponse {
  final String status;
  final List<AutocompletePrediction>? predictions;

  const PlaceAutocompleteResponse({
    required this.status,
    this.predictions,
  });

  factory PlaceAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteResponse(
      status: json['status'],
      predictions: json['predictions'] != null ? (json['predictions'] as List).map((i) => AutocompletePrediction.fromJson(i)).toList() : null,
    );
  }

  static PlaceAutocompleteResponse parseAutocompleteResult(String responseBody) {

    final parsed = jsonDecode(responseBody).cast<String, dynamic>();
    return PlaceAutocompleteResponse.fromJson(parsed);
  }
}