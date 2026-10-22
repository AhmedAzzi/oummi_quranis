import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saad_el_ghamidy/audio_player_service.dart';
import 'package:saad_el_ghamidy/app_settings.dart';
import 'package:saad_el_ghamidy/realm_service.dart';
import 'package:saad_el_ghamidy/realm_schemas.dart';
import 'package:saad_el_ghamidy/settings_screen.dart';
import 'package:saad_el_ghamidy/part_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const Color kPrimaryBrown = Color(0xFF5D4037);
const Color kLightBeige = Color(0xFFFFFDE7);
const Color kGold = Color(0xFFD4AF37);

// Meccan (مكية) = true, Medinan (مدنية) = false
const Map<int, bool> _surahType = {
  1: true,
  2: false,
  3: false,
  4: false,
  5: false,
  6: true,
  7: true,
  8: false,
  9: false,
  10: true,
  11: true,
  12: true,
  13: false,
  14: true,
  15: true,
  16: true,
  17: true,
  18: true,
  19: true,
  20: true,
  21: true,
  22: false,
  23: true,
  24: false,
  25: true,
  26: true,
  27: true,
  28: true,
  29: true,
  30: true,
  31: true,
  32: true,
  33: false,
  34: true,
  35: true,
  36: true,
  37: true,
  38: true,
  39: true,
  40: true,
  41: true,
  42: true,
  43: true,
  44: true,
  45: true,
  46: true,
  47: false,
  48: false,
  49: false,
  50: true,
  51: true,
  52: true,
  53: true,
  54: true,
  55: false,
  56: true,
  57: false,
  58: false,
  59: false,
  60: false,
  61: false,
  62: false,
  63: false,
  64: false,
  65: false,
  66: false,
  67: true,
  68: true,
  69: true,
  70: true,
  71: true,
  72: true,
  73: true,
  74: true,
  75: true,
  76: false,
  77: true,
  78: true,
  79: true,
  80: true,
  81: true,
  82: true,
  83: true,
  84: true,
  85: true,
  86: true,
  87: true,
  88: true,
  89: true,
  90: true,
  91: true,
  92: true,
  93: true,
  94: true,
  95: true,
  96: true,
  97: true,
  98: false,
  99: true,
  100: true,
  101: true,
  102: true,
  103: true,
  104: true,
  105: true,
  106: true,
  107: true,
  108: true,
  109: true,
  110: false,
  111: true,
  112: true,
  113: true,
  114: true,
};

