import 'package:flutter/material.dart';
import 'flutter_radio_player.dart';

import 'dart:async';

class _RadioStatus {
  final String _status;

  _RadioStatus._(this._status);
}

abstract class RadioPage<MyState extends StatefulWidget>
    extends State<MyState> {

  final String _appName;
  final String _subTitle;
  final String _streamUrl;

  RadioPage({this.loadingText = 'Завантаження...', String appName, String subTitle, String streamUrl,}) : streamingController = FlutterRadioPlayer(), _appName = appName, _streamUrl = streamUrl, _subTitle = subTitle;

  static String _currentSong;
  static bool _gettingSong;
  static bool _isInitiated;

  final String loadingText;

  String get currentSong {
    final int criticalLength = 70;
    if (_currentSong == null || _currentSong.length > criticalLength)
      return loadingText;
    else
      return _currentSong;
  }

  void _initStream() async {
    streamingController.init(_appName, _subTitle, _streamUrl, 'false');
    _isInitiated = true;
  }

  final FlutterRadioPlayer streamingController;

  static final _RadioStatus loading = _RadioStatus._('loading');
  static final _RadioStatus playing = _RadioStatus._('playing');
  static final _RadioStatus paused = _RadioStatus._('paused');

  StreamSubscription _periodicSub;

  @override
  void dispose() {
    _periodicSub.cancel();
    super.dispose();
  }

  _RadioStatus _handleStatus(String status) {
    switch (status) {
      case FlutterRadioPlayer.flutter_radio_playing:
        _statusSaved = playing;
        return playing;
        break;
      case FlutterRadioPlayer.flutter_radio_loading:
        _statusSaved = loading;
        return loading;
        break;
      case FlutterRadioPlayer.flutter_radio_stopped:
        _initStream();
        break;
      case 'null':
          return _statusSaved;
        break;
    }
    _statusSaved = paused;
    return paused;
  }

  @override
  void initState() {
    super.initState();
    if (_statusSaved == null) _statusSaved = paused;
    if (_gettingSong == null) _gettingSong = false;
    if (_isInitiated == null) _isInitiated = false;
    if (_currentSong == null) {
      _currentSong = null;
    }
    if (!_isInitiated)
      _initStream();
    _getCurrentSong();
    _periodicSub = new Stream.periodic(const Duration(seconds: 15))
        .take(10000)
        .listen((_) => _getCurrentSong());
  }

  static _RadioStatus _statusSaved;

  void _getCurrentSong() async {
    if (_gettingSong) return;
    _gettingSong = true;
    _currentSong = await getSong();
    if (mounted) setState(() {});
    _gettingSong = false;
  }

  Widget getStream() {
    return StreamBuilder<Object>(
        stream: streamingController.isPlayingStream,
        initialData: streamingController.myStatus,
        builder: (context, snapshot) {
          _RadioStatus state;
          if (snapshot.hasData)
            state = _handleStatus(snapshot.data);
          return buildBody(state);
        });
  }

  Widget buildBody(_RadioStatus state);

  Future<String> getSong();
}