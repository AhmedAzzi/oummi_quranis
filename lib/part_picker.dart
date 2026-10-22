import 'package:flutter/material.dart';
import 'package:saad_el_ghamidy/main.dart' show kPrimaryBrown, kGold;
import 'package:saad_el_ghamidy/realm_schemas.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// App palette (matches the player screen).
const _cream = Color(0xFFFFF9EC);

/// A sub-range of a single surah, as global 0-based indexes into the
/// surah's verse/timing lists (inclusive on both ends).
class VerseRangeSelection {
  final int startIndex;
  final int endIndex;
  final String label;

  const VerseRangeSelection({
    required this.startIndex,
    required this.endIndex,
    required this.label,
  });
}

final _wsRegex = RegExp(r'\s+');

/// Full cleaned verse text (drops trailing markers like نج/نح).
String _cleanVerseText(Verses v) {
  var raw = (v.text ?? v.uthmaniText ?? '').trim().replaceAll(_wsRegex, ' ');
  if (raw.isEmpty) return '';
  final words = raw.split(' ');
  if (words.length > 1 && words.last.length <= 2) {
    words.removeLast();
    raw = words.join(' ');
  }
  return raw;
}

/// Short human-readable preview of a verse, e.g. `الحمد لله رب…`.
String verseSnippet(Verses v, {int maxChars = 48}) {
  final raw = _cleanVerseText(v);
  if (raw.length <= maxChars) return raw;
  // Cut at a word boundary when possible so we never split a word in half.
  var cut = raw.substring(0, maxChars);
  final lastSpace = cut.lastIndexOf(' ');
  if (lastSpace > maxChars - 15) cut = cut.substring(0, lastSpace);
  return '$cut…';
}

/// Plain derived data for one surah. Only ints/strings: safe to cache for
/// the whole app session (the bundled database never changes).
class _SurahPartsData {
  final List<int> pages;
  final Map<int, List<int>> pageAyahs;
  final Map<int, String> pageSnippets;

  const _SurahPartsData({
    required this.pages,
    required this.pageAyahs,
    required this.pageSnippets,
  });
}

final Map<int, _SurahPartsData> _partsCache = {};

_SurahPartsData _buildPartsData(List<Verses> verses) {
  // Single in-memory pass over the already-loaded verses: no Realm scans.
  // Only page rows need a text snippet, so only those (~50 max) are built.
  final pageAyahs = <int, List<int>>{};
  for (final v in verses) {
    final p = v.pageNumber;
    if (p != null) (pageAyahs[p] ??= []).add(v.verseNumberInSura);
  }
  final pages = pageAyahs.keys.toList()..sort();
  String snippetOf(int ayah) {
    final i = verses.indexWhere((v) => v.verseNumberInSura == ayah);
    if (i < 0) return '';
    return verseSnippet(verses[i], maxChars: 60);
  }

  return _SurahPartsData(
    pages: pages,
    pageAyahs: pageAyahs,
    pageSnippets: {
      for (final p in pages) p: snippetOf(pageAyahs[p]!.first),
    },
  );
}

/// Pre-builds (and caches) a surah's picker data OFF the tap path.
/// Call once its player screen has loaded; later taps open instantly.
void warmPartPickerCache({
  required int suraNumber,
  required List<Verses> verses,
}) {
  if (verses.isEmpty || _partsCache.containsKey(suraNumber)) return;
  _partsCache[suraNumber] = _buildPartsData(verses);
}

/// Opens a bottom-sheet picker to choose a part of [surah] to play:
/// tap verses directly (start then end), or pick a Mushaf page.
/// Returns null when dismissed without a choice. Single-surah only.
///
/// Opens instantly: the sheet paints immediately (spinner on first ever
/// open) while the one-time data prep runs after the first frame; later
/// opens reuse the session cache and show content right away.
Future<VerseRangeSelection?> showPartPicker({
  required BuildContext context,
  required Sura surah,
  required List<Verses> verses,
  int? currentStart,
  int? currentEnd,
}) {
  if (verses.isEmpty) return Future.value(null);
  return showModalBottomSheet<VerseRangeSelection>(
    context: context,
    backgroundColor: _cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _PartPickerSheet(
      surah: surah,
      suraNumber: surah.suraNumber ?? 0,
      verses: verses,
      currentStart: currentStart,
      currentEnd: currentEnd,
    ),
  );
}

