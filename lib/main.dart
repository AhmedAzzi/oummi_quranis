import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saad_el_ghamidy/audio_player_service.dart';
import 'package:saad_el_ghamidy/realm_service.dart';
import 'package:saad_el_ghamidy/realm_schemas.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastSuraNumber = prefs.getInt('last_sura');
      lastVerseIndex = prefs.getInt('last_verse');
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: kPrimaryBrown,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  const Text(
                    'هدية لأمي القرآنية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SurahPlayerScreen(
                                  surah: sura,
                                  initialVerseIndex: lastVerseIndex,
                                ),
                              ),
                            ).then((_) => _loadLastRead());
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => searchQuery = value),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'البحث عن سورة...',
                  prefixIcon: const Icon(Icons.search, color: kPrimaryBrown),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
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
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahPlayerScreen(surah: surah),
                        ),
                      ).then((_) => _loadLastRead());
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kLightBeige,
                        shape: BoxShape.circle,
                        border: Border.all(color: kGold.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          '${surah.suraNumber}',
                          style: const TextStyle(
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryBrown,
                      ),
                    ),
                    subtitle: Text(
                      'آية ${surah.verseCount} • ${_getSurahTypeLabel(surah.suraNumber ?? 0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: kPrimaryBrown.withOpacity(0.6)),
                    ),
                  ),
                ),
              );
            }, childCount: filteredSurahs.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
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
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  List<Verses> _verses = [];
  List<Timing> _timings = [];
  final ValueNotifier<int> _currentVerseIndex = ValueNotifier<int>(-1);
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _currentVerseIndex.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final realmService = Provider.of<RealmService>(context, listen: false);
    final verses = realmService.getVersesForSura(widget.surah.suraNumber!);
    final track = realmService.getTrackForSura(widget.surah.suraNumber!);
    List<Timing> timings = [];
    if (track != null) {
      timings = realmService.getTimingsForTrack(track.index);
    }

    setState(() {
      _verses = verses;
      _timings = timings;
    });

    if (!mounted) return;

    // Setup listener BEFORE playing so we catch the very first position events
    _setupPositionListener();

    if (widget.initialVerseIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _currentVerseIndex.value = widget.initialVerseIndex!;
        _scrollToVerse(widget.initialVerseIndex!);
      });
    }

    await _loadAndPlay(timings);
  }

  void _setupPositionListener() {
    final audioService = Provider.of<AudioPlayerHandler>(
      context,
      listen: false,
    );

    // Listen to position updates
    _positionSubscription = audioService.positionStream.listen((position) {
      if (audioService.player.processingState != ProcessingState.completed) {
        _updateCurrentVerse(position);
      }
    });

    // Also listen to player state changes (e.g., when it starts playing)
    // to ensure highlighting is correct as soon as the player is ready.
    _playerStateSubscription = audioService.player.playerStateStream.listen((
      state,
    ) async {
      if (!mounted) return;
      if (state.playing) {
        _updateCurrentVerse(audioService.player.position);
      }
      if (state.processingState == ProcessingState.completed) {
        // We no longer clear progress or reset highlights here
        // so that the last verse remains saved and highlighted.
        await audioService.stop();
      }
    });
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
        widget.initialVerseIndex! > 0 &&
        timings.isNotEmpty &&
        widget.initialVerseIndex! < timings.length) {
      final startTimeMs = timings[widget.initialVerseIndex! - 1].timeOfEnding;
      initialPosition = Duration(milliseconds: startTimeMs);
    }

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

    // Force an initial update for highlighting
    if (mounted) {
      _forceUpdateHighlight(initialPosition ?? Duration.zero);
    }
  }

  Future<void> _saveProgress(int verseIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_sura', widget.surah.suraNumber!);
    await prefs.setInt('last_verse', verseIndex);
  }

  void _updateCurrentVerse(Duration position) {
    if (!mounted || _timings.isEmpty) return;

    final audioService = Provider.of<AudioPlayerHandler>(
      context,
      listen: false,
    );
    if (audioService.player.processingState == ProcessingState.completed) {
      return;
    }

    int newIndex = -1;

    // Check if we are at the very beginning of the Surah
    // If current index is the last verse and position is 0, it's likely a post-completion reset, so ignore it.
    if (position == Duration.zero &&
        _currentVerseIndex.value == _timings.length - 1) {
      return;
    }

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

    if (newIndex != -1 && newIndex != _currentVerseIndex.value) {
      _currentVerseIndex.value = newIndex;
      _scrollToVerse(newIndex);
      _saveProgress(newIndex);
    }
  }

  void _forceUpdateHighlight(Duration position) {
    // A version of _updateCurrentVerse that forces an update even if the index hasn't changed
    // Useful for initial load when ValueNotifier might not trigger listeners if value is already -1
    if (_timings.isEmpty) return;

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

    if (newIndex != -1) {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.surah.arabicName,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 28,
            color: kPrimaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFFFF9EC), // Matching background color from image
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<int>(
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

                      return GestureDetector(
                        onTap: () {
                          if (_timings.isNotEmpty && index < _timings.length) {
                            final startTimeMs = index == 0
                                ? 0
                                : _timings[index - 1].timeOfEnding;
                            audioService.seek(
                              Duration(milliseconds: startTimeMs),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Verse Card
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 30,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? const Color(0xFFFFF8E1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrent
                                        ? kGold
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _cleanArabicText(
                                        verse.text ?? verse.uthmaniText ?? '',
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
                    color: Colors.black.withOpacity(0.05),
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
                          var position = positionSnapshot.data ?? Duration.zero;
                          if (position > duration) position = duration;
                          return Column(
                            children: [
                              ProgressBar(
                                progress: position,
                                total: duration,
                                progressBarColor: kPrimaryBrown,
                                baseBarColor: kPrimaryBrown.withOpacity(0.15),
                                thumbColor: kPrimaryBrown,
                                thumbRadius: 10,
                                barHeight: 2.5,
                                timeLabelLocation: TimeLabelLocation.none,
                                onSeek: (duration) =>
                                    audioHandler.seek(duration),
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
                                      color: kPrimaryBrown.withOpacity(0.5),
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
                                    onPressed: () => audioHandler.seek(
                                      audioHandler.player.position -
                                          const Duration(seconds: 5),
                                    ),
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
                                    onPressed: () => audioHandler.seek(
                                      audioHandler.player.position +
                                          const Duration(seconds: 5),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: TextStyle(
                                      color: kPrimaryBrown.withOpacity(0.5),
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
                        onPressed: audioHandler.skipToPrevious,
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
                        onPressed: audioHandler.skipToNext,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
                      inactiveColor: kPrimaryBrown.withOpacity(0.2),
                      label: '${audioService.player.speed.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        setModalState(() {
                          audioService.setSpeed(value);
                        });
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
