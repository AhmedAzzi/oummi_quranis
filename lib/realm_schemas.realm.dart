// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Hizb extends _Hizb with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Hizb(
    int index, {
    Iterable<Translation> titleTranslations = const [],
    Iterable<Quarter> quarters = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Hizb>({'index': 0});
    }
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set<RealmList<Translation>>(
      this,
      'titleTranslations',
      RealmList<Translation>(titleTranslations),
    );
    RealmObjectBase.set<RealmList<Quarter>>(
      this,
      'quarters',
      RealmList<Quarter>(quarters),
    );
  }

  Hizb._();

  @override
  int get index => RealmObjectBase.get<int>(this, 'index') as int;
  @override
  set index(int value) => RealmObjectBase.set(this, 'index', value);

  @override
  RealmList<Translation> get titleTranslations =>
      RealmObjectBase.get<Translation>(this, 'titleTranslations')
          as RealmList<Translation>;
  @override
  set titleTranslations(covariant RealmList<Translation> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Quarter> get quarters =>
      RealmObjectBase.get<Quarter>(this, 'quarters') as RealmList<Quarter>;
  @override
  set quarters(covariant RealmList<Quarter> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Hizb>> get changes =>
      RealmObjectBase.getChanges<Hizb>(this);

  @override
  Stream<RealmObjectChanges<Hizb>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Hizb>(this, keyPaths);

  @override
  Hizb freeze() => RealmObjectBase.freezeObject<Hizb>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'index': index.toEJson(),
      'titleTranslations': titleTranslations.toEJson(),
      'quarters': quarters.toEJson(),
    };
  }

  static EJsonValue _toEJson(Hizb value) => value.toEJson();
  static Hizb _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'index': EJsonValue index} => Hizb(
        fromEJson(ejson['index'], defaultValue: 0),
        titleTranslations: fromEJson(
          ejson['titleTranslations'],
          defaultValue: const [],
        ),
        quarters: fromEJson(ejson['quarters'], defaultValue: const []),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Hizb._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Hizb, 'Hizb', [
      SchemaProperty('index', RealmPropertyType.int, primaryKey: true),
      SchemaProperty(
        'titleTranslations',
        RealmPropertyType.object,
        linkTarget: 'Translation',
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty(
        'quarters',
        RealmPropertyType.object,
        linkTarget: 'Quarter',
        collectionType: RealmCollectionType.list,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Part extends _Part with RealmEntity, RealmObjectBase, RealmObject {
  Part(
    int index, {
    Iterable<Translation> titleTranslations = const [],
    Iterable<Hizb> hizbs = const [],
    Iterable<Quarter> quarters = const [],
  }) {
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set<RealmList<Translation>>(
      this,
      'titleTranslations',
      RealmList<Translation>(titleTranslations),
    );
    RealmObjectBase.set<RealmList<Hizb>>(this, 'hizbs', RealmList<Hizb>(hizbs));
    RealmObjectBase.set<RealmList<Quarter>>(
      this,
      'quarters',
      RealmList<Quarter>(quarters),
    );
  }

  Part._();

  @override
  int get index => RealmObjectBase.get<int>(this, 'index') as int;
  @override
  set index(int value) => RealmObjectBase.set(this, 'index', value);

  @override
  RealmList<Translation> get titleTranslations =>
      RealmObjectBase.get<Translation>(this, 'titleTranslations')
          as RealmList<Translation>;
  @override
  set titleTranslations(covariant RealmList<Translation> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Hizb> get hizbs =>
      RealmObjectBase.get<Hizb>(this, 'hizbs') as RealmList<Hizb>;
  @override
  set hizbs(covariant RealmList<Hizb> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Quarter> get quarters =>
      RealmObjectBase.get<Quarter>(this, 'quarters') as RealmList<Quarter>;
  @override
  set quarters(covariant RealmList<Quarter> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Part>> get changes =>
      RealmObjectBase.getChanges<Part>(this);

  @override
  Stream<RealmObjectChanges<Part>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Part>(this, keyPaths);

  @override
  Part freeze() => RealmObjectBase.freezeObject<Part>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'index': index.toEJson(),
      'titleTranslations': titleTranslations.toEJson(),
      'hizbs': hizbs.toEJson(),
      'quarters': quarters.toEJson(),
    };
  }

  static EJsonValue _toEJson(Part value) => value.toEJson();
  static Part _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'index': EJsonValue index} => Part(
        fromEJson(index),
        titleTranslations: fromEJson(ejson['titleTranslations']),
        hizbs: fromEJson(ejson['hizbs']),
        quarters: fromEJson(ejson['quarters']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Part._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Part, 'Part', [
      SchemaProperty('index', RealmPropertyType.int, primaryKey: true),
      SchemaProperty(
        'titleTranslations',
        RealmPropertyType.object,
        linkTarget: 'Translation',
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty(
        'hizbs',
        RealmPropertyType.object,
        linkTarget: 'Hizb',
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty(
        'quarters',
        RealmPropertyType.object,
        linkTarget: 'Quarter',
        collectionType: RealmCollectionType.list,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Quarter extends _Quarter with RealmEntity, RealmObjectBase, RealmObject {
  Quarter(int index, {Iterable<Translation> titleTranslations = const []}) {
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set<RealmList<Translation>>(
      this,
      'titleTranslations',
      RealmList<Translation>(titleTranslations),
    );
  }

  Quarter._();

  @override
  int get index => RealmObjectBase.get<int>(this, 'index') as int;
  @override
  set index(int value) => RealmObjectBase.set(this, 'index', value);

  @override
  RealmList<Translation> get titleTranslations =>
      RealmObjectBase.get<Translation>(this, 'titleTranslations')
          as RealmList<Translation>;
  @override
  set titleTranslations(covariant RealmList<Translation> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Quarter>> get changes =>
      RealmObjectBase.getChanges<Quarter>(this);

  @override
  Stream<RealmObjectChanges<Quarter>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Quarter>(this, keyPaths);

  @override
  Quarter freeze() => RealmObjectBase.freezeObject<Quarter>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'index': index.toEJson(),
      'titleTranslations': titleTranslations.toEJson(),
    };
  }

  static EJsonValue _toEJson(Quarter value) => value.toEJson();
  static Quarter _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'index': EJsonValue index} => Quarter(
        fromEJson(index),
        titleTranslations: fromEJson(ejson['titleTranslations']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Quarter._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Quarter, 'Quarter', [
      SchemaProperty('index', RealmPropertyType.int, primaryKey: true),
      SchemaProperty(
        'titleTranslations',
        RealmPropertyType.object,
        linkTarget: 'Translation',
        collectionType: RealmCollectionType.list,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Quarter_first_verse extends _Quarter_first_verse
    with RealmEntity, RealmObjectBase, RealmObject {
  Quarter_first_verse({Quarter? quarter, Verses? firstVerse}) {
    RealmObjectBase.set(this, 'quarter', quarter);
    RealmObjectBase.set(this, 'firstVerse', firstVerse);
  }

  Quarter_first_verse._();

  @override
  Quarter? get quarter =>
      RealmObjectBase.get<Quarter>(this, 'quarter') as Quarter?;
  @override
  set quarter(covariant Quarter? value) =>
      RealmObjectBase.set(this, 'quarter', value);

  @override
  Verses? get firstVerse =>
      RealmObjectBase.get<Verses>(this, 'firstVerse') as Verses?;
  @override
  set firstVerse(covariant Verses? value) =>
      RealmObjectBase.set(this, 'firstVerse', value);

  @override
  Stream<RealmObjectChanges<Quarter_first_verse>> get changes =>
      RealmObjectBase.getChanges<Quarter_first_verse>(this);

  @override
  Stream<RealmObjectChanges<Quarter_first_verse>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<Quarter_first_verse>(this, keyPaths);

  @override
  Quarter_first_verse freeze() =>
      RealmObjectBase.freezeObject<Quarter_first_verse>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'quarter': quarter.toEJson(),
      'firstVerse': firstVerse.toEJson(),
    };
  }

  static EJsonValue _toEJson(Quarter_first_verse value) => value.toEJson();
  static Quarter_first_verse _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return Quarter_first_verse(
      quarter: fromEJson(ejson['quarter']),
      firstVerse: fromEJson(ejson['firstVerse']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Quarter_first_verse._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Quarter_first_verse,
      'Quarter_first_verse',
      [
        SchemaProperty(
          'quarter',
          RealmPropertyType.object,
          optional: true,
          linkTarget: 'Quarter',
        ),
        SchemaProperty(
          'firstVerse',
          RealmPropertyType.object,
          optional: true,
          linkTarget: 'Verses',
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Reciter extends _Reciter with RealmEntity, RealmObjectBase, RealmObject {
  Reciter(ObjectId index, {Iterable<Translation> names = const []}) {
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set<RealmList<Translation>>(
      this,
      'names',
      RealmList<Translation>(names),
    );
  }

  Reciter._();

  @override
  ObjectId get index =>
      RealmObjectBase.get<ObjectId>(this, 'index') as ObjectId;
  @override
  set index(ObjectId value) => RealmObjectBase.set(this, 'index', value);

  @override
  RealmList<Translation> get names =>
      RealmObjectBase.get<Translation>(this, 'names') as RealmList<Translation>;
  @override
  set names(covariant RealmList<Translation> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Reciter>> get changes =>
      RealmObjectBase.getChanges<Reciter>(this);

  @override
  Stream<RealmObjectChanges<Reciter>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Reciter>(this, keyPaths);

  @override
  Reciter freeze() => RealmObjectBase.freezeObject<Reciter>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'index': index.toEJson(),
      'names': names.toEJson(),
    };
  }

  static EJsonValue _toEJson(Reciter value) => value.toEJson();
  static Reciter _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'index': EJsonValue index} => Reciter(
        fromEJson(index),
        names: fromEJson(ejson['names']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Reciter._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Reciter, 'Reciter', [
      SchemaProperty('index', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty(
        'names',
        RealmPropertyType.object,
        linkTarget: 'Translation',
        collectionType: RealmCollectionType.list,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Sura extends _Sura with RealmEntity, RealmObjectBase, RealmObject {
  Sura(
    int? suraNumber,
    int verseCount,
    String searchText,
    String arabicName,
    String englishName,
    String uthmaniName,
  ) {
    RealmObjectBase.set(this, 'suraNumber', suraNumber);
    RealmObjectBase.set(this, 'verseCount', verseCount);
    RealmObjectBase.set(this, 'searchText', searchText);
    RealmObjectBase.set(this, 'arabicName', arabicName);
    RealmObjectBase.set(this, 'englishName', englishName);
    RealmObjectBase.set(this, 'uthmaniName', uthmaniName);
  }

  Sura._();

  @override
  int? get suraNumber => RealmObjectBase.get<int>(this, 'suraNumber') as int?;
  @override
  set suraNumber(int? value) => RealmObjectBase.set(this, 'suraNumber', value);

  @override
  int get verseCount => RealmObjectBase.get<int>(this, 'verseCount') as int;
  @override
  set verseCount(int value) => RealmObjectBase.set(this, 'verseCount', value);

  @override
  String get searchText =>
      RealmObjectBase.get<String>(this, 'searchText') as String;
  @override
  set searchText(String value) =>
      RealmObjectBase.set(this, 'searchText', value);

  @override
  String get arabicName =>
      RealmObjectBase.get<String>(this, 'arabicName') as String;
  @override
  set arabicName(String value) =>
      RealmObjectBase.set(this, 'arabicName', value);

  @override
  String get englishName =>
      RealmObjectBase.get<String>(this, 'englishName') as String;
  @override
  set englishName(String value) =>
      RealmObjectBase.set(this, 'englishName', value);

  @override
  String get uthmaniName =>
      RealmObjectBase.get<String>(this, 'uthmaniName') as String;
  @override
  set uthmaniName(String value) =>
      RealmObjectBase.set(this, 'uthmaniName', value);

  @override
  Stream<RealmObjectChanges<Sura>> get changes =>
      RealmObjectBase.getChanges<Sura>(this);

  @override
  Stream<RealmObjectChanges<Sura>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Sura>(this, keyPaths);

  @override
  Sura freeze() => RealmObjectBase.freezeObject<Sura>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'suraNumber': suraNumber.toEJson(),
      'verseCount': verseCount.toEJson(),
      'searchText': searchText.toEJson(),
      'arabicName': arabicName.toEJson(),
      'englishName': englishName.toEJson(),
      'uthmaniName': uthmaniName.toEJson(),
    };
  }

  static EJsonValue _toEJson(Sura value) => value.toEJson();
  static Sura _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'suraNumber': EJsonValue suraNumber,
        'verseCount': EJsonValue verseCount,
        'searchText': EJsonValue searchText,
        'arabicName': EJsonValue arabicName,
        'englishName': EJsonValue englishName,
        'uthmaniName': EJsonValue uthmaniName,
      } =>
        Sura(
          fromEJson(ejson['suraNumber']),
          fromEJson(verseCount),
          fromEJson(searchText),
          fromEJson(arabicName),
          fromEJson(englishName),
          fromEJson(uthmaniName),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Sura._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Sura, 'Sura', [
      SchemaProperty(
        'suraNumber',
        RealmPropertyType.int,
        optional: true,
        primaryKey: true,
      ),
      SchemaProperty('verseCount', RealmPropertyType.int),
      SchemaProperty('searchText', RealmPropertyType.string),
      SchemaProperty('arabicName', RealmPropertyType.string),
      SchemaProperty('englishName', RealmPropertyType.string),
      SchemaProperty('uthmaniName', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Timing extends _Timing with RealmEntity, RealmObjectBase, RealmObject {
  Timing(int index, int timeOfEnding, {Track? track, Verses? verse}) {
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'timeOfEnding', timeOfEnding);
    RealmObjectBase.set(this, 'track', track);
    RealmObjectBase.set(this, 'verse', verse);
  }

  Timing._();

  @override
  int get index => RealmObjectBase.get<int>(this, 'index') as int;
  @override
  set index(int value) => RealmObjectBase.set(this, 'index', value);

  @override
  int get timeOfEnding => RealmObjectBase.get<int>(this, 'timeOfEnding') as int;
  @override
  set timeOfEnding(int value) =>
      RealmObjectBase.set(this, 'timeOfEnding', value);

  @override
  Track? get track => RealmObjectBase.get<Track>(this, 'track') as Track?;
  @override
  set track(covariant Track? value) =>
      RealmObjectBase.set(this, 'track', value);

  @override
  Verses? get verse => RealmObjectBase.get<Verses>(this, 'verse') as Verses?;
  @override
  set verse(covariant Verses? value) =>
      RealmObjectBase.set(this, 'verse', value);

  @override
  Stream<RealmObjectChanges<Timing>> get changes =>
      RealmObjectBase.getChanges<Timing>(this);

  @override
  Stream<RealmObjectChanges<Timing>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Timing>(this, keyPaths);

  @override
  Timing freeze() => RealmObjectBase.freezeObject<Timing>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'index': index.toEJson(),
      'timeOfEnding': timeOfEnding.toEJson(),
      'track': track.toEJson(),
      'verse': verse.toEJson(),
    };
  }

  static EJsonValue _toEJson(Timing value) => value.toEJson();
  static Timing _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'index': EJsonValue index, 'timeOfEnding': EJsonValue timeOfEnding} =>
        Timing(
          fromEJson(index),
          fromEJson(timeOfEnding),
          track: fromEJson(ejson['track']),
          verse: fromEJson(ejson['verse']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Timing._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Timing, 'Timing', [
      SchemaProperty('index', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('timeOfEnding', RealmPropertyType.int),
      SchemaProperty(
        'track',
        RealmPropertyType.object,
        optional: true,
        linkTarget: 'Track',
      ),
      SchemaProperty(
        'verse',
        RealmPropertyType.object,
        optional: true,
        linkTarget: 'Verses',
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Track extends _Track with RealmEntity, RealmObjectBase, RealmObject {
  Track(
    int index,
    bool favourite,
    bool isDownloaded, {
    Reciter? reciter,
    Sura? sura,
    String? fileURL,
    Iterable<Timing> timings = const [],
  }) {
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'favourite', favourite);
    RealmObjectBase.set(this, 'isDownloaded', isDownloaded);
    RealmObjectBase.set(this, 'reciter', reciter);
    RealmObjectBase.set(this, 'sura', sura);
    RealmObjectBase.set(this, 'fileURL', fileURL);
    RealmObjectBase.set<RealmList<Timing>>(
      this,
      'timings',
      RealmList<Timing>(timings),
    );
  }

  Track._();

  @override
  int get index => RealmObjectBase.get<int>(this, 'index') as int;
  @override
  set index(int value) => RealmObjectBase.set(this, 'index', value);

  @override
  bool get favourite => RealmObjectBase.get<bool>(this, 'favourite') as bool;
  @override
  set favourite(bool value) => RealmObjectBase.set(this, 'favourite', value);

  @override
  bool get isDownloaded =>
      RealmObjectBase.get<bool>(this, 'isDownloaded') as bool;
  @override
  set isDownloaded(bool value) =>
      RealmObjectBase.set(this, 'isDownloaded', value);

  @override
  Reciter? get reciter =>
      RealmObjectBase.get<Reciter>(this, 'reciter') as Reciter?;
  @override
  set reciter(covariant Reciter? value) =>
      RealmObjectBase.set(this, 'reciter', value);

  @override
  Sura? get sura => RealmObjectBase.get<Sura>(this, 'sura') as Sura?;
  @override
  set sura(covariant Sura? value) => RealmObjectBase.set(this, 'sura', value);

  @override
  String? get fileURL =>
      RealmObjectBase.get<String>(this, 'fileURL') as String?;
  @override
  set fileURL(String? value) => RealmObjectBase.set(this, 'fileURL', value);

  @override
  RealmList<Timing> get timings =>
      RealmObjectBase.get<Timing>(this, 'timings') as RealmList<Timing>;
  @override
  set timings(covariant RealmList<Timing> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Track>> get changes =>
      RealmObjectBase.getChanges<Track>(this);

  @override
  Stream<RealmObjectChanges<Track>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Track>(this, keyPaths);

  @override
  Track freeze() => RealmObjectBase.freezeObject<Track>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'index': index.toEJson(),
      'favourite': favourite.toEJson(),
      'isDownloaded': isDownloaded.toEJson(),
      'reciter': reciter.toEJson(),
      'sura': sura.toEJson(),
      'fileURL': fileURL.toEJson(),
      'timings': timings.toEJson(),
    };
  }

  static EJsonValue _toEJson(Track value) => value.toEJson();
  static Track _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'index': EJsonValue index,
        'favourite': EJsonValue favourite,
        'isDownloaded': EJsonValue isDownloaded,
      } =>
        Track(
          fromEJson(index),
          fromEJson(favourite),
          fromEJson(isDownloaded),
          reciter: fromEJson(ejson['reciter']),
          sura: fromEJson(ejson['sura']),
          fileURL: fromEJson(ejson['fileURL']),
          timings: fromEJson(ejson['timings']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Track._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Track, 'Track', [
      SchemaProperty('index', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('favourite', RealmPropertyType.bool),
      SchemaProperty('isDownloaded', RealmPropertyType.bool),
      SchemaProperty(
        'reciter',
        RealmPropertyType.object,
        optional: true,
        linkTarget: 'Reciter',
      ),
      SchemaProperty(
        'sura',
        RealmPropertyType.object,
        optional: true,
        linkTarget: 'Sura',
      ),
      SchemaProperty('fileURL', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'timings',
        RealmPropertyType.object,
        linkTarget: 'Timing',
        collectionType: RealmCollectionType.list,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Translation extends _Translation
    with RealmEntity, RealmObjectBase, RealmObject {
  Translation(int index, String iso, String translation) {
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'iso', iso);
    RealmObjectBase.set(this, 'translation', translation);
  }

  Translation._();

  @override
  int get index => RealmObjectBase.get<int>(this, 'index') as int;
  @override
  set index(int value) => RealmObjectBase.set(this, 'index', value);

  @override
  String get iso => RealmObjectBase.get<String>(this, 'iso') as String;
  @override
  set iso(String value) => RealmObjectBase.set(this, 'iso', value);

  @override
  String get translation =>
      RealmObjectBase.get<String>(this, 'translation') as String;
  @override
  set translation(String value) =>
      RealmObjectBase.set(this, 'translation', value);

  @override
  Stream<RealmObjectChanges<Translation>> get changes =>
      RealmObjectBase.getChanges<Translation>(this);

  @override
  Stream<RealmObjectChanges<Translation>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<Translation>(this, keyPaths);

  @override
  Translation freeze() => RealmObjectBase.freezeObject<Translation>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'index': index.toEJson(),
      'iso': iso.toEJson(),
      'translation': translation.toEJson(),
    };
  }

  static EJsonValue _toEJson(Translation value) => value.toEJson();
  static Translation _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'index': EJsonValue index,
        'iso': EJsonValue iso,
        'translation': EJsonValue translation,
      } =>
        Translation(fromEJson(index), fromEJson(iso), fromEJson(translation)),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Translation._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Translation,
      'Translation',
      [
        SchemaProperty('index', RealmPropertyType.int, primaryKey: true),
        SchemaProperty(
          'iso',
          RealmPropertyType.string,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('translation', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Verses extends _Verses with RealmEntity, RealmObjectBase, RealmObject {
  Verses(
    int index,
    int verseNumberInSura, {
    Sura? sura,
    Quarter? quarter,
    int? pageNumber,
    String? text,
    String? uthmaniText,
    String? engText,
  }) {
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'verseNumberInSura', verseNumberInSura);
    RealmObjectBase.set(this, 'sura', sura);
    RealmObjectBase.set(this, 'quarter', quarter);
    RealmObjectBase.set(this, 'pageNumber', pageNumber);
    RealmObjectBase.set(this, 'text', text);
    RealmObjectBase.set(this, 'uthmaniText', uthmaniText);
    RealmObjectBase.set(this, 'engText', engText);
  }

  Verses._();

  @override
  int get index => RealmObjectBase.get<int>(this, 'index') as int;
  @override
  set index(int value) => RealmObjectBase.set(this, 'index', value);

  @override
  int get verseNumberInSura =>
      RealmObjectBase.get<int>(this, 'verseNumberInSura') as int;
  @override
  set verseNumberInSura(int value) =>
      RealmObjectBase.set(this, 'verseNumberInSura', value);

  @override
  Sura? get sura => RealmObjectBase.get<Sura>(this, 'sura') as Sura?;
  @override
  set sura(covariant Sura? value) => RealmObjectBase.set(this, 'sura', value);

  @override
  Quarter? get quarter =>
      RealmObjectBase.get<Quarter>(this, 'quarter') as Quarter?;
  @override
  set quarter(covariant Quarter? value) =>
      RealmObjectBase.set(this, 'quarter', value);

  @override
  int? get pageNumber => RealmObjectBase.get<int>(this, 'pageNumber') as int?;
  @override
  set pageNumber(int? value) => RealmObjectBase.set(this, 'pageNumber', value);

  @override
  String? get text => RealmObjectBase.get<String>(this, 'text') as String?;
  @override
  set text(String? value) => RealmObjectBase.set(this, 'text', value);

  @override
  String? get uthmaniText =>
      RealmObjectBase.get<String>(this, 'uthmaniText') as String?;
  @override
  set uthmaniText(String? value) =>
      RealmObjectBase.set(this, 'uthmaniText', value);

  @override
  String? get engText =>
      RealmObjectBase.get<String>(this, 'engText') as String?;
  @override
  set engText(String? value) => RealmObjectBase.set(this, 'engText', value);

  @override
  Stream<RealmObjectChanges<Verses>> get changes =>
      RealmObjectBase.getChanges<Verses>(this);

  @override
  Stream<RealmObjectChanges<Verses>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Verses>(this, keyPaths);

  @override
  Verses freeze() => RealmObjectBase.freezeObject<Verses>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'index': index.toEJson(),
      'verseNumberInSura': verseNumberInSura.toEJson(),
      'sura': sura.toEJson(),
      'quarter': quarter.toEJson(),
      'pageNumber': pageNumber.toEJson(),
      'text': text.toEJson(),
      'uthmaniText': uthmaniText.toEJson(),
      'engText': engText.toEJson(),
    };
  }

  static EJsonValue _toEJson(Verses value) => value.toEJson();
  static Verses _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'index': EJsonValue index,
        'verseNumberInSura': EJsonValue verseNumberInSura,
      } =>
        Verses(
          fromEJson(index),
          fromEJson(verseNumberInSura),
          sura: fromEJson(ejson['sura']),
          quarter: fromEJson(ejson['quarter']),
          pageNumber: fromEJson(ejson['pageNumber']),
          text: fromEJson(ejson['text']),
          uthmaniText: fromEJson(ejson['uthmaniText']),
          engText: fromEJson(ejson['engText']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Verses._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Verses, 'Verses', [
      SchemaProperty('index', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('verseNumberInSura', RealmPropertyType.int),
      SchemaProperty(
        'sura',
        RealmPropertyType.object,
        optional: true,
        linkTarget: 'Sura',
      ),
      SchemaProperty(
        'quarter',
        RealmPropertyType.object,
        optional: true,
        linkTarget: 'Quarter',
      ),
      SchemaProperty('pageNumber', RealmPropertyType.int, optional: true),
      SchemaProperty('text', RealmPropertyType.string, optional: true),
      SchemaProperty('uthmaniText', RealmPropertyType.string, optional: true),
      SchemaProperty('engText', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
