import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/common/constant.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/components/my_location_list_tile.dart';
import 'package:challenge_delivery_flutter/models/google_autocomplete/autocomplete_prediction.dart';
import 'package:challenge_delivery_flutter/models/google_autocomplete/place_autocomplete_response.dart';
import 'package:challenge_delivery_flutter/utils/network_utility.dart';
import 'package:flutter/material.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {

  List<AutocompletePrediction> departurePlacePredictions = [];
  List<AutocompletePrediction> arrivalPlacePredictions = [];
  TextEditingController _departureAddressController = TextEditingController();
  TextEditingController _arrivalAddressController = TextEditingController();
  AutocompletePrediction? selectedDeparturePrediction;

  @override
  void initState() {
    super.initState();
  }

  Future<void> placeAutocomplete(String query, String addressType) async {
    Uri uri = Uri.https(
        'maps.googleapis.com',
        'maps/api/place/autocomplete/json',
      {
        'input': query,
        'key': apiKey
      }
    );
    
    String ?response = await NetworkUtility.fetchUrl(uri);

    if(response != null) {
      PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);

      if(result.predictions != null) {
        if(addressType == 'departure') {
          setState(() {
            departurePlacePredictions = result.predictions!;
          });
        } else if(addressType == 'arrival') {
          setState(() {
            arrivalPlacePredictions = result.predictions!;
          });
        }
      }
    }
  }

  void onPlaceSelected(AutocompletePrediction place, String addressType) {
    setState(() {
      var selectedPlace = place;

      if(addressType == 'departure') {
        _departureAddressController.text = place.description!;
        setState(() {
          departurePlacePredictions = [];
        });
      }

      if(addressType == 'arrival') {
        _arrivalAddressController.text = place.description!;
        setState(() {
          arrivalPlacePredictions = [];
        });
      }
    });

    print("Lieu sélectionné : ${place.description}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Center(
              child: Text(
                'Nouvelle commande',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            titleSpacing: 10,
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  color: Colors.black,
                  onPressed: () => {},
                ),
              ),
            ],
          ),
        ),
      ),
      body:  SafeArea(
        child: Column(
          children: [
            // Adresse de départ
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25.0),
              child: InputComponent(
                controller: _departureAddressController,
                onChanged: (value) async { await placeAutocomplete(value!, 'departure'); },
                label: 'Adresse de départ',
                labelSize: 12,
                labelColor: Colors.grey,
                placeholder: 'Entrez votre adresse de départ',
              ),
            ),
            const SizedBox(height: 20),
            departurePlacePredictions.isNotEmpty ? Expanded(
              child: ListView.builder(
                  itemCount: departurePlacePredictions.length,
                  itemBuilder: (context, index) => LocationListTile(
                    onTap: () {
                      onPlaceSelected(departurePlacePredictions[index], 'departure');
                    },
                    location: departurePlacePredictions[index].description!,
                  )
              ),
            ) : const SizedBox(height: 0),
            // Adresse de destination
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25.0),
              child: InputComponent(
                controller: _arrivalAddressController,
                onChanged: (value) async { await placeAutocomplete(value!, 'arrival');},
                label: 'Adresse de destination',
                labelSize: 12,
                labelColor: Colors.grey,
                placeholder: 'Entrez votre adresse de destination',
              ),
            ),
            const SizedBox(height: 30),
            arrivalPlacePredictions.isNotEmpty ? Expanded(
              child: ListView.builder(
                  itemCount: arrivalPlacePredictions.length,
                  itemBuilder: (context, index) => LocationListTile(
                    onTap: () {
                      onPlaceSelected(arrivalPlacePredictions[index], 'arrival');
                    },
                    location: arrivalPlacePredictions[index].description!,
                  )
              ),
            ) : const SizedBox(height: 0),
            Divider(
              color: Colors.grey.withOpacity(0.5),
              indent: 60,
              endIndent: 60,
              thickness: 1,
            ),
            const SizedBox(height: 30),
            // Type de colis
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(left: 25.0, right: 2),
                    child: const InputComponent(
                      label: 'Type de colis',
                      labelSize: 12,
                      labelColor: Colors.grey,
                      placeholder: 'Quel type de colis ?',
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(right: 25.0),
                    child: const InputComponent(
                      label: 'Poids',
                      labelSize: 12,
                      labelColor: Colors.grey,
                      placeholder: 'En kg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: ButtonAtom(data: 'Suivant'),
            ),
          ],
        ),
      ),
    );
  }
}
