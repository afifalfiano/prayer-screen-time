import 'package:adhan/adhan.dart';

enum PrayerMethod {
  muslimWorldLeague('Muslim World League'),
  egyptian('Egyptian General Authority'),
  karachi('University of Islamic Sciences, Karachi'),
  ummAlQura('Umm Al-Qura University, Makkah'),
  dubai('Dubai'),
  qatar('Qatar'),
  kuwait('Kuwait'),
  singapore('Singapore'),
  northAmerica('ISNA (North America)'),
  tehran('Institute of Geophysics, Tehran'),
  turkey('Diyanet İşleri Başkanlığı, Turkey');

  const PrayerMethod(this.label);
  final String label;

  CalculationParameters get parameters {
    return switch (this) {
      PrayerMethod.muslimWorldLeague =>
        CalculationMethod.muslim_world_league.getParameters(),
      PrayerMethod.egyptian =>
        CalculationMethod.egyptian.getParameters(),
      PrayerMethod.karachi =>
        CalculationMethod.karachi.getParameters(),
      PrayerMethod.ummAlQura =>
        CalculationMethod.umm_al_qura.getParameters(),
      PrayerMethod.dubai =>
        CalculationMethod.dubai.getParameters(),
      PrayerMethod.qatar =>
        CalculationMethod.qatar.getParameters(),
      PrayerMethod.kuwait =>
        CalculationMethod.kuwait.getParameters(),
      PrayerMethod.singapore =>
        CalculationMethod.singapore.getParameters(),
      PrayerMethod.northAmerica =>
        CalculationMethod.north_america.getParameters(),
      PrayerMethod.tehran =>
        CalculationMethod.tehran.getParameters(),
      PrayerMethod.turkey =>
        CalculationMethod.turkey.getParameters(),
    };
  }
}
