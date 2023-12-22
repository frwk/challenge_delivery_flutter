import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/components/my_location_list_tile.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/helpers/loading_state.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/models/google_autocomplete/autocomplete_prediction.dart';
import 'package:challenge_delivery_flutter/models/google_autocomplete/place_autocomplete_response.dart';
import 'package:challenge_delivery_flutter/utils/network_utility.dart';
import 'package:challenge_delivery_flutter/views/order/order_summary.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../bloc/order/order_bloc.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _orderFormKey = GlobalKey<FormBuilderState>();

  List<AutocompletePrediction> departurePlacePredictions = [];
  List<AutocompletePrediction> arrivalPlacePredictions = [];
  final TextEditingController _pickupAddressController = TextEditingController();
  final TextEditingController _dropoffAddressController = TextEditingController();
  AutocompletePrediction? selectedDeparturePrediction;
  bool isOnChangedActiveForDropoffAddress = true;
  bool isOnChangedActiveForPickupAddress = true;

  Future<void> placeAutocomplete(String query, String addressType) async {
    if (query.isEmpty) {
      return;
    }

    try {
      Uri uri = Uri.https('maps.googleapis.com', 'maps/api/place/autocomplete/json', {
        'input': query,
        'key': dotenv.env['GOOGLE_API_KEY']!,
      });

      String? response;

      if (query.isNotEmpty) {
        response = await NetworkUtility.fetchUrl(uri);
      }

      if (response != null) {
        PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);

        if (result.predictions != null) {
          if (addressType == 'departure' && isOnChangedActiveForPickupAddress) {
            setState(() {
              departurePlacePredictions = result.predictions!;
              isOnChangedActiveForPickupAddress = false;
            });
          }

          if (addressType == 'arrival' && isOnChangedActiveForDropoffAddress) {
            setState(() {
              arrivalPlacePredictions = result.predictions!;
              isOnChangedActiveForDropoffAddress = false;
            });
          }
        }
      }
    } catch (error) {
      print('Error during place autocomplete: $error');
    }
  }

  void onPlaceSelected(AutocompletePrediction place, String addressType) {
    if (addressType == 'departure' && !isOnChangedActiveForPickupAddress) {
      setState(() {
        _pickupAddressController.text = place.description!;
        departurePlacePredictions.clear();
      });
    }

    if (addressType == 'arrival' && !isOnChangedActiveForDropoffAddress) {
      setState(() {
        _dropoffAddressController.text = place.description!;
        arrivalPlacePredictions = [];
      });
    }
  }

  void dispose() {
    _pickupAddressController.dispose();
    _dropoffAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderBloc = BlocProvider.of<OrderBloc>(context);

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) async {
        print('Create order screen $state');
        if (state is OrderLoadingState) {
          modalLoading(context);
        } else if (state is OrderFailureState) {
          Navigator.of(context, rootNavigator: true).pop();
          showSnackMessage(context, state.error, MessageTypeEnum.error);
        } else if (state is OrderSuccessState) {
          Navigator.of(context, rootNavigator: true).pop();
          showSnackMessage(context, 'Commande créée avec succès', MessageTypeEnum.success);
        } else if (state is OrderAddressSuccessState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSummaryScreen(order: state.order!),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: const MyAppBar(title: 'Nouvelle commande'),
        body: SafeArea(
          child: FormBuilder(
            key: _orderFormKey,
            child: Column(
              children: [
                // Adresse de départ
                buildAddressInput(
                  controller: _pickupAddressController,
                  onChanged: (value) async => await placeAutocomplete(value, 'departure'),
                  name: 'departure',
                  label: 'Adresse de départ',
                  placeholder: 'Entrez votre adresse de départ',
                  displayPlaceholder: true,
                  predictions: departurePlacePredictions.map((e) => e.description!).toList(),
                  onTap: (prediction) => onPlaceSelected(prediction as AutocompletePrediction, 'departure'),
                  isOnChangedActive: isOnChangedActiveForPickupAddress,
                ),
                const SizedBox(height: 20),
                buildPredictionsList(departurePlacePredictions.cast<AutocompletePrediction>(), 'departure'),
                // Adresse de destination
                buildAddressInput(
                  controller: _dropoffAddressController,
                  onChanged: (value) async => await placeAutocomplete(value, 'arrival'),
                  name: 'arrival',
                  label: 'Adresse d\'arrivée',
                  placeholder: 'Entrez votre adresse d\'arrivée',
                  displayPlaceholder: true,
                  predictions: arrivalPlacePredictions.map((e) => e.description!).toList(),
                  onTap: (prediction) => onPlaceSelected(prediction as AutocompletePrediction, 'arrival'),
                  isOnChangedActive: isOnChangedActiveForDropoffAddress,
                ),
                const SizedBox(height: 30),
                buildPredictionsList(arrivalPlacePredictions.cast<AutocompletePrediction>(), 'arrival'),
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
                        child: InputComponent(
                          label: 'Type de colis',
                          labelSize: 12,
                          labelColor: Colors.grey,
                          placeholder: 'package_type',
                          name: 'package_type',
                          validators: [
                            FormBuilderValidators.required(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(right: 25.0),
                        child: InputComponent(
                          label: 'Poids - (En kg)',
                          labelSize: 12,
                          labelColor: Colors.grey,
                          placeholder: 'package_weight',
                          name: 'package_weight',
                          validators: [
                            FormBuilderValidators.required(),
                            FormBuilderValidators.integer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ButtonAtom(
                      data: 'Suivant',
                      onTap: () => {
                            if (_orderFormKey.currentState!.saveAndValidate())
                              {
                                orderBloc.add(OrderAddressEvent(
                                  _orderFormKey.currentState!.fields['departure']?.value,
                                  _orderFormKey.currentState!.fields['arrival']?.value,
                                  _orderFormKey.currentState!.fields['package_type']?.value,
                                  _orderFormKey.currentState!.fields['package_weight']?.value,
                                ))
                              }
                          }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPredictionsList(List<AutocompletePrediction> predictions, String addressType) {
    return predictions.isNotEmpty
        ? Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) => LocationListTile(
                onTap: () => onPlaceSelected(predictions[index], addressType),
                location: predictions[index].description!,
              ),
            ),
          )
        : const SizedBox(height: 0);
  }

  Widget buildAddressInput({
    required TextEditingController controller,
    required Function(String) onChanged,
    required String name,
    required String label,
    required String placeholder,
    required List<String> predictions,
    required Function(String) onTap,
    required bool isOnChangedActive,
    required bool displayPlaceholder,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: InputComponent(
        controller: controller,
        onChanged: (value) async {
          if (isOnChangedActive) {
            await onChanged(value!);
          }
        },
        label: label,
        labelSize: 12,
        labelColor: Colors.grey,
        placeholder: placeholder,
        displayPlaceholder: displayPlaceholder,
        name: name,
      ),
    );
  }
}