String _getSurahTypeLabel(int surahNumber) {
  final isMeccan = _surahType[surahNumber] ?? true;
  return isMeccan ? 'مكية' : 'مدنية';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Background Audio Service
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.saidelghamidy.channel.audio',
      androidNotificationChannelName: 'Quran Audio',
      androidNotificationOngoing: true,
    ),
  );

  final realmService = RealmService();
  await realmService.init();

  // Apply the saved playback speed (default 1.7x) so it survives restarts.
  try {
    await audioHandler.setSpeed(await AppSettings.getSpeed());
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        Provider<RealmService>.value(value: realmService),
        Provider<AudioPlayerHandler>.value(value: audioHandler),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'هدية لأمي القرآنية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kLightBeige,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryBrown,
          primary: kPrimaryBrown,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Amiri'),
          bodyLarge: TextStyle(fontFamily: 'Amiri'),
          bodySmall: TextStyle(fontFamily: 'Amiri'),
          titleMedium: TextStyle(fontFamily: 'Amiri'),
          titleLarge: TextStyle(fontFamily: 'Amiri'),
          titleSmall: TextStyle(fontFamily: 'Amiri'),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: kPrimaryBrown,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const SurahListScreen(),
    );
  }
}

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  int? lastSuraNumber;
  int? lastVerseIndex;
  // Guards player navigation: a rapid double-tap used to push two player
  // routes, whose concurrent loads fought over the shared audio player and
  // clobbered the highlight.
  bool _openingPlayer = false;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  /// Opens the player once; extra taps while navigating are ignored.
  /// [initialVerseIndex] resumes a surah where it was left off (may be null).
  void _openPlayer(Sura surah, {int? initialVerseIndex}) {
    if (_openingPlayer) return;
    _openingPlayer = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahPlayerScreen(
          surah: surah,
          initialVerseIndex: initialVerseIndex,
        ),
      ),
    ).then((_) {
      _openingPlayer = false;
      _loadLastRead();
    });
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final sura = prefs.getInt('last_sura');
    var verse = prefs.getInt('last_verse');
    // Sanitize stale resume data: a negative verse index once crashed
    // resume with `RangeError ... -1`, and an orphan verse without its
    // surah can never be valid.
    if (verse != null && verse < 0) {
      await prefs.remove('last_verse');
      verse = null;
    }
    if (sura == null && verse != null) {
      await prefs.remove('last_verse');
      verse = null;
    }
    setState(() {
      lastSuraNumber = sura;
      lastVerseIndex = verse;
    });
  }

  @override
  Widget build(BuildContext context) {
    final realmService = Provider.of<RealmService>(context, listen: false);
    final surahs = realmService.getAllSurahs();

    final filteredSurahs = surahs.where((s) {
      return s.arabicName.contains(searchQuery) ||
          s.suraNumber.toString().contains(searchQuery);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: kPrimaryBrown,
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white70,
                          ),
                          tooltip: 'الإعدادات',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'هدية لأمي القرآنية',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Balances the IconButton so the title stays centered.
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'رزقك الله حفظ القرآن وتلاوته آناء الليل وآناء النهار',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            if (lastSuraNumber != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kPrimaryBrown,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: Colors.white70,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'تابع القراءة',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        Text(
                          realmService
                                  .getSuraByNumber(lastSuraNumber!)
                                  ?.arabicName ??
                              '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'الآية ${lastVerseIndex ?? 0}',
                          style: const TextStyle(color: kGold, fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            final sura = realmService.getSuraByNumber(
                              lastSuraNumber!,
                            );
                            if (sura != null) {
                              _openPlayer(
                                sura,
                                initialVerseIndex: lastVerseIndex,
                              );
                            }
                          },
                          icon: const Icon(Icons.play_circle_fill),
                          label: const Text(
                            'استئناف',
                            style: TextStyle(fontSize: 20),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: kPrimaryBrown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => searchQuery = value),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Amiri',
                      fontSize: 18,
                    ),
                    cursorColor: kGold,
                    decoration: InputDecoration(
                      hintText: 'البحث عن سورة...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      hintTextDirection: TextDirection.rtl,
                      suffixIcon: const Icon(Icons.search, color: kGold),
                      filled: true,
                      fillColor: kPrimaryBrown,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final surah = filteredSurahs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 3,
                  ),
                  child: Card(
                    color: kPrimaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child: ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      onTap: () => _openPlayer(surah),
                      leading: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9EC),
                          shape: BoxShape.circle,
                          border: Border.all(color: kGold.withValues(alpha: 0.5)),
                        ),
                        child: Center(
                          child: Text(
                            '${surah.suraNumber}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kPrimaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        surah.arabicName,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'آية ${surah.verseCount} • ${_getSurahTypeLabel(surah.suraNumber ?? 0)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: filteredSurahs.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }
}

class SurahPlayerScreen extends StatefulWidget {
  final Sura surah;
  final int? initialVerseIndex;

  const SurahPlayerScreen({
    super.key,
    required this.surah,
    this.initialVerseIndex,
  });

  @override
  State<SurahPlayerScreen> createState() => _SurahPlayerScreenState();
}

class _SurahPlayerScreenState extends State<SurahPlayerScreen> {
  /// Bumped by every player screen: only the latest generation may drive the
  /// shared audio player. Older (e.g. double-pushed) screens go fully inert
  /// instead of fighting over playback and clobbering the highlight.
  static int _playerGeneration = 0;
  late final int _myGeneration;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  List<Verses> _verses = [];
  List<Timing> _timings = [];
  bool _loaded = false;
  final ValueNotifier<int> _currentVerseIndex = ValueNotifier<int>(-1);
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _autoPlayNext = true;
  bool _isGoingToNext = false;
  bool _hasStartedPlaying = false;
  // Ayah loop state: [_loopVerse] is the verse being counted, [_loopProgress]
  // holds how many times it has played (0 hides the badge).
  int _ayahRepeatTotal = 1;
  int _loopVerse = -1;
  final ValueNotifier<int> _loopProgress = ValueNotifier<int>(0);
  // Surah loop state: replay the whole surah [_surahRepeatTotal] times.
  int _surahRepeatTotal = 1;
  int _surahDone = 1;
  // Segment loop state: replay the chosen part [_segmentRepeatTotal] times.
  int _segmentRepeatTotal = 1;
  int _segmentDone = 1;
  // Set by manual seeks (tap / progress / ±5s / skip) so the resulting
  // position jump is never mistaken for a natural verse completion.
  bool _suppressLoopOnce = false;
  // Guards position ticks arriving between a loop-back seek and its landing.
  bool _inLoopBack = false;
  // Last position seen by the highlight tracker, used to reject wild
  // backward jumps (stale ticks). Updated on every tick, even rejected ones,
  // so a sustained new position (e.g. notification seek) is accepted on the
  // very next tick.
  Duration _lastHighlightPosition = Duration.zero;
  bool _hasHighlightPosition = false;
  // Backward hysteresis window: passive ticks landing this close before the
  // current verse's start are pause-time staleness, not a real verse change.
  static const int _kBackwardHysteresisMs = 1500;
  // Highest verse number in this surah (AppBar subtitle). Computed from
  // the loaded verses so DB numbering quirks stay correct.
  int _ayahTotal = 0;
  // Custom part (single-surah range) state: null = whole surah.
  int? _rangeStart;
  int? _rangeEnd;
  String? _rangeLabel;
  bool get _hasRange =>
      _rangeStart != null &&
      _rangeEnd != null &&
      _timings.isNotEmpty &&
      _verses.isNotEmpty;
  int _rangeStartMs() {
    if (!_hasRange || _rangeStart! <= 0) return 0;
    if (_rangeStart! - 1 >= _timings.length) return 0;
    return _timings[_rangeStart! - 1].timeOfEnding;
  }

  int _rangeEndMs() {
    if (!_hasRange) return -1;
    final re = _rangeEnd!.clamp(0, _timings.length - 1);
    return _timings[re].timeOfEnding;
  }

  int _effectiveEndIndex() {
    if (_timings.isEmpty) return -1;
    if (_hasRange) return _rangeEnd!.clamp(0, _timings.length - 1);
    return _timings.length - 1;
  }

  Duration _clampToRange(Duration target) {
    if (!_hasRange) return target;
    final startMs = _rangeStartMs();
    final endMs = _rangeEndMs();
    if (target.inMilliseconds < startMs) {
      return Duration(milliseconds: startMs);
    }
    if (target.inMilliseconds > endMs) {
      return Duration(milliseconds: endMs);
    }
    return target;
  }

  void _applyRange(VerseRangeSelection sel) {
    if (_timings.isEmpty || _verses.isEmpty) return;
    final maxIdx =
        (_verses.length < _timings.length ? _verses.length : _timings.length) -
        1;
    if (maxIdx < 0) return;
    var s = sel.startIndex.clamp(0, maxIdx);
    var e = sel.endIndex.clamp(0, maxIdx);
    if (s > e) {
      final t = s;
      s = e;
      e = t;
    }
    setState(() {
      _rangeStart = s;
      _rangeEnd = e;
      _rangeLabel = sel.label;
    });
    _segmentDone = 1;
    _suppressLoopOnce = true;
    _inLoopBack = false;
    final startMs = s == 0 ? 0 : _timings[s - 1].timeOfEnding;
    final audioService = Provider.of<AudioPlayerHandler>(
      context,
      listen: false,
    );
    final target = Duration(milliseconds: startMs);
    audioService.seek(target);
    _forceUpdateHighlight(target);
    try {
      audioService.play();
    } catch (_) {}
  }

  void _clearRange() {
    if (!_hasRange) return;
    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
      _rangeLabel = null;
    });
    _segmentDone = 1;
  }

  /// Restarts the chosen part from its first verse (segment repeat).
  /// Callers bump [_segmentDone] first.
  Future<void> _replaySegment(
    AudioPlayerHandler audioService, {
    bool ensurePlaying = false,
  }) async {
    if (!_hasRange) return;
    final rs = _rangeStart!.clamp(0, _verses.length - 1);
    _loopVerse = rs;
    _loopProgress.value = _ayahRepeatTotal > 1 ? 1 : 0;
    _suppressLoopOnce = false;
    _inLoopBack = true;
    _currentVerseIndex.value = rs;
    _scrollToVerse(rs);
    _saveProgress(rs);
    final startMs =
        rs == 0 || rs - 1 >= _timings.length ? 0 : _timings[rs - 1].timeOfEnding;
    try {
      await audioService.seek(Duration(milliseconds: startMs));
      if (ensurePlaying) await audioService.play();
    } catch (_) {}
  }

  Future<void> _openPartPicker() async {
    final sel = await showPartPicker(
      context: context,
      surah: widget.surah,
      verses: _verses,
      currentStart: _rangeStart,
      currentEnd: _rangeEnd,
    );
    if (sel == null || !mounted) return;
    _applyRange(sel);
  }

  @override
  void initState() {
    super.initState();
    _myGeneration = ++_playerGeneration;
    _initialize();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _currentVerseIndex.dispose();
    _loopProgress.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final realmService = Provider.of<RealmService>(context, listen: false);
    _autoPlayNext = await AppSettings.getAutoPlayNext();
    _ayahRepeatTotal = await AppSettings.getAyahRepeat();
    _surahRepeatTotal = await AppSettings.getSurahRepeat();
    _segmentRepeatTotal = await AppSettings.getSegmentRepeat();
    final verses = realmService.getVersesForSura(widget.surah.suraNumber!);
    final track = realmService.getTrackForSura(widget.surah.suraNumber!);
    List<Timing> timings = [];
    if (track != null) {
      timings = realmService.getTimingsForTrack(track.index);
    }
    _ayahTotal = verses.isEmpty
        ? (widget.surah.verseCount)
        : verses
            .map((v) => v.verseNumberInSura)
            .reduce((a, b) => a > b ? a : b);

    setState(() {
      _verses = verses;
      _timings = timings;
      _loaded = true;
    });

    if (!mounted) return;

    // Pre-warm the part-picker cache off the tap path (idle, after load)
    // so the tune button opens instantly instead of preparing on tap.
    unawaited(
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        warmPartPickerCache(
          suraNumber: widget.surah.suraNumber ?? 0,
          verses: _verses,
        );
      }),
    );

    // Setup listener BEFORE playing so we catch the very first position events
    _setupPositionListener();

    if (widget.initialVerseIndex != null) {
      final resumeIndex = widget.initialVerseIndex!;
      // Validate resume index from disk: it may be stale (e.g. saved before
      // a data update) or out of range for this surah. An invalid index here
      // used to crash with `RangeError ... -1` via scrollTo / timings[].
      if (resumeIndex >= 0 && resumeIndex < _verses.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _currentVerseIndex.value = resumeIndex;
          _loopVerse = resumeIndex;
          _loopProgress.value = _ayahRepeatTotal > 1 ? 1 : 0;
          _scrollToVerse(resumeIndex);
        });
      }
    }

    await _loadAndPlay(timings);
  }

  void _setupPositionListener() {
    final audioService = Provider.of<AudioPlayerHandler>(
      context,
      listen: false,
    );

    // Listen to position updates.
    // Only `ready` state drives highlighting: this ignores position resets
    // emitted after stop() (idle) or while loading/buffering, so pausing or
    // finishing a surah never snaps the highlight back to the first verse.
    _positionSubscription = audioService.positionStream.listen((position) {
      _updateCurrentVerse(position);
    });

    // Also listen to player state changes (e.g., when it starts playing)
    // to ensure highlighting is correct as soon as the player is ready.
    _playerStateSubscription = audioService.player.playerStateStream.listen((
      state,
    ) async {
      if (!mounted) return;
      if (state.playing) {
        _hasStartedPlaying = true;
        if (state.processingState == ProcessingState.ready) {
          _updateCurrentVerse(audioService.player.position);
        }
      }
      if (state.processingState == ProcessingState.completed) {
        if (_isGoingToNext) return;
        // A newer player screen owns the shared player now.
        if (_myGeneration != _playerGeneration) return;
        // Ignore stale completed events from the previous surah:
        // only auto-advance after THIS surah has actually started playing.
        if (!_hasStartedPlaying) return;
        _ayahRepeatTotal = await AppSettings.getAyahRepeat();
        _surahRepeatTotal = await AppSettings.getSurahRepeat();
        _autoPlayNext = await AppSettings.getAutoPlayNext();
        if (!mounted) return;
        // Keep the loop badge consistent when the repeat count changed mid-play.
        if (_ayahRepeatTotal > 1 &&
            _loopVerse >= 0 &&
            _loopProgress.value == 0) {
          _loopProgress.value = 1;
        } else if (_ayahRepeatTotal <= 1 && _loopProgress.value != 0) {
          _loopProgress.value = 0;
        }
        // 1) Ayah loop also covers the final verse: repeat it N times.
        // In range mode the "final" verse is the end of the chosen part.
        if (_timings.isNotEmpty &&
            _verses.isNotEmpty &&
            _ayahRepeatTotal > 1 &&
            _loopVerse == _effectiveEndIndex() &&
            _loopVerse < _verses.length &&
            _loopProgress.value >= 1 &&
            _loopProgress.value < _ayahRepeatTotal) {
          _loopProgress.value++;
          _suppressLoopOnce = false;
          _inLoopBack = false;
          final startMs = _timings.length == 1
              ? 0
              : _timings[_timings.length - 2].timeOfEnding;
          try {
            await audioService.seek(Duration(milliseconds: startMs));
            await audioService.play();
          } catch (_) {}
          return;
        }
        // 2) Surah loop: replay the whole surah N times, then fall through
        // to the auto-next setting below. Disabled in range mode (the
        // segment loop below handles repetition there instead).
        if (!_hasRange && _surahDone < _surahRepeatTotal) {
          _surahDone++;
          _loopVerse = 0;
          _loopProgress.value = _ayahRepeatTotal > 1 ? 1 : 0;
          _suppressLoopOnce = false;
          _inLoopBack = false;
          _currentVerseIndex.value = 0;
          _scrollToVerse(0);
          _saveProgress(0);
          try {
            await audioService.seek(Duration.zero);
            await audioService.play();
          } catch (_) {}
          return;
        }
        if (_autoPlayNext && !_hasRange) {
          _isGoingToNext = true;
          await _goToNextSurah();
          return;
        }
        // 3) Segment loop (range mode): replay the chosen part N times
        // from its start, then fall through to stop below.
        if (_hasRange && _segmentDone < _segmentRepeatTotal) {
          _segmentDone++;
          await _replaySegment(audioService, ensurePlaying: true);
          return;
        }
        // We no longer clear progress or reset highlights here
        // so that the last verse remains saved and highlighted.
        await audioService.stop();
      }
    });
  }

  Future<void> _reloadSettings() async {
    final autoNext = await AppSettings.getAutoPlayNext();
    final ayahRepeat = await AppSettings.getAyahRepeat();
    final surahRepeat = await AppSettings.getSurahRepeat();
    final segmentRepeat = await AppSettings.getSegmentRepeat();
    if (!mounted) return;
    setState(() {
      _autoPlayNext = autoNext;
      _ayahRepeatTotal = ayahRepeat;
      _surahRepeatTotal = surahRepeat;
      _segmentRepeatTotal = segmentRepeat;
    });
    // Keep the loop badge consistent when the repeat count changed mid-play.
    if (ayahRepeat > 1 && _loopVerse >= 0 && _loopProgress.value == 0) {
      _loopProgress.value = 1;
    } else if (ayahRepeat <= 1 && _loopProgress.value != 0) {
      _loopProgress.value = 0;
    }
  }

  Future<void> _goToNextSurah() async {
    final realmService = Provider.of<RealmService>(context, listen: false);
    final audioService = Provider.of<AudioPlayerHandler>(
      context,
      listen: false,
    );
    final currentNumber = widget.surah.suraNumber ?? 0;

    if (currentNumber >= 114) {
      _isGoingToNext = false;
      try {
        await audioService.stop();
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إتمام جميع السور')));
      }
      return;
    }

    final nextSura = realmService.getSuraByNumber(currentNumber + 1);
    if (nextSura == null) {
      _isGoingToNext = false;
      return;
    }

    // Reset the shared player BEFORE navigating so the next screen
    // doesn't see a stale `completed` state and skip straight through
    // all remaining suwar to An-Nas.
    try {
      await audioService.stop();
    } catch (_) {}
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SurahPlayerScreen(surah: nextSura),
      ),
    );
  }

  Future<void> _loadAndPlay(List<Timing> timings) async {
    final realmService = Provider.of<RealmService>(context, listen: false);
    final audioService = Provider.of<AudioPlayerHandler>(
      context,
      listen: false,
    );

    final suraNumber = widget.surah.suraNumber!;
    final assetPath =
        'assets/audios/${suraNumber.toString().padLeft(3, '0')}.aac';

    Duration? initialPosition;
    if (widget.initialVerseIndex != null &&
        widget.initialVerseIndex! >= 0 &&
        timings.isNotEmpty &&
        widget.initialVerseIndex! < timings.length) {
      final startTimeMs = widget.initialVerseIndex! == 0
          ? 0
          : timings[widget.initialVerseIndex! - 1].timeOfEnding;
      initialPosition = Duration(milliseconds: startTimeMs);
    }

    // A newer player screen took over: don't touch the shared player.
    if (_myGeneration != _playerGeneration) return;

    try {
      await rootBundle.load(assetPath);
      await audioService.playTrack(
        assetPath,
        isAsset: true,
        initialPosition: initialPosition,
        surahName: widget.surah.arabicName,
        timings: timings.map((t) => t.timeOfEnding).toList(),
      );
    } catch (e) {
      final track = realmService.getTrackForSura(suraNumber);
      if (track != null && track.fileURL != null) {
        await audioService.playTrack(
          track.fileURL,
          initialPosition: initialPosition,
          surahName: widget.surah.arabicName,
          timings: timings.map((t) => t.timeOfEnding).toList(),
        );
      }
    }

    // Initial highlight: only force it if position ticks haven't set one
    // yet, and derive it from the LIVE player position. A late-draining
    // load (its awaits resolving seconds later, e.g. released by a pause)
    // must never clobber live state with the stale initial position —
    // that snapped mid-surah highlights back to verse 0.
    if (mounted &&
        _myGeneration == _playerGeneration &&
        _currentVerseIndex.value == -1) {
      _forceUpdateHighlight(audioService.player.position);
    }
  }

  Future<void> _saveProgress(int verseIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_sura', widget.surah.suraNumber!);
    await prefs.setInt('last_verse', verseIndex);
  }

  void _updateCurrentVerse(Duration position) {
    if (!mounted || _timings.isEmpty) return;
    // A newer player screen took over: stay fully inert so a buried
    // duplicate never seeks, saves, loops, or highlights.
    if (_myGeneration != _playerGeneration) return;

    final audioService = Provider.of<AudioPlayerHandler>(
      context,
      listen: false,
    );
    // Freeze highlighting unless the player is actively ready.
    // - completed/idle (after stop): keep last verse highlighted
    // - loading/buffering (track switch): keep previous highlight
    if (audioService.player.processingState != ProcessingState.ready) {
      return;
    }

    // Freeze the highlight while paused: pausing can emit a stale/reset
    // position tick that would wrongly snap the highlight to the first
    // verse. Manual seeks bypass this via _forceUpdateHighlight, and
    // playback ticks resume driving the highlight as soon as play resumes.
    if (!audioService.player.playing) {
      return;
    }

    int newIndex = -1;

    // Add a small positive offset to trigger the highlight slightly earlier/faster
    // This compensates for any processing or UI update latency.
    final ms = position.inMilliseconds + 150;

    // Binary search for efficiency and correctness
    // Find the first timing where timeOfEnding > ms
    int low = 0;
    int high = _timings.length - 1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      if (_timings[mid].timeOfEnding > ms) {
        newIndex = mid;
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    // If audio position is past the last verse, keep the last verse highlighted
    if (newIndex == -1 && ms >= _timings.last.timeOfEnding) {
      newIndex = _timings.length - 1;
    }

    // Never index past the visible verse list (timings/verses mismatch
    // must not crash the frame with a RangeError).
    if (newIndex < 0 || newIndex >= _verses.length) return;

    // Custom part boundaries: replay the part [_segmentRepeatTotal] times,
    // then stop on its last verse.
    if (_hasRange) {
      final rs = _rangeStart!;
      final re = _rangeEnd!;
      if (newIndex > re) {
        // The part's last verse still honors ayah-repeat before stopping.
        if (_ayahRepeatTotal > 1 &&
            _loopVerse == re &&
            _loopProgress.value >= 1 &&
            _loopProgress.value < _ayahRepeatTotal) {
          _loopProgress.value++;
          _inLoopBack = true;
          _scrollToVerse(re);
          final startMs = re == 0 ? 0 : _timings[re - 1].timeOfEnding;
          try {
            audioService.seek(Duration(milliseconds: startMs));
          } catch (_) {}
          return;
        }
        // The part itself repeats N times (تكرار المقطع) before stopping.
        if (_segmentDone < _segmentRepeatTotal) {
          _segmentDone++;
          unawaited(_replaySegment(audioService));
          return;
        }
        _currentVerseIndex.value = re;
        _loopVerse = re;
        _scrollToVerse(re);
        _saveProgress(re);
        try {
          audioService.pause();
        } catch (_) {}
        return;
      }
      if (newIndex < rs) {
        // An external seek (e.g. notification) jumped before the part:
        // drop the filter and follow the user instead of fighting them.
        setState(() {
          _rangeStart = null;
          _rangeEnd = null;
          _rangeLabel = null;
        });
      }
    }

    // Reject wild backward jumps: natural playback never jumps back except
    // via ayah loop-back (guarded by _inLoopBack). This drops the stale ~0
    // tick emitted around the first pause, which otherwise snaps the
    // highlight to the first verse — even right after a manual seek, whose
    // flag must not open a hole here (manual seeks already sync everything
    // via _forceUpdateHighlight, and the flag is preserved below for its
    // real job: suppressing a loop-back yank). The baseline still advances,
    // so a sustained new position (e.g. a notification seek) is accepted on
    // the very next tick.
    if (_hasHighlightPosition &&
        !_inLoopBack &&
        position < _lastHighlightPosition - const Duration(seconds: 2)) {
      _lastHighlightPosition = position;
      return;
    }
    _hasHighlightPosition = true;
    _lastHighlightPosition = position;

    final current = _currentVerseIndex.value;
    if (newIndex == current) {
      // Settled inside the same verse: clear transient flags.
      if (newIndex == _loopVerse) _inLoopBack = false;
      _suppressLoopOnce = false;
      return;
    }

    if (_inLoopBack && !_suppressLoopOnce) {
      // Ticks arriving between a loop-back seek and its landing.
      if (newIndex == _loopVerse) _inLoopBack = false;
      return;
    }

    final bool manual = _suppressLoopOnce;
    _suppressLoopOnce = false;
    _inLoopBack = false;

    // Backward hysteresis for passive ticks: pausing right after a verse
    // boundary can freeze a slightly stale position just before the current
    // verse's start (e.g. pausing at the start of ألم reports a position
    // inside بسم الله). That must not move the highlight back — the audio
    // is actually in the current verse. Genuine larger jumps (notification
    // seeks) still pass, as do manual seeks and ayah loop-backs.
    if (!manual &&
        newIndex < current &&
        current > 0 &&
        current <= _timings.length &&
        position.inMilliseconds >
            _timings[current - 1].timeOfEnding - _kBackwardHysteresisMs) {
      return;
    }

    if (!manual &&
        newIndex == current + 1 &&
        current == _loopVerse &&
        _loopVerse >= 0 &&
        _ayahRepeatTotal > 1 &&
        _loopProgress.value < _ayahRepeatTotal) {
      // Natural end of the looping verse and repeats remain:
      // seek back to its start instead of advancing.
      _loopProgress.value++;
      _inLoopBack = true;
      _scrollToVerse(_loopVerse);
      final startMs = _loopVerse == 0
          ? 0
          : _timings[_loopVerse - 1].timeOfEnding;
      audioService.seek(Duration(milliseconds: startMs));
      return;
    }

    _loopVerse = newIndex;
    _loopProgress.value = _ayahRepeatTotal > 1 ? 1 : 0;
    _currentVerseIndex.value = newIndex;
    _scrollToVerse(newIndex);
    _saveProgress(newIndex);
  }

  void _forceUpdateHighlight(Duration position) {
    // A version of _updateCurrentVerse that forces an update even if the index hasn't changed
    // Useful for initial load when ValueNotifier might not trigger listeners if value is already -1
    if (_timings.isEmpty || _verses.isEmpty) return;
    if (_myGeneration != _playerGeneration) return;

    int newIndex = -1;
    final ms = position.inMilliseconds + 150;

    int low = 0;
    int high = _timings.length - 1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      if (_timings[mid].timeOfEnding > ms) {
        newIndex = mid;
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    if (newIndex == -1 && ms >= _timings.last.timeOfEnding) {
      newIndex = _timings.length - 1;
    }

    if (newIndex < 0 || newIndex >= _verses.length) return;

    // Keep explicit highlights inside the chosen part: seeks are clamped,
    // but guard anyway so a stale position never escapes the part.
    if (_hasRange) {
      if (newIndex > _rangeEnd!) {
        newIndex = _rangeEnd!;
      } else if (newIndex < _rangeStart!) {
        setState(() {
          _rangeStart = null;
          _rangeEnd = null;
          _rangeLabel = null;
        });
      }
    }

    {
      // Explicit highlight (initial load or manual seek): restart the
      // ayah-loop counter on the target verse and refresh the position
      // baseline used by the wild-jump guard.
      _loopVerse = newIndex;
      _loopProgress.value = _ayahRepeatTotal > 1 ? 1 : 0;
      _hasHighlightPosition = true;
      _lastHighlightPosition = position;
      _currentVerseIndex.value = newIndex;
      _scrollToVerse(newIndex);
      _saveProgress(newIndex);
    }
  }

  String _cleanArabicText(String text) {
    if (text.isEmpty) return text;

    // 1. Normalize whitespace and trim
    String cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');

    // 2. Split into words
    final words = cleaned.split(' ');

    // 3. Remove the last word if it's 1 or 2 characters long and not the only word.
    // This is designed to remove markers like 'نج', 'نح', 'بج', etc.
    if (words.length > 1 && words.last.length <= 2) {
      words.removeLast();
      return words.join(' ');
    }

    return cleaned;
  }

  void _scrollToVerse(int index) {
    if (!_itemScrollController.isAttached) return;
    // Guard against out-of-range indices (stale resume index, or timings
    // longer than the verse list). scrollTo with an invalid index throws
    // RangeError and crashes the frame.
    if (index < 0 || index >= _verses.length) return;

    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      alignment: 0.3, // Maintain active verse in "focus" area (30% from top)
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerHandler>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF5E6), // Light tan/beige app bar
        elevation: 0,
        toolbarHeight: 64,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        // Two-line title. With a single settings action balancing the
        // back button, the surah name sits truly centered.
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.surah.arabicName,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                color: kPrimaryBrown,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            Text(
              _surahMetaLine(),
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13,
                color: kPrimaryBrown.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: kPrimaryBrown),
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _reloadSettings());
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Container(
          color: const Color(
            0xFFFFF9EC,
          ), // Matching background color from image
          child: Column(
            children: [
              // Quick controls strip: big labeled buttons instead of tiny
              // AppBar icons. Same pickers, kept in sync automatically.
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryBrown.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStripButton(
                        icon: Icons.tune,
                        label: 'مقطع',
                        active: _hasRange,
                        count: 1,
                        onTap: _loaded ? _openPartPicker : null,
                      ),
                      _buildStripButton(
                        icon: Icons.repeat_one,
                        label: 'الآية',
                        active: _ayahRepeatTotal > 1,
                        count: _ayahRepeatTotal,
                        onTap: () => _showAyahRepeatPicker(context),
                      ),
                      _buildStripButton(
                        icon: Icons.repeat,
                        label: _hasRange ? 'المقطع' : 'السورة',
                        active: (_hasRange
                                ? _segmentRepeatTotal
                                : _surahRepeatTotal) >
                            1,
                        count: _hasRange
                            ? _segmentRepeatTotal
                            : _surahRepeatTotal,
                        onTap: () => _hasRange
                            ? _showSegmentRepeatPicker(context)
                            : _showSurahRepeatPicker(context),
                      ),
                    ],
                  ),
                ),
              ),
              if (_hasRange && _loaded)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryBrown.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGold.withValues(alpha: 0.6)),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tune,
                          size: 18,
                          color: kPrimaryBrown,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _rangeLabel ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryBrown,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _showSegmentRepeatPicker(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.repeat,
                                size: 16,
                                color: kPrimaryBrown,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'تكرار ×$_segmentRepeatTotal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryBrown,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _clearRange,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'كامل السورة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kPrimaryBrown,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.close,
                                size: 18,
                                color: kPrimaryBrown,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: !_loaded
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryBrown),
                      )
                    : _verses.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد آيات لهذه السورة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20,
                            color: kPrimaryBrown,
                          ),
                        ),
                      )
                    : ValueListenableBuilder<int>(
                        valueListenable: _currentVerseIndex,
                        builder: (context, currentIndex, _) {
                          return ScrollablePositionedList.builder(
                            itemScrollController: _itemScrollController,
                            itemPositionsListener: _itemPositionsListener,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 20,
                            ),
                            itemCount: _verses.length,
                            itemBuilder: (context, index) {
                              final verse = _verses[index];
                              final isCurrent = index == currentIndex;
                              final isOutside =
                                  _hasRange &&
                                  (index < _rangeStart! ||
                                      index > _rangeEnd!);

                              return GestureDetector(
                                onTap: () {
                                  if (_timings.isNotEmpty &&
                                      index < _timings.length &&
                                      index < _verses.length) {
                                    // Tapping outside a chosen part drops the
                                    // filter and follows the user.
                                    if (isOutside) _clearRange();
                                    // Manual seek: never treat the resulting jump as
                                    // a natural verse completion (no loop-back).
                                    // Optimistic highlight so taps (even while paused
                                    // or on the first verse) feel instant and don't
                                    // depend on the next position tick.
                                    _suppressLoopOnce = true;
                                    _inLoopBack = false;
                                    final startTimeMs = index == 0
                                        ? 0
                                        : _timings[index - 1].timeOfEnding;
                                    _forceUpdateHighlight(
                                      Duration(milliseconds: startTimeMs),
                                    );
                                    audioService.seek(
                                      Duration(milliseconds: startTimeMs),
                                    );
                                  }
                                },
                                child: Opacity(
                                  opacity: isOutside ? 0.45 : 1.0,
                                  child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Verse Card
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 30,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? const Color(0xFFFFF8E1)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isCurrent
                                                ? kGold
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.04,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              _cleanArabicText(
                                                verse.text ??
                                                    verse.uthmaniText ??
                                                    '',
                                              ),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Amiri',
                                                fontSize: 32,
                                                height: 1.6,
                                                color: kPrimaryBrown,
                                                fontWeight: isCurrent
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            // Ayah-loop progress badge, shown on the
                                            // looping verse while repeats remain.
                                            if (isCurrent &&
                                                _ayahRepeatTotal > 1 &&
                                                index == _loopVerse)
                                              ValueListenableBuilder<int>(
                                                valueListenable: _loopProgress,
                                                builder: (context, done, _) {
                                                  if (done <= 0) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          top: 12,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: kPrimaryBrown
                                                          .withValues(alpha: 0.08),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      border: Border.all(
                                                        color: kGold
                                                            .withValues(alpha: 0.6),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.repeat,
                                                          size: 14,
                                                          color: kPrimaryBrown,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          '$done / $_ayahRepeatTotal',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                kPrimaryBrown,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Verse Number Badge
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: isCurrent
                                                ? const Color(0xFF795548)
                                                : const Color(0xFFF5F5F5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${verse.verseNumberInSura}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isCurrent
                                                    ? Colors.white
                                                    : Colors.black38,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Speaker Icon for active verse
                                      if (isCurrent)
                                        const Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Icon(
                                            Icons.volume_up,
                                            color: Color(0xFF795548),
                                            size: 22,
                                          ),
                                        ),
                                    ],
                                  ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              // Bottom Player Controls
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF5E6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<Duration?>(
                      stream: audioHandler.durationStream,
                      builder: (context, durationSnapshot) {
                        final duration = durationSnapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration>(
                          stream: audioHandler.positionStream,
                          builder: (context, positionSnapshot) {
                            var position =
                                positionSnapshot.data ?? Duration.zero;
                            if (position > duration) position = duration;
                            return Column(
                              children: [
                                ProgressBar(
                                  progress: position,
                                  total: duration,
                                  progressBarColor: kPrimaryBrown,
                                  baseBarColor: kPrimaryBrown.withValues(alpha: 0.15),
                                  thumbColor: kPrimaryBrown,
                                  thumbRadius: 10,
                                  barHeight: 2.5,
                                  timeLabelLocation: TimeLabelLocation.none,
                                  onSeek: (seekTarget) {
                                    _suppressLoopOnce = true;
                                    _inLoopBack = false;
                                    final target = _clampToRange(seekTarget);
                                    audioHandler.seek(target);
                                    // Sync highlight immediately (covers seeks
                                    // while paused, where no position ticks
                                    // arrive to drive _updateCurrentVerse).
                                    _forceUpdateHighlight(target);
                                  },
                                ),
                                const SizedBox(height: 12),
                                // Middle Row: Time, Replay 5s, Speed, Forward 5s, Total Time
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: TextStyle(
                                        color: kPrimaryBrown.withValues(alpha: 0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.replay_5,
                                        color: kPrimaryBrown,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        _suppressLoopOnce = true;
                                        _inLoopBack = false;
                                        final raw =
                                            audioHandler.player.position -
                                            const Duration(seconds: 5);
                                        final target = _clampToRange(
                                          raw < Duration.zero
                                              ? Duration.zero
                                              : raw,
                                        );
                                        audioHandler.seek(target);
                                        _forceUpdateHighlight(target);
                                      },
                                    ),
                                    _buildSpeedButton(context, audioHandler),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.forward_5,
                                        color: kPrimaryBrown,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        _suppressLoopOnce = true;
                                        _inLoopBack = false;
                                        final target = _clampToRange(
                                          audioHandler.player.position +
                                              const Duration(seconds: 5),
                                        );
                                        audioHandler.seek(target);
                                        _forceUpdateHighlight(target);
                                      },
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: TextStyle(
                                        color: kPrimaryBrown.withValues(alpha: 0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Bottom Row: Skip Previous, Play/Pause, Skip Next
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: kPrimaryBrown,
                            size: 32,
                          ),
                          onPressed: () async {
                            _suppressLoopOnce = true;
                            _inLoopBack = false;
                            if (_hasRange && _timings.isNotEmpty) {
                              // Step verse-by-verse, staying inside the part.
                              final cur = _currentVerseIndex.value.clamp(
                                _rangeStart!,
                                _rangeEnd!,
                              );
                              final prev = (cur - 1).clamp(
                                _rangeStart!,
                                _rangeEnd!,
                              );
                              final startMs = prev <= 0
                                  ? 0
                                  : _timings[prev - 1].timeOfEnding;
                              final target = Duration(
                                milliseconds: startMs,
                              );
                              _forceUpdateHighlight(target);
                              await audioHandler.seek(target);
                            } else {
                              await audioHandler.skipToPrevious();
                              _forceUpdateHighlight(
                                audioHandler.player.position,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 40),
                        StreamBuilder<PlayerState>(
                          stream: audioHandler.playerStateStream,
                          builder: (context, snapshot) {
                            final playing = snapshot.data?.playing ?? false;
                            return GestureDetector(
                              onTap: audioHandler.togglePlay,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  color: kPrimaryBrown,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  playing ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 40),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: kPrimaryBrown,
                            size: 32,
                          ),
                          onPressed: () async {
                            _suppressLoopOnce = true;
                            _inLoopBack = false;
                            if (_hasRange && _timings.isNotEmpty) {
                              // Step verse-by-verse, staying inside the part.
                              final cur = _currentVerseIndex.value.clamp(
                                _rangeStart!,
                                _rangeEnd!,
                              );
                              final next = (cur + 1).clamp(
                                _rangeStart!,
                                _rangeEnd!,
                              );
                              final startMs = next <= 0
                                  ? 0
                                  : _timings[next - 1].timeOfEnding;
                              final target = Duration(
                                milliseconds: startMs,
                              );
                              _forceUpdateHighlight(target);
                              await audioHandler.seek(target);
                            } else {
                              await audioHandler.skipToNext();
                              _forceUpdateHighlight(
                                audioHandler.player.position,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _repeatLabel(int n) {
    if (n == 1) return 'مرة واحدة';
    if (n == 2) return 'مرتان';
    return '$n مرات';
  }

  /// AppBar subtitle line: surah number, ayah count, revelation type.
  String _surahMetaLine() {
    final n = widget.surah.suraNumber ?? 0;
    final c = _ayahTotal > 0 ? _ayahTotal : widget.surah.verseCount;
    final count = c == 1 ? 'آية' : c == 2 ? 'آيتان' : '$c آيات';
    return 'سورة $n • $count • ${_getSurahTypeLabel(n)}';
  }

  /// Labeled control button for the strip under the AppBar, with a gold
  /// count badge while its repeat is active.
  Widget _buildStripButton({
    required IconData icon,
    required String label,
    required bool active,
    required int count,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    final iconColor = !enabled
        ? Colors.black38
        : active
            ? kPrimaryBrown
            : kPrimaryBrown.withValues(alpha: 0.35);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: iconColor, size: 24),
                if (count > 1)
                  Positioned(
                    left: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: kGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Amiri',
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: enabled ? kPrimaryBrown : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAyahRepeatPicker(BuildContext context) {
    _showRepeatPicker(
      context: context,
      title: 'تكرار الآية',
      subtitle: 'إعادة كل آية أثناء التشغيل (للحفظ والمراجعة)',
      max: 100,
      current: _ayahRepeatTotal,
      onPick: (n) async {
        setState(() => _ayahRepeatTotal = n);
        await AppSettings.setAyahRepeat(n);
        if (!mounted) return;
        // Resync the badge counter with the newly chosen N.
        if (n > 1 && _loopVerse >= 0 && _loopProgress.value == 0) {
          _loopProgress.value = 1;
        } else if (n <= 1) {
          _loopProgress.value = 0;
        }
      },
    );
  }

  void _showSurahRepeatPicker(BuildContext context) {
    _showRepeatPicker(
      context: context,
      title: 'تكرار السورة',
      subtitle: 'إعادة السورة كاملة قبل الانتقال للتي بعدها',
      max: 100,
      current: _surahRepeatTotal,
      onPick: (n) async {
        setState(() => _surahRepeatTotal = n);
        await AppSettings.setSurahRepeat(n);
      },
    );
  }

  void _showSegmentRepeatPicker(BuildContext context) {
    _showRepeatPicker(
      context: context,
      title: 'تكرار المقطع',
      subtitle: 'إعادة تشغيل المقطع المحدد من بدايته',
      max: 100,
      current: _segmentRepeatTotal,
      onPick: (n) async {
        setState(() => _segmentRepeatTotal = n);
        await AppSettings.setSegmentRepeat(n);
      },
    );
  }

  void _showRepeatPicker({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int max,
    required int current,
    required Future<void> Function(int) onPick,
  }) {
    int temp = current.clamp(1, max);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            void setTemp(int v) {
              setModalState(() {
                temp = v.clamp(1, max);
              });
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 4),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBrown,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _repeatLabel(temp),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: kGold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    Slider(
                      value: temp.toDouble(),
                      min: 1,
                      max: max.toDouble(),
                      divisions: max - 1,
                      activeColor: kPrimaryBrown,
                      inactiveColor: kPrimaryBrown.withValues(alpha: 0.2),
                      label: '$temp',
                      onChanged: (v) => setTemp(v.round()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: kPrimaryBrown,
                            size: 34,
                          ),
                          tooltip: 'إنقاص',
                          onPressed: temp > 1 ? () => setTemp(temp - 1) : null,
                        ),
                        const SizedBox(width: 32),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: kPrimaryBrown,
                            size: 34,
                          ),
                          tooltip: 'زيادة',
                          onPressed: temp < max
                              ? () => setTemp(temp + 1)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await onPick(temp);
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'تأكيد',
                        style: TextStyle(fontSize: 18, fontFamily: 'Amiri'),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpeedButton(
    BuildContext context,
    AudioPlayerHandler audioHandler,
  ) {
    return StreamBuilder<double>(
      stream: audioHandler.player.speedStream,
      builder: (context, snapshot) {
        final speed = snapshot.data ?? 1.0;
        return InkWell(
          onTap: () => _showSpeedSelection(context, audioHandler, speed),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '${speed}x',
              style: const TextStyle(
                color: kPrimaryBrown,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSpeedSelection(
    BuildContext context,
    AudioPlayerHandler audioService,
    double initialSpeed,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'سرعة القراءة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBrown,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                    Text(
                      '${audioService.player.speed.toStringAsFixed(2)}x',
                      style: const TextStyle(
                        fontSize: 18,
                        color: kGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: audioService.player.speed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15, // 0.1 intervals
                      activeColor: kPrimaryBrown,
                      inactiveColor: kPrimaryBrown.withValues(alpha: 0.2),
                      label: '${audioService.player.speed.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        setModalState(() {
                          audioService.setSpeed(value);
                        });
                        AppSettings.setSpeed(value);
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'خيارات سريعة',
                      style: TextStyle(
                        fontSize: 16,
                        color: kPrimaryBrown,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                        final isSelected = audioService.player.speed == speed;
                        return ChoiceChip(
                          label: Text('${speed}x'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                audioService.setSpeed(speed);
                              });
                              AppSettings.setSpeed(speed);
                            }
                          },
                          selectedColor: kPrimaryBrown,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : kPrimaryBrown,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
