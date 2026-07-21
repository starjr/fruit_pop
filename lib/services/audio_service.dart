import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

import 'local_store.dart';

/// 배경음·효과음. `LocalStore` 의 BGM/SFX 스위치를 따른다.
class AudioService with WidgetsBindingObserver {
  AudioService._();
  static final AudioService I = AudioService._();

  static const double _bgmVol = 0.42;
  static const double _sfxDropVol = 0.5;
  static const double _sfxMergeVol = 0.52;
  static const double _sfxMegaVol = 0.58;

  final AudioPlayer _bgm = AudioPlayer();
  final List<AudioPlayer> _sfxPool =
      List<AudioPlayer>.generate(4, (_) => AudioPlayer());
  int _sfxRound = 0;

  bool _initialized = false;
  bool _gameSession = false;
  bool _observing = false;

  Future<void> init() async {
    if (_initialized) return;
    await _bgm.setReleaseMode(ReleaseMode.loop);
    _initialized = true;
  }

  /// 설정 화면 등에서 토글 직후 호출.
  Future<void> applySettings() => _syncBgm();

  /// 인게임 BGM 구간 시작(게임 화면 `initState`).
  Future<void> setGameSessionActive(bool active) async {
    _gameSession = active;
    await _syncBgm();
  }

  Future<void> _syncBgm() async {
    await init();
    final want = _gameSession && LocalStore.I.bgmEnabled;
    if (!want) {
      await _bgm.stop();
      return;
    }
    if (_bgm.state == PlayerState.playing) return;
    await _bgm.play(AssetSource('audio/bgm_game.wav'), volume: _bgmVol);
  }

  void attachLifecycleObserver() {
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  void detachLifecycleObserver() {
    if (!_observing) return;
    WidgetsBinding.instance.removeObserver(this);
    _observing = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_bgm.pause());
    } else if (state == AppLifecycleState.resumed) {
      if (_gameSession && LocalStore.I.bgmEnabled) {
        unawaited(_bgm.resume());
      }
    }
  }

  AudioPlayer _nextSfxPlayer() {
    final p = _sfxPool[_sfxRound % _sfxPool.length];
    _sfxRound++;
    return p;
  }

  void playDrop() {
    if (!LocalStore.I.sfxEnabled) return;
    unawaited(_playAsset(_nextSfxPlayer(), 'audio/sfx_drop.wav', _sfxDropVol));
  }

  void playMerge() {
    if (!LocalStore.I.sfxEnabled) return;
    unawaited(_playAsset(_nextSfxPlayer(), 'audio/sfx_merge.wav', _sfxMergeVol));
  }

  void playMegaMerge() {
    if (!LocalStore.I.sfxEnabled) return;
    unawaited(_playAsset(_nextSfxPlayer(), 'audio/sfx_mega.wav', _sfxMegaVol));
  }

  Future<void> _playAsset(AudioPlayer p, String path, double volume) async {
    await init();
    try {
      await p.stop();
      await p.play(AssetSource(path), volume: volume);
    } catch (_) {
      // 에셋 누락·시뮬레이터 오디오 실패 등은 게임 진행을 막지 않는다.
    }
  }

  Future<void> dispose() async {
    detachLifecycleObserver();
    await _bgm.dispose();
    for (final p in _sfxPool) {
      await p.dispose();
    }
  }
}
