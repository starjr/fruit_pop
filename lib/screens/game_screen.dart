import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../data/fruit_data.dart';
import '../data/skin_catalog.dart';
import '../theme/app_colors.dart';
import '../widgets/fruits/fruit_painters.dart';
import '../widgets/icons.dart';
import '../widgets/pop_button.dart';
import '../services/local_store.dart';
import '../services/audio_service.dart';
import 'result_screen.dart';

// 가로 플레이 영역을 넓게 사용하기 위해 보드 비율을 가로로 확장한다.
const double _boardWidth = 420;
const double _boardHeight = 540;
// LIMIT 라인 위 드롭 영역. 드롭되는 최대 과일 반지름(사과 ~36)에 여유분을
// 더해 미리보기가 라인을 넘지 않도록 한다.
const double _dangerLineY = 86;
// 보드 내부 안내선을 제거했으므로 벽/바닥 인셋을 0으로 두어
// 과일이 실제 보이는 보드 가장자리까지 닿도록 한다.
const double _wallInset = 0;
const double _floorInset = 0;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _FruitBody {
  _FruitBody({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    this.vx = 0,
    this.vy = 0,
  });

  int id;
  double x;
  double y;
  double vx;
  double vy;
  double radius;
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const double _gravity = 1100;
  static const int _spawnCooldownMs = 260;
  static const double _maxStepDt = 1 / 30;

  final List<_FruitBody> _fruits = <_FruitBody>[];
  final math.Random _rng = math.Random();
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  late final Ticker _ticker;
  Duration _lastTickElapsed = Duration.zero;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  int _score = 0;
  int _combo = 0;
  int _merges = 0;
  /// 이번에 떨어뜨릴 과일(보드 미리보기·드롭과 동일).
  int _handId = 1;
  /// 그 다음 손에 들 과일 — Suika 스타일로 HUD `NEXT`에만 표시.
  int _nextQueuedId = 1;
  int _maxFruitId = 0;
  // 결과로 만들어진 과일을 id별로 카운트(데일리 챌린지 진행도 계산에 사용).
  final Map<int, int> _mergesByOutputId = <int, int>{};

  int _dangerFrames = 0;
  int _comboDecayFrames = 0;
  DateTime? _lastDropAt;
  bool _ended = false;
  // 한 물리 스텝 안에서 수박 두 개가 만나 사라지면 true. 스텝 종료 후
  // 게임 종료를 트리거한다.
  bool _doubleMelonPop = false;

  /// 터치 중인 미리보기 드롭 위치(보드 좌표). null이면 비활성.
  double? _previewX;

  @override
  void initState() {
    super.initState();
    AudioService.I.attachLifecycleObserver();
    unawaited(AudioService.I.setGameSessionActive(true));
    _handId = _spawnableId();
    _nextQueuedId = _spawnableId();
    _ticker = createTicker(_onTick)..start();
    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _elapsed += const Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    unawaited(AudioService.I.setGameSessionActive(false));
    AudioService.I.detachLifecycleObserver();
    _ticker.dispose();
    _elapsedTimer?.cancel();
    _frame.dispose();
    super.dispose();
  }

  int _spawnableId() => 1 + _rng.nextInt(5);

  void _hapticLight() {
    if (LocalStore.I.hapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void _hapticMedium() {
    if (LocalStore.I.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// 본체 시각 반지름이 곧 물리 반지름이 되도록 매핑.
  /// fruits[id].radius (10~156) 를 게임 보드에 맞는 18~70 범위로 압축.
  /// 과일이 화면에 너무 많이 들어차지 않도록 단계별 차이를 키웠다.
  double _radiusForId(int id) {
    final r = fruits[id].radius;
    return (18 + (r - 22) * 0.42).clamp(18, 70).toDouble();
  }

  double _clampedPreviewX(double localDx, double widgetWidth) {
    final radius = _radiusForId(_handId);
    final boardX = (localDx / widgetWidth) * _boardWidth;
    return boardX
        .clamp(_wallInset + radius, _boardWidth - _wallInset - radius)
        .toDouble();
  }

  /// 미리보기 표시 y(보드 좌표). 큰 과일이라도 LIMIT 라인 위쪽에 안전하게
  /// 들어오도록 한 값. 드롭 시작 위치와 동일하게 사용해 “순간이동” 효과를 막는다.
  double _previewBoardY(double radius) {
    return math.max(radius + 4, _dangerLineY - radius - 6);
  }

  void _onPointerDown(PointerDownEvent e, BoxConstraints constraints) {
    if (_ended) return;
    final now = DateTime.now();
    if (_lastDropAt != null &&
        now.difference(_lastDropAt!).inMilliseconds < _spawnCooldownMs) {
      return;
    }
    setState(() {
      _previewX = _clampedPreviewX(e.localPosition.dx, constraints.maxWidth);
    });
  }

  void _onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    if (_previewX == null) return;
    setState(() {
      _previewX = _clampedPreviewX(e.localPosition.dx, constraints.maxWidth);
    });
  }

  void _onPointerUp(PointerUpEvent e) {
    final preview = _previewX;
    if (preview == null) return;
    _previewX = null;
    if (_ended) {
      setState(() {});
      return;
    }
    _lastDropAt = DateTime.now();

    final id = _handId;
    final radius = _radiusForId(id);
    final spawnY = _previewBoardY(radius);
    // 살짝의 좌우 흔들림으로 완벽한 수직 스택을 방지.
    final initialVx = (_rng.nextDouble() - 0.5) * 4;

    _fruits.add(
      _FruitBody(
        id: id,
        x: preview,
        y: spawnY,
        radius: radius,
        vx: initialVx,
        vy: 0,
      ),
    );

    setState(() {
      _handId = _nextQueuedId;
      _nextQueuedId = _spawnableId();
      if (id > _maxFruitId) _maxFruitId = id;
    });
    AudioService.I.playDrop();
    _hapticLight();
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (_previewX == null) return;
    setState(() => _previewX = null);
  }

  void _onTick(Duration elapsed) {
    if (!mounted || _ended) return;

    var dt = (elapsed - _lastTickElapsed).inMicroseconds / 1e6;
    _lastTickElapsed = elapsed;
    if (dt <= 0) return;
    if (dt > _maxStepDt) dt = _maxStepDt;

    _physicsStep(dt);
  }

  void _physicsStep(double dt) {
    if (_fruits.isEmpty) {
      _frame.value++;
      return;
    }

    final int beforeScore = _score;
    final int beforeMax = _maxFruitId;
    final int beforeCombo = _combo;
    bool mergedThisStep = false;
    bool megaMergeSfx = false;

    const floorY = _boardHeight - _floorInset;
    final n = _fruits.length;

    // 1) supported: 바닥에 닿아있거나, 다른 안정된 과일 위에 얹혀 있는 과일.
    //    이 과일들은 중력을 받지 않고 잔여 속도가 강하게 감쇠된다.
    //    이렇게 해야 스택된 과일들의 미세 떨림을 막을 수 있다.
    //
    //    임계값은 임팩트 직후 정상상태(중력+임펄스 절반감쇠) 의
    //    vy 진동 진폭(~|gravity*dt/0.5| ≈ 36) 을 안전하게 포함하도록 충분히
    //    크게 잡는다. 너무 빡빡하면 위쪽 과일이 영원히 cascade 에 들지 못해
    //    계속 떨린다.
    final supported = List<bool>.filled(n, false);
    for (int i = 0; i < n; i++) {
      final f = _fruits[i];
      if ((f.y + f.radius) >= (floorY - 0.5) &&
          f.vy.abs() < 55 &&
          f.vx.abs() < 14) {
        supported[i] = true;
      }
    }
    // 캐스케이드: 안정된 과일 위에 얹혀 있는(접촉 + 위쪽) 과일도 안정으로 본다.
    for (int iter = 0; iter < 6; iter++) {
      bool changed = false;
      for (int i = 0; i < n; i++) {
        if (supported[i]) continue;
        final a = _fruits[i];
        if (a.vx.abs() > 22 || a.vy.abs() > 60) continue;
        for (int j = 0; j < n; j++) {
          if (i == j || !supported[j]) continue;
          final b = _fruits[j];
          if (b.y <= a.y) continue; // b가 a보다 아래에 있어야 한다.
          final dx = b.x - a.x;
          final dy = b.y - a.y;
          final dist = math.sqrt(dx * dx + dy * dy);
          // 과일이 커졌으므로 접촉 허용 마진도 살짝 키운다.
          final reach = a.radius + b.radius + 6.0;
          if (dist <= reach && dy / (dist + 1e-6) > 0.5) {
            supported[i] = true;
            changed = true;
            break;
          }
        }
      }
      if (!changed) break;
    }

    // 2) 적분 단계.
    for (int i = 0; i < n; i++) {
      final f = _fruits[i];
      if (supported[i]) {
        // 안정된 과일은 잔여 운동량을 더 빠르게 0 으로 끌어당긴다.
        f.vx *= 0.45;
        f.vy *= 0.25;
        if (f.vx.abs() < 6) f.vx = 0;
        if (f.vy.abs() < 8) f.vy = 0;
      } else {
        f.vy += _gravity * dt;
      }

      f.x += f.vx * dt;
      f.y += f.vy * dt;

      if (f.x - f.radius < _wallInset) {
        f.x = _wallInset + f.radius;
        f.vx = -f.vx * 0.30;
      } else if (f.x + f.radius > _boardWidth - _wallInset) {
        f.x = _boardWidth - _wallInset - f.radius;
        f.vx = -f.vx * 0.30;
      }

      if (f.y + f.radius > floorY) {
        f.y = floorY - f.radius;
        if (f.vy > 0) f.vy = -f.vy * 0.18;
        if (f.vy.abs() < 25) f.vy = 0;
        f.vx *= 0.74;
      }

      if (f.vx.abs() < 8) f.vx = 0;
    }

    // 두 번에 걸친 단순 위치 보정으로 안정성 향상.
    for (int pass = 0; pass < 2; pass++) {
      final consumed = <int>{};
      final List<_FruitBody> spawned = <_FruitBody>[];

      for (int i = 0; i < _fruits.length; i++) {
        if (consumed.contains(i)) continue;
        final a = _fruits[i];
        for (int j = i + 1; j < _fruits.length; j++) {
          if (consumed.contains(j)) continue;
          final b = _fruits[j];
          final dx = b.x - a.x;
          final dy = b.y - a.y;
          final minDist = a.radius + b.radius;
          final distSq = dx * dx + dy * dy;

          // 머지 검사: 살짝 닿기만 해도(부동소수점 노이즈 허용) 동일
          // 종류는 합쳐지도록 한다.
          const double mergeTolerance = 1.5;
          final mergeReach = minDist + mergeTolerance;
          final isTouching = distSq < mergeReach * mergeReach;

          if (isTouching && a.id == b.id) {
            if (a.id < fruits.length - 1) {
              // 일반 머지: 다음 단계 과일을 두 과일 중간에 새로 만든다.
              final newId = a.id + 1;
              spawned.add(
                _FruitBody(
                  id: newId,
                  x: (a.x + b.x) / 2,
                  y: (a.y + b.y) / 2,
                  radius: _radiusForId(newId),
                  vx: (a.vx + b.vx) * 0.25,
                  vy: (a.vy + b.vy) * 0.2 - 60,
                ),
              );
              consumed.add(i);
              consumed.add(j);
              mergedThisStep = true;
              _merges += 1;
              _mergesByOutputId[newId] = (_mergesByOutputId[newId] ?? 0) + 1;
              _combo = (_combo + 1).clamp(1, 99);
              _score += fruits[newId].score * (1 + (_combo ~/ 6));
              if (newId > _maxFruitId) _maxFruitId = newId;
              break;
            } else {
              // 최종 단계(수박)끼리 만남 → 두 과일 모두 펑 사라지고
              // 큰 보너스 점수를 준 뒤 게임을 종료한다.
              consumed.add(i);
              consumed.add(j);
              mergedThisStep = true;
              _merges += 1;
              // 수박 두 개가 사라진 것도 “수박 1개 추가 생성”과 같은 빈도로
              // 챌린지 진행도에 반영한다(시각적으로 더 많이 만든 셈).
              _mergesByOutputId[a.id] =
                  (_mergesByOutputId[a.id] ?? 0) + 1;
              _combo = (_combo + 1).clamp(1, 99);
              _score += 500;
              _doubleMelonPop = true;
              megaMergeSfx = true;
              break;
            }
          }

          if (distSq >= minDist * minDist) continue;

          final dist = math.sqrt(distSq).clamp(0.0001, 1e6);
          final nx = dx / dist;
          final ny = dy / dist;
          final overlap = minDist - dist;

          // Baumgarte 위치 보정. 0.5 = 한 패스에 침투를 완전히 해결.
          // (양쪽이 각각 overlap*0.5씩 이동 → 합 overlap)
          const correction = 0.5;
          a.x -= nx * overlap * correction;
          a.y -= ny * overlap * correction;
          b.x += nx * overlap * correction;
          b.y += ny * overlap * correction;

          final rv = (b.vx - a.vx) * nx + (b.vy - a.vy) * ny;
          if (rv < 0) {
            // 접근 속도가 매우 작으면 반발을 흡수해 미세 진동을 막는다.
            final restitution = rv.abs() < 18 ? 0.0 : 0.14;
            final impulse = -(1 + restitution) * rv * 0.5;
            a.vx -= impulse * nx;
            a.vy -= impulse * ny;
            b.vx += impulse * nx;
            b.vy += impulse * ny;
          }

          // 수직 스택 안정성 깨기: 위 과일이 거의 똑바로 얹히려는 "낙하 도중"에만
          // 살짝 옆으로 밀어 완전한 수직 정렬을 깬다. 이미 정지된 과일에는 적용하지
          // 않아야 미세 진동이 생기지 않는다.
          if (ny.abs() > 0.92) {
            final upperIsA = a.y < b.y;
            final upper = upperIsA ? a : b;
            final lower = upperIsA ? b : a;
            final upperIdx = upperIsA ? i : j;
            final stillFalling = upper.vy > 6 && upper.vy < 90;
            if (!supported[upperIdx] &&
                stillFalling &&
                upper.vx.abs() < 14) {
              final lateral = upper.x - lower.x;
              final dir = lateral.abs() > 0.4
                  ? (lateral > 0 ? 1.0 : -1.0)
                  : (_rng.nextBool() ? 1.0 : -1.0);
              upper.vx += dir * 55 * dt;
            }
          }
        }
      }

      if (consumed.isNotEmpty) {
        final next = <_FruitBody>[];
        for (int i = 0; i < _fruits.length; i++) {
          if (!consumed.contains(i)) next.add(_fruits[i]);
        }
        next.addAll(spawned);
        _fruits
          ..clear()
          ..addAll(next);
      }
    }

    if (megaMergeSfx) {
      AudioService.I.playMegaMerge();
      _hapticMedium();
    } else if (mergedThisStep) {
      AudioService.I.playMerge();
      _hapticLight();
    }

    if (mergedThisStep) {
      _comboDecayFrames = 0;
    } else if (_combo > 0) {
      _comboDecayFrames += 1;
      if (_comboDecayFrames > 140) {
        _combo = 0;
        _comboDecayFrames = 0;
      }
    }

    // 수박 두 개가 만나 펑 사라진 경우, 잔여 처리 후 결과 화면으로 넘어간다.
    if (_doubleMelonPop) {
      _finishGame();
      return;
    }

    // LIMIT 라인 위에 과일이 있으면 위험 카운터를 누적한다.
    //
    // 속도 조건(`vy.abs() < 30`)은 의도적으로 빼두었다. 보드가 꽉 차면
    // 새 드롭이나 머지로 윗쪽 과일이 잠깐씩 튀어 속도가 30을 넘는데,
    // 매 프레임 리셋해버리면 카운터가 절대 누적되지 못해 가시적으로
    // 라인을 한참 넘긴 상태에서도 게임 오버가 트리거되지 않는다.
    //
    // 대신, 라인 아래로 내려간 프레임에는 즉시 0으로 만들지 않고
    // 빠르게 감쇠시켜 정상 드롭(체공 ~30프레임) 은 빠르게 상쇄되도록 했다.
    final overDanger =
        _fruits.any((f) => (f.y - f.radius) <= _dangerLineY);
    if (overDanger) {
      _dangerFrames += 1;
      if (_dangerFrames > 90) {
        _finishGame();
        return;
      }
    } else {
      _dangerFrames = math.max(0, _dangerFrames - 4);
    }

    _frame.value++;

    if (_score != beforeScore ||
        _maxFruitId != beforeMax ||
        _combo != beforeCombo) {
      if (mounted) setState(() {});
    }
  }

  void _finishGame() {
    if (_ended || !mounted) return;
    _ended = true;
    _ticker.stop();
    _elapsedTimer?.cancel();
    _persistAndOpenResult();
  }

  /// 좌상단 일시정지(=종료) 버튼. 진행 중이면 confirm 으로 보호.
  Future<void> _confirmQuit() async {
    if (_ended) {
      Navigator.pop(context);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('게임을 종료할까요?'),
        content: const Text(
            '지금 종료하면 현재 점수로 결과가 기록되고 홈으로 돌아갑니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('계속')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('종료', style: TextStyle(color: AppColors.accentCoral))),
        ],
      ),
    );
    if (ok == true) _finishGame();
  }

  Future<void> _persistAndOpenResult() async {
    final outcome = await LocalStore.I.recordGame(
      score: _score,
      maxFruitId: _maxFruitId,
      combo: _combo,
      merges: _merges,
      elapsedSec: _elapsed.inSeconds,
      mergesByOutputId: Map<int, int>.from(_mergesByOutputId),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: outcome.score,
          previousBest: outcome.previousBest,
          maxFruitId: _maxFruitId,
          combo: _combo,
          merges: _merges,
          time: _formatTime(_elapsed),
          isNewBest: outcome.isNewBest,
          coinsEarned: outcome.coinsEarned,
          challengeCompleted: outcome.challengeCompleted,
          challengeRewardCoins: outcome.challengeRewardCoins,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sidePad = EdgeInsets.symmetric(horizontal: 16);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: Column(
              children: [
                Padding(padding: sidePad, child: _buildTopHud()),
                const SizedBox(height: 6),
                Padding(padding: sidePad, child: _buildSecondaryHud()),
                const SizedBox(height: 4),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: _boardWidth / _boardHeight,
                    child: _buildBoard(),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(padding: sidePad, child: _buildEvolutionChain()),
                const SizedBox(height: 8),
                Padding(
                  padding: sidePad,
                  child: PopButton(
                    height: 54,
                    width: double.infinity,
                    onTap: _finishGame,
                    child: const Text(
                      '게임 종료',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return Row(
      children: [
        PopButton(
          variant: PopButtonVariant.ghost,
          height: 40,
          width: 40,
          padding: EdgeInsets.zero,
          onTap: _confirmQuit,
          child: const AppIcon(IconKind.pause),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SCORE',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.inkLight,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fmt(_score),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD9588A),
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SoftCard(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'NEXT',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.inkLight,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 32,
                height: 32,
                child: FruitWidget(id: _nextQueuedId, size: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryHud() {
    return Row(
      children: [
        _miniHud('⏱', _formatTime(_elapsed)),
        const SizedBox(width: 8),
        _miniHud('🔥', '×$_combo'),
        const Spacer(),
        Text(
          '수박까지 ${math.max(0, 10 - _maxFruitId)}단계',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) => _onPointerDown(e, constraints),
          onPointerMove: (e) => _onPointerMove(e, constraints),
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: ClipRect(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF9F5), Color(0xFFFFEEE5)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _BoardPainter(
                          fruits: _fruits,
                          previewX: _previewX,
                          previewId: _handId,
                          previewRadius: _radiusForId(_handId),
                          repaint: _frame,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                  if (SkinCatalog.boardOverlay(LocalStore.I.equippedSkin) != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: SkinCatalog.boardOverlay(LocalStore.I.equippedSkin)!,
                          ),
                        ),
                      ),
                    ),
                  if (_previewX == null)
                    Positioned(
                      top: (_dangerLineY * constraints.maxHeight / _boardHeight) + 4,
                      right: (_wallInset + 6) * constraints.maxWidth / _boardWidth,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.candyPink.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'LIMIT',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEvolutionChain() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < 11; i++) _buildChainItem(i),
        ],
      ),
    );
  }

  Widget _buildChainItem(int i) {
    final isReached = i < _maxFruitId;
    final isCurrent = i == _maxFruitId;
    final isNext = i == _maxFruitId + 1;

    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.candyPink, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.candyPink.withValues(alpha: 0.55),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: FruitWidget(id: i, size: 20),
      );
    }

    if (isReached) {
      return FruitWidget(id: i, size: 18);
    }

    if (isNext) {
      return Opacity(
        opacity: 0.5,
        child: FruitWidget(id: i, size: 18),
      );
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.inkLight.withValues(alpha: 0.22),
      ),
    );
  }

  Widget _miniHud(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              // 숫자 폭을 등폭으로 고정해 시간 변화 시 좌우 흔들림을 막는다.
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.fruits,
    required this.previewX,
    required this.previewId,
    required this.previewRadius,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_FruitBody> fruits;
  final double? previewX;
  final int previewId;
  final double previewRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / _boardWidth;
    final scaleY = size.height / _boardHeight;

    final dangerPaint = Paint()
      ..color = AppColors.candyPink.withValues(alpha: 0.45)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(_wallInset * scaleX, _dangerLineY * scaleY),
      Offset(size.width - _wallInset * scaleX, _dangerLineY * scaleY),
      dangerPaint,
    );

    // 미리보기: LIMIT 라인 위쪽에 다음 과일을 살짝 흐리게 표시 + 가이드 점선
    if (previewX != null) {
      final px = previewX! * scaleX;
      final pr = previewRadius * scaleX;
      // 드롭 시작 좌표와 동일한 보드 y 사용해 손을 떼었을 때 순간이동을 막는다.
      final previewBoardY =
          math.max(previewRadius + 4, _dangerLineY - previewRadius - 6);
      final previewCanvasY = previewBoardY * scaleY;

      // 가이드 세로 점선
      final guidePaint = Paint()
        ..color = AppColors.candyPink.withValues(alpha: 0.55)
        ..strokeWidth = 1.5;
      const dash = 6.0;
      const gap = 4.0;
      double y = previewCanvasY + pr + 2;
      final yMax = size.height - _floorInset * scaleY;
      while (y < yMax) {
        canvas.drawLine(
          Offset(px, y),
          Offset(px, math.min(y + dash, yMax)),
          guidePaint,
        );
        y += dash + gap;
      }

      // 미리보기 과일 (반투명)
      canvas.saveLayer(
        Rect.fromCircle(center: Offset(px, previewCanvasY), radius: pr * 1.3),
        Paint()..color = const Color(0xB3FFFFFF),
      );
      paintFruitOnCanvas(canvas, previewId, Offset(px, previewCanvasY), pr);
      canvas.restore();
    }

    for (final f in fruits) {
      final cx = f.x * scaleX;
      final cy = f.y * scaleY;
      final r = f.radius * scaleX;
      paintFruitOnCanvas(canvas, f.id, Offset(cx, cy), r);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) =>
      oldDelegate.previewX != previewX ||
      oldDelegate.previewId != previewId ||
      oldDelegate.previewRadius != previewRadius;
}
