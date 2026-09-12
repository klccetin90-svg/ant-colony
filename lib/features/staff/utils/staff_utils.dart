import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class IbanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String filtered = newValue.text.replaceAll(' ', '').toUpperCase();
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class StaffUtils {
  static bool validateTC(String tc) {
    if (tc.length != 11 || tc.startsWith('0')) return false;

    int sumOdd = 0;
    int sumEven = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(tc[i]);
      if (i % 2 == 0) {
        sumOdd += digit;
      } else {
        sumEven += digit;
      }
    }

    int digit10 = (sumOdd * 7 - sumEven) % 10;
    if (digit10 < 0) digit10 += 10;
    if (digit10 != int.parse(tc[9])) return false;

    int totalSum = 0;
    for (int i = 0; i < 10; i++) {
      totalSum += int.parse(tc[i]);
    }

    return (totalSum % 10) == int.parse(tc[10]);
  }

  static bool validateIBAN(String iban) {
    String clean = iban.replaceAll(' ', '').toUpperCase();
    if (clean.length != 26 || !clean.startsWith('TR')) return false;
    return RegExp(r'^\d{24}$').hasMatch(clean.substring(2));
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static Future<void> openWhatsApp(String phoneNumber) async {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '9$cleanPhone';
    } else if (!cleanPhone.startsWith('90')) {
      cleanPhone = '90$cleanPhone';
    }
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanPhone');
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  static const List<String> cities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin', 'Aydın', 'Balıkesir',
    'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli',
    'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari',
    'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir', 'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir',
    'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş', 'Nevşehir',
    'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Tekirdağ', 'Tokat',
    'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman',
    'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce'
  ];
}