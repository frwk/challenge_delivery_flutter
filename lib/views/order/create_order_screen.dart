import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/components/my_location_list_tile.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/enums/urgency_enum.dart';
import 'package:challenge_delivery_flutter/enums/vehicle_enum.dart';
import 'package:challenge_delivery_flutter/helpers/loading_state.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/models/google_autocomplete/autocomplete_prediction.dart';
import 'package:challenge_delivery_flutter/models/google_autocomplete/place_autocomplete_response.dart';
import 'package:challenge_delivery_flutter/utils/network_utility.dart';
import 'package:challenge_delivery_flutter/views/order/order_summary.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:challenge_delivery_flutter/widgets/order/order_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:async';
import '../../bloc/order/order_bloc.dart';
import '../../enums/role_enum.dart';

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
  bool departureSelected = false;
  bool arrivalSelected = false;
  Timer? _debounce;

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
        'components': 'country:fr',
      });

      String? response;

      if (query.isNotEmpty && query.length > 3) {
        response = await NetworkUtility.fetchUrl(uri);
      }

      if (response != null) {
        PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);
        if (result.predictions != null) {
          if (addressType == 'departure') {
            setState(() {
              departurePlacePredictions = result.predictions!;
            });
          }

          if (addressType == 'arrival') {
            setState(() {
              arrivalPlacePredictions = result.predictions!;
            });
          }
        }
      }
    } catch (error) {
      print('Error during place autocomplete: $error');
    }
  }

  void onPlaceSelected(AutocompletePrediction place, String addressType) {
    if (addressType == 'departure') {
      setState(() {
        departureSelected = true;
        departurePlacePredictions.clear();
        _pickupAddressController.text = place.description!;
      });
    } else if (addressType == 'arrival') {
      setState(() {
        arrivalSelected = true;
        arrivalPlacePredictions.clear();
        _dropoffAddressController.text = place.description!;
      });
    }
  }

  Future<void> onSearchChanged(String value, String addressType) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    final selected = addressType == 'departure' ? departureSelected : arrivalSelected;
    if (!selected) {
      _debounce = Timer(const Duration(milliseconds: 1000), () async {
        await placeAutocomplete(value, addressType);
      });
    }
  }

  void dispose() {
    _debounce?.cancel();
    _pickupAddressController.dispose();
    _dropoffAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderBloc = BlocProvider.of<OrderBloc>(context);

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) async {
        if (state is OrderLoadingState) {
          modalLoading(context);
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
        } else if (state is OrderInitial) {
          Navigator.of(context, rootNavigator: true).pop();
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
                buildAddressInput(
                  controller: _pickupAddressController,
                  addressType: 'departure',
                  name: 'departure',
                  label: 'Adresse de départ',
                  placeholder: 'Entrez votre adresse de départ',
                  displayPlaceholder: true,
                  isEnabled: departureSelected ? false : true,
                  predictions: departurePlacePredictions.map((e) => e.description!).toList(),
                  onTap: (prediction) => onPlaceSelected(prediction as AutocompletePrediction, 'departure'),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                  prefixIcon: const Icon(Icons.home),
                  resetCallback: () {
                    _pickupAddressController.clear();
                    setState(() {
                      departureSelected = false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                buildPredictionsList(departurePlacePredictions.cast<AutocompletePrediction>(), 'departure'),
                buildAddressInput(
                  controller: _dropoffAddressController,
                  addressType: 'arrival',
                  name: 'arrival',
                  label: 'Adresse d\'arrivée',
                  placeholder: 'Entrez votre adresse d\'arrivée',
                  displayPlaceholder: true,
                  isEnabled: arrivalSelected ? false : true,
                  predictions: arrivalPlacePredictions.map((e) => e.description!).toList(),
                  onTap: (prediction) => onPlaceSelected(prediction as AutocompletePrediction, 'arrival'),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                  prefixIcon: const Icon(Icons.pin_drop),
                  resetCallback: () {
                    _dropoffAddressController.clear();
                    setState(() {
                      arrivalSelected = false;
                    });
                  },
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
                const Text('Quel mode de livraison souhaitez-vous ?'),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: FormBuilderRadioGroup(
                      name: 'vehicle',
                      orientation: OptionsOrientation.horizontal,
                      initialValue: VehicleEnum.moto.name,
                      options: [
                          FormBuilderFieldOption(value: VehicleEnum.moto.name, child: const Text('Moto')),
                        FormBuilderFieldOption(value: VehicleEnum.voiture.name, child: const Text('Voiture')),
                        FormBuilderFieldOption(value: VehicleEnum.camion.name, child: const Text('Camion')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Quel est l\'urgence de votre livraison ?'),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 350,
                    child: FormBuilderRadioGroup(
                      name: 'urgency',
                      orientation: OptionsOrientation.horizontal,
                      initialValue: UrgencyEnum.normal.name,
                      options: [
                        FormBuilderFieldOption(value: UrgencyEnum.normal.name,
                            child: const Column(
                              children: [
                                Text('Normal'),
                                Text('Jusqu\'à 24h', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                        )),
                        FormBuilderFieldOption(value: UrgencyEnum.urgent.name,
                            child: const Column(
                              children: [
                                Text('Urgent'),
                                Text('Jusqu\'à 3h', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            )
                        ),
                        FormBuilderFieldOption(value: UrgencyEnum.direct.name,
                            child: const Column(
                              children: [
                                Text('Direct'),
                                Text('Jusqu\'à 1h', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                                  _orderFormKey.currentState!.fields['vehicle']?.value,
                                  _orderFormKey.currentState!.fields['urgency']?.value,
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
    required String name,
    required String addressType,
    required String label,
    required bool isEnabled,
    required String placeholder,
    required List<String> predictions,
    required Function(String) onTap,
    required bool displayPlaceholder,
    required List<FormFieldValidator<String>>? validators,
    required Icon prefixIcon,
    required Function() resetCallback,
    String? initialValue,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: InputComponent(
        controller: controller,
        onChanged: (value) async => await onSearchChanged(value!, addressType),
        label: label,
        labelSize: 12,
        labelColor: Colors.grey,
        placeholder: placeholder,
        displayPlaceholder: displayPlaceholder,
        name: name,
        validators: [...?validators],
        isEnabled: isEnabled,
        prefixIcon: prefixIcon,
        suffixIcon: isEnabled
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => resetCallback(),
              ),
        initialValue: initialValue,
      ),
    );
  }
}
