enum DeliveryStatusEnum { pending, accepted, picked_up, delivered, cancelled }

String getStatusText(String? status) {
  if (status == DeliveryStatusEnum.pending.name) return 'En attente';
  if (status == DeliveryStatusEnum.accepted.name) return 'Accepté';
  if (status == DeliveryStatusEnum.picked_up.name) return 'Colis récupéré';
  if (status == DeliveryStatusEnum.delivered.name) return 'Livré';
  if (status == DeliveryStatusEnum.cancelled.name) return 'Annulé';
  return 'Inconnu';
}
