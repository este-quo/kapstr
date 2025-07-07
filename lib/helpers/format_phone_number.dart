Future<String?> formatPhoneNumber(String phoneNumber) async {
  if (phoneNumber.isEmpty) return null;

  // Remove all spaces from the phone number
  String formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');

  // Replace leading '0' with '+33'
  if (formattedPhoneNumber.startsWith('0')) {
    formattedPhoneNumber = '+33${formattedPhoneNumber.substring(1)}';
  }

  return formattedPhoneNumber;
}
