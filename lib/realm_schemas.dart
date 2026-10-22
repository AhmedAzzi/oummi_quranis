// ignore_for_file: camel_case_types
// (_Quarter_first_verse keeps its snake_case name on purpose: renaming it
// would change the Realm table name 'Quarter_first_verse' and break the
// bundled database file.)
import 'package:realm/realm.dart';

part 'realm_schemas.realm.dart';

@RealmModel()
class _Hizb {
  @PrimaryKey()
  int index = 0;
  List<_Translation> titleTranslations = [];
  List<_Quarter> quarters = [];
}

@RealmModel()
class _Part {
  @PrimaryKey()
  late int index;
  late List<_Translation> titleTranslations;
  late List<_Hizb> hizbs;
  late List<_Quarter> quarters;
}

@RealmModel()
class _Quarter {
  @PrimaryKey()
  late int index;
  late List<_Translation> titleTranslations;
}

@RealmModel()
class _Quarter_first_verse {
  late _Quarter? quarter;
  late _Verses? firstVerse;
}

@RealmModel()
class _Reciter {
  @PrimaryKey()
  late ObjectId index;
  late List<_Translation> names;
}

@RealmModel()
class _Sura {
  @PrimaryKey()
  late int? suraNumber;
  late int verseCount;
  late String searchText;
  late String arabicName;
  late String englishName;
  late String uthmaniName;
}

@RealmModel()
class _Timing {
  @PrimaryKey()
  late int index;
  late int timeOfEnding;
  late _Track? track;
  late _Verses? verse;
}

@RealmModel()
class _Track {
  @PrimaryKey()
  late int index;
  late bool favourite;
  late bool isDownloaded;
  late _Reciter? reciter;
  late _Sura? sura;
  late String? fileURL;
  late List<_Timing> timings;
}

@RealmModel()
class _Translation {
  @PrimaryKey()
  late int index;
  @Indexed()
  late String iso;
  late String translation;
}

@RealmModel()
class _Verses {
  @PrimaryKey()
  late int index;
  late int verseNumberInSura;
  late _Sura? sura;
  late _Quarter? quarter;
  late int? pageNumber;
  late String? text;
  late String? uthmaniText;
  late String? engText;
}
