import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import 'realm_schemas.dart';

class RealmService {
  late Realm realm;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'theReciter.realm');

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load('assets/theReciter.realm');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes);
    }

    final config = Configuration.local(
      [
        Hizb.schema,
        Part.schema,
        Quarter.schema,
        Quarter_first_verse.schema,
        Reciter.schema,
        Sura.schema,
        Timing.schema,
        Track.schema,
        Translation.schema,
        Verses.schema,
      ],
      path: path,
      isReadOnly: true,
      schemaVersion: 1,
    );

    realm = Realm(config);
  }

  List<Sura> getAllSurahs() {
    return realm.all<Sura>().toList()
      ..sort((a, b) => (a.suraNumber ?? 0).compareTo(b.suraNumber ?? 0));
  }

  Sura? getSuraByNumber(int suraNumber) {
    final suras = realm.all<Sura>().query('suraNumber == \$0', [suraNumber]);
    return suras.isNotEmpty ? suras.first : null;
  }

  Track? getTrackForSura(int suraNumber) {
    final tracks = realm.all<Track>().query('sura.suraNumber == \$0', [
      suraNumber,
    ]);
    return tracks.isNotEmpty ? tracks.first : null;
  }

  List<Verses> getVersesForSura(int suraNumber) {
    return realm.all<Verses>().query('sura.suraNumber == \$0', [
        suraNumber,
      ]).toList()
      ..sort((a, b) => a.verseNumberInSura.compareTo(b.verseNumberInSura));
  }

  List<Timing> getTimingsForTrack(int trackIndex) {
    return realm.all<Timing>().query('track.index == \$0', [
      trackIndex,
    ]).toList()..sort((a, b) => a.timeOfEnding.compareTo(b.timeOfEnding));
  }
}
