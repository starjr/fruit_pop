import 'dart:convert';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

/// 단말 로컬 저장소. 모든 데이터는 SharedPreferences 에 평문 JSON 으로
/// 저장되며 외부로 전송되지 않는다.
class LocalStore {
  static late LocalStore _instance;
  static LocalStore get I => _instance;

  final SharedPreferences _prefs;
  LocalStore._(this._prefs);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStore._(prefs);
  }

  // ── 온보딩 ──────────────────────────────────────────────
  /// 첫 실행 시 닉네임 입력 화면을 띄우기 위한 플래그.
  /// 닉네임을 한 번이라도 저장(=완료) 하면 true 가 된다.
  bool get isOnboarded => _prefs.getBool('isOnboarded') ?? false;
  Future<void> completeOnboarding() =>
      _prefs.setBool('isOnboarded', true);

  // ── 프로필 ──────────────────────────────────────────────
  String get nickname => _prefs.getString('nickname') ?? '플레이어';
  Future<void> setNickname(String v) async {
    final clean = v.trim();
    if (clean.isEmpty) return;
    await _prefs.setString('nickname', clean.substring(0, math.min(clean.length, 12)));
  }

  /// 닉네임의 첫 한 글자 — 아바타 원형 안에 표시.
  String get nicknameInitial {
    final n = nickname;
    return n.isEmpty ? '?' : n.substring(0, 1);
  }

  // ── 코인 ────────────────────────────────────────────────
  int get coins => _prefs.getInt('coins') ?? 200;
  Future<void> _setCoins(int v) =>
      _prefs.setInt('coins', v.clamp(0, 999999999));
  Future<void> addCoins(int delta) => _setCoins(coins + delta);

  // ── 베스트 점수 ─────────────────────────────────────────
  int get bestScore => _prefs.getInt('bestScore') ?? 0;

  // ── 최근 게임 기록 (최대 50개) ──────────────────────────
  List<GameRecord> get recentGames {
    final raw = _prefs.getString('recentGames');
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => GameRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _setRecentGames(List<GameRecord> list) =>
      _prefs.setString(
          'recentGames', jsonEncode(list.map((e) => e.toJson()).toList()));

  /// 점수 기준 상위 N개. 동점이면 더 최근 기록이 위.
  List<GameRecord> topScores({int n = 10}) {
    final list = List<GameRecord>.from(recentGames);
    list.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return b.timestamp.compareTo(a.timestamp);
    });
    return list.take(n).toList();
  }

  // ── 설정 ───────────────────────────────────────────────
  bool get bgmEnabled => _prefs.getBool('bgmEnabled') ?? true;
  Future<void> setBgmEnabled(bool v) => _prefs.setBool('bgmEnabled', v);

  bool get sfxEnabled => _prefs.getBool('sfxEnabled') ?? true;
  Future<void> setSfxEnabled(bool v) => _prefs.setBool('sfxEnabled', v);

  bool get hapticEnabled => _prefs.getBool('hapticEnabled') ?? false;
  Future<void> setHapticEnabled(bool v) => _prefs.setBool('hapticEnabled', v);

  bool get pushEnabled => _prefs.getBool('pushEnabled') ?? false;
  Future<void> setPushEnabled(bool v) => _prefs.setBool('pushEnabled', v);

  // ── 데일리 챌린지 ───────────────────────────────────────
  /// 오늘 자 챌린지를 반환. 날짜가 바뀌었으면 새로 생성·저장한다.
  DailyChallenge get dailyChallenge {
    final today = _todayKey();
    final raw = _prefs.getString('dailyChallenge');
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        if (data['date'] == today) return DailyChallenge.fromJson(data);
      } catch (_) {}
    }
    final fresh = DailyChallenge.forDate(today);
    _prefs.setString('dailyChallenge', jsonEncode(fresh.toJson()));
    return fresh;
  }

  Future<void> _saveChallenge(DailyChallenge c) =>
      _prefs.setString('dailyChallenge', jsonEncode(c.toJson()));

  // ── 상점 (스킨 보유/장착) ───────────────────────────────
  Set<String> get ownedSkins {
    final list = _prefs.getStringList('ownedSkins') ?? const ['classic'];
    return list.toSet();
  }

  Future<void> _setOwned(Set<String> set) =>
      _prefs.setStringList('ownedSkins', set.toList());

  String get equippedSkin => _prefs.getString('equippedSkin') ?? 'classic';
  Future<void> equipSkin(String id) async {
    if (!ownedSkins.contains(id)) return;
    await _prefs.setString('equippedSkin', id);
  }

  /// 스킨 구매. 잔액 부족 시 false.
  Future<bool> buySkin(String id, int price) async {
    if (ownedSkins.contains(id)) return true;
    if (coins < price) return false;
    await addCoins(-price);
    final next = ownedSkins..add(id);
    await _setOwned(next);
    return true;
  }

  // ── 게임 결과 기록 ──────────────────────────────────────
  Future<GameOutcome> recordGame({
    required int score,
    required int maxFruitId,
    required int combo,
    required int merges,
    required int elapsedSec,
    required Map<int, int> mergesByOutputId,
  }) async {
    final prevBest = bestScore;
    final isNewBest = score > prevBest;
    if (isNewBest) {
      await _prefs.setInt('bestScore', score);
    }

    // 최근 기록 (최신이 앞)
    final games = List<GameRecord>.from(recentGames);
    games.insert(
      0,
      GameRecord(
        score: score,
        maxFruitId: maxFruitId,
        combo: combo,
        merges: merges,
        elapsedSec: elapsedSec,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (games.length > 50) games.removeRange(50, games.length);
    await _setRecentGames(games);

    // 점수 → 코인 환산 (10점당 1코인)
    final coinsEarned = (score / 10).floor();
    await addCoins(coinsEarned);

    // 챌린지 진행 업데이트
    var challenge = dailyChallenge;
    final addProgress = challenge.progressDelta(
      score: score,
      maxFruitId: maxFruitId,
      combo: combo,
      mergesByOutputId: mergesByOutputId,
    );
    var challengeCompleted = false;
    var challengeReward = 0;
    if (!challenge.completed && addProgress > 0) {
      final next = math.min(challenge.target, challenge.progress + addProgress);
      challenge = challenge.copyWith(progress: next);
      if (challenge.progress >= challenge.target) {
        challenge = challenge.copyWith(completed: true);
        challengeCompleted = true;
        challengeReward = challenge.reward;
        await addCoins(challengeReward);
      }
      await _saveChallenge(challenge);
    }

    return GameOutcome(
      score: score,
      previousBest: prevBest,
      isNewBest: isNewBest,
      coinsEarned: coinsEarned,
      challengeCompleted: challengeCompleted,
      challengeRewardCoins: challengeReward,
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 모든 사용자 데이터(닉네임/코인/베스트/기록/챌린지/설정/스킨/온보딩) 를 제거.
  /// 다음 접근 시 기본값으로 복원되며 온보딩 화면이 다시 표시된다.
  Future<void> clearAll() async {
    const keys = [
      'isOnboarded',
      'nickname',
      'coins',
      'bestScore',
      'recentGames',
      'bgmEnabled',
      'sfxEnabled',
      'hapticEnabled',
      'pushEnabled',
      'dailyChallenge',
      'ownedSkins',
      'equippedSkin',
    ];
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}

/// 한 게임의 기록.
class GameRecord {
  final int score;
  final int maxFruitId;
  final int combo;
  final int merges;
  final int elapsedSec;
  final int timestamp;

  const GameRecord({
    required this.score,
    required this.maxFruitId,
    required this.combo,
    required this.merges,
    required this.elapsedSec,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'maxFruitId': maxFruitId,
        'combo': combo,
        'merges': merges,
        'elapsedSec': elapsedSec,
        'ts': timestamp,
      };

  factory GameRecord.fromJson(Map<String, dynamic> j) => GameRecord(
        score: (j['score'] as num?)?.toInt() ?? 0,
        maxFruitId: (j['maxFruitId'] as num?)?.toInt() ?? 0,
        combo: (j['combo'] as num?)?.toInt() ?? 0,
        merges: (j['merges'] as num?)?.toInt() ?? 0,
        elapsedSec: (j['elapsedSec'] as num?)?.toInt() ?? 0,
        timestamp: (j['ts'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      );
}

/// 게임 종료 직후 화면에 표시할 “결과 요약”.
class GameOutcome {
  final int score;
  final int previousBest;
  final bool isNewBest;
  final int coinsEarned;
  final bool challengeCompleted;
  final int challengeRewardCoins;

  const GameOutcome({
    required this.score,
    required this.previousBest,
    required this.isNewBest,
    required this.coinsEarned,
    required this.challengeCompleted,
    required this.challengeRewardCoins,
  });
}

// ── 데일리 챌린지 ─────────────────────────────────────────
class DailyChallenge {
  final String date; // YYYY-MM-DD
  final ChallengeKind kind;
  final int target;
  final int reward; // 코인
  final int progress;
  final bool completed;

  const DailyChallenge({
    required this.date,
    required this.kind,
    required this.target,
    required this.reward,
    required this.progress,
    required this.completed,
  });

  String get title => kind.title(target);

  DailyChallenge copyWith({int? progress, bool? completed}) => DailyChallenge(
        date: date,
        kind: kind,
        target: target,
        reward: reward,
        progress: progress ?? this.progress,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'kind': kind.id,
        'target': target,
        'reward': reward,
        'progress': progress,
        'completed': completed,
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> j) => DailyChallenge(
        date: (j['date'] as String?) ?? '',
        kind: ChallengeKind.fromId((j['kind'] as String?) ?? 'apple'),
        target: (j['target'] as num?)?.toInt() ?? 5,
        reward: (j['reward'] as num?)?.toInt() ?? 200,
        progress: (j['progress'] as num?)?.toInt() ?? 0,
        completed: (j['completed'] as bool?) ?? false,
      );

  static DailyChallenge forDate(String date) {
    const pool = ChallengeKind.pool;
    final hash = date.hashCode.abs();
    final picked = pool[hash % pool.length];
    return DailyChallenge(
      date: date,
      kind: picked.kind,
      target: picked.target,
      reward: picked.reward,
      progress: 0,
      completed: false,
    );
  }
}

/// 챌린지 종류.
class ChallengeKind {
  final String id;
  final String label;
  final String unit; // “개”, “점”, “×”
  final int? targetFruitId; // 누적 — 특정 과일을 N개 만들기
  final bool useScore;       // 단판 — 점수 N점 이상
  final bool useCombo;       // 단판 — 콤보 N 이상
  const ChallengeKind._({
    required this.id,
    required this.label,
    required this.unit,
    this.targetFruitId,
    this.useScore = false,
    this.useCombo = false,
  });

  String title(int target) {
    final t = target.toString();
    if (targetFruitId != null) return '$label $t$unit 만들기';
    if (useScore) return '$t$unit 달성하기';
    if (useCombo) return '$label $t 달성하기';
    return label;
  }

  static const grape = ChallengeKind._(
      id: 'grape', label: '포도', unit: '개', targetFruitId: 2);
  static const tangerine = ChallengeKind._(
      id: 'tangerine', label: '데코폰', unit: '개', targetFruitId: 3);
  static const apple = ChallengeKind._(
      id: 'apple', label: '사과', unit: '개', targetFruitId: 5);
  static const pear = ChallengeKind._(
      id: 'pear', label: '배', unit: '개', targetFruitId: 6);
  static const peach = ChallengeKind._(
      id: 'peach', label: '복숭아', unit: '개', targetFruitId: 7);
  static const score = ChallengeKind._(
      id: 'score', label: '점수', unit: '점', useScore: true);
  static const combo = ChallengeKind._(
      id: 'combo', label: '콤보', unit: '', useCombo: true);

  static const all = [grape, tangerine, apple, pear, peach, score, combo];

  static ChallengeKind fromId(String id) =>
      all.firstWhere((k) => k.id == id, orElse: () => apple);

  /// 가능한 챌린지 풀 (target/reward).
  static const pool = <_PoolEntry>[
    _PoolEntry(grape, 6, 150),
    _PoolEntry(tangerine, 4, 180),
    _PoolEntry(apple, 5, 200),
    _PoolEntry(pear, 3, 250),
    _PoolEntry(peach, 1, 300),
    _PoolEntry(score, 2000, 200),
    _PoolEntry(combo, 8, 200),
  ];
}

class _PoolEntry {
  final ChallengeKind kind;
  final int target;
  final int reward;
  const _PoolEntry(this.kind, this.target, this.reward);
}

/// 한 판 결과로부터 챌린지 진행도 증가량을 계산.
/// - 누적형(targetFruitId): 만든 개수만큼 가산
/// - 단판형(useScore/useCombo): 임계값(target) 이상이면 target 만큼 한 번에 채움
extension ChallengeEvaluator on DailyChallenge {
  int progressDelta({
    required int score,
    required int maxFruitId,
    required int combo,
    required Map<int, int> mergesByOutputId,
  }) {
    if (kind.targetFruitId != null) {
      return mergesByOutputId[kind.targetFruitId!] ?? 0;
    }
    if (kind.useScore) {
      return score >= target ? target : 0;
    }
    if (kind.useCombo) {
      return combo >= target ? target : 0;
    }
    return 0;
  }
}