class _PartPickerSheet extends StatefulWidget {
  final Sura surah;
  final int suraNumber;
  final List<Verses> verses;
  final int? currentStart;
  final int? currentEnd;

  const _PartPickerSheet({
    required this.surah,
    required this.suraNumber,
    required this.verses,
    required this.currentStart,
    required this.currentEnd,
  });

  @override
  State<_PartPickerSheet> createState() => _PartPickerSheetState();
}

class _PartPickerSheetState extends State<_PartPickerSheet> {
  _SurahPartsData? _data;
  final ItemScrollController _scrollController = ItemScrollController();

  int _mode = 0; // 0 = tap verses, 1 = pick a page
  late int _fromIdx;
  late int _toIdx;
  // Verse mode is two taps: first tap = start, second tap = end.
  bool _pickEnd = false;
  bool _hasPicked = false;
  int? _page;

  int _clampIdx(int i) =>
      widget.verses.isEmpty ? 0 : i.clamp(0, widget.verses.length - 1);

  @override
  void initState() {
    super.initState();
    var from = _clampIdx(widget.currentStart ?? 0);
    var to = _clampIdx(widget.currentEnd ?? widget.currentStart ?? 0);
    if (from > to) {
      final t = from;
      from = to;
      to = t;
    }
    _fromIdx = from;
    _toIdx = to;

    final cached = _partsCache[widget.suraNumber];
    if (cached != null) {
      _attachData(cached);
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToSelection());
    } else {
      // Let the sheet paint (spinner) before the one-time prep runs.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final data = _buildPartsData(widget.verses);
        _partsCache[widget.suraNumber] = data;
        if (!mounted) return;
        setState(() => _attachData(data));
        WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToSelection());
      });
    }
  }

  void _attachData(_SurahPartsData data) {
    _data = data;
    _page = data.pages.isNotEmpty ? data.pages.first : null;
  }

  void _jumpToSelection() {
    if (!mounted || _mode != 0 || _fromIdx <= 2) return;
    try {
      if (_scrollController.isAttached) {
        _scrollController.jumpTo(index: _fromIdx);
      }
    } catch (_) {}
  }

  void _onVerseTap(int index) {
    setState(() {
      _hasPicked = true;
      if (!_pickEnd) {
        _fromIdx = index;
        _toIdx = index;
        _pickEnd = true;
      } else {
        var a = _fromIdx;
        var b = index;
        if (b < a) {
          final t = a;
          a = b;
          b = t;
        }
        _fromIdx = a;
        _toIdx = b;
        _pickEnd = false;
      }
    });
  }

  VerseRangeSelection _buildSelection() {
    if (_mode == 1 && _page != null) {
      final pv = _data!.pageAyahs[_page!];
      if (pv != null && pv.isNotEmpty) {
        // Map ayah numbers back to list indexes (cheap int scan,
        // runs only when the selection changes).
        var s = widget.verses.indexWhere(
          (v) => v.verseNumberInSura == pv.first,
        );
        var e = widget.verses.indexWhere(
          (v) => v.verseNumberInSura == pv.last,
        );
        if (s < 0) s = 0;
        if (e < 0) e = widget.verses.length - 1;
        return VerseRangeSelection(
          startIndex: s,
          endIndex: e,
          label: 'صفحة $_page • الآيات ${pv.first}-${pv.last}',
        );
      }
    }
    final a = widget.verses[_fromIdx].verseNumberInSura;
    final b = widget.verses[_toIdx].verseNumberInSura;
    return VerseRangeSelection(
      startIndex: _fromIdx,
      endIndex: _toIdx,
      label: a == b ? 'الآية $a' : 'الآيات $a-$b',
    );
  }

  String _ayahCountLabel() {
    final sel = _buildSelection();
    final n = sel.endIndex - sel.startIndex + 1;
    if (n == 1) return 'آية واحدة';
    if (n == 2) return 'آيتان';
    return '$n آيات';
  }

  @override
  Widget build(BuildContext context) {
    // The whole sheet is forced RTL so Arabic rows align to the right.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: _data == null
              ? const SizedBox(
                  height: 260,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: kPrimaryBrown),
                        SizedBox(height: 12),
                        Text(
                          'جارٍ تجهيز المقاطع…',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: kPrimaryBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: kGold,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Header: gold icon + brown title + surah pill.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: kPrimaryBrown.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kGold.withValues(alpha: 0.7),
                              ),
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: kPrimaryBrown,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'تشغيل مقطع',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryBrown,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryBrown,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.surah.arabicName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          _modeChip('اختيار بالآيات', 0),
                          _modeChip('اختيار بالصفحة', 1),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _modeHint(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: _mode == 0
                            ? ScrollablePositionedList.builder(
                                itemScrollController: _scrollController,
                                itemCount: widget.verses.length,
                                padding: const EdgeInsets.only(bottom: 8),
                                itemBuilder: (context, index) =>
                                    _verseRow(index),
                              )
                            : ListView.builder(
                                itemCount: _data!.pages.length,
                                padding: const EdgeInsets.only(bottom: 8),
                                itemBuilder: (context, i) =>
                                    _pageRow(_data!.pages[i]),
                              ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(
                            context,
                            _buildSelection(),
                          ),
                          icon: const Icon(
                            Icons.play_arrow,
                            color: kGold,
                            size: 24,
                          ),
                          label: Text(
                            'تشغيل المقطع • ${_ayahCountLabel()}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Amiri',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBrown,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: kPrimaryBrown.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  String _modeHint() {
    if (_mode == 1) {
      return 'المسي الصفحة التي تريدين تشغيلها';
    }
    if (!_pickEnd) {
      return _hasPicked
          ? 'تم الاختيار • المسي أي آية لاختيار مقطع جديد'
          : 'المسي آية البداية';
    }
    return 'ممتاز • الآن المسي آية النهاية';
  }

  Widget _modeChip(String text, int value) {
    final selected = _mode == value;
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) => setState(() => _mode = value),
      selectedColor: kPrimaryBrown,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? kPrimaryBrown : kPrimaryBrown.withValues(alpha: 0.35),
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : kPrimaryBrown,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Amiri',
      ),
    );
  }

  /// One tappable verse card. The chosen range glows gold; start/end rows
  /// carry البداية / النهاية pills.
  Widget _verseRow(int index) {
    final v = widget.verses[index];
    final inRange = index >= _fromIdx && index <= _toIdx;
    final isStart = index == _fromIdx;
    final isEnd = index == _toIdx;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: inRange ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inRange ? kGold : kPrimaryBrown.withValues(alpha: 0.15),
          width: inRange ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _onVerseTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: inRange ? kPrimaryBrown : kPrimaryBrown
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'آية ${v.verseNumberInSura}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: inRange
                            ? Colors.white
                            : kPrimaryBrown,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isStart) _tag('البداية'),
                  if (isEnd) ...[
                    if (isStart) const SizedBox(width: 6),
                    _tag('النهاية'),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _cleanVerseText(v),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 17,
                  height: 1.55,
                  color: kPrimaryBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: kGold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
      ),
    );
  }

  /// One tappable page card: page number, ayah span, first words.
  Widget _pageRow(int page) {
    final selected = page == _page;
    final ayahs = _data!.pageAyahs[page]!;
    final span = ayahs.length == 1
        ? 'آية ${ayahs.first}'
        : 'الآيات ${ayahs.first}-${ayahs.last}';
    final snippet = _data!.pageSnippets[page] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? kGold : kPrimaryBrown.withValues(alpha: 0.15),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _page = page),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'صفحة $page',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryBrown,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    Text(
                      '$span • $snippet',
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontFamily: 'Amiri',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: selected
                      ? kPrimaryBrown
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? kPrimaryBrown
                        : kPrimaryBrown.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
