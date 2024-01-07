enum VehicleEnum { moto, car, truck }

String translateVehicleEnum(dynamic vehicle) {
  if (vehicle is VehicleEnum) {
    switch (vehicle) {
      case VehicleEnum.moto:
        return 'Moto';
      case VehicleEnum.car:
        return 'Voiture';
      case VehicleEnum.truck:
        return 'Camion';
      default:
        return 'Inconnu';
    }
  } else if (vehicle is String) {
    switch (vehicle) {
      case 'moto':
        return 'Moto';
      case 'car':
        return 'Voiture';
      case 'truck':
        return 'Camion';
      default:
        return 'Inconnu';
    }
  } else {
    throw ArgumentError('vehicle doit être de type VehicleEnum ou String');
  }
}
