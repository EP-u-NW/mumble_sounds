/// Provides access to sound samples which might be useful in a voip app.
///
/// All samples can be accessed in three different sound formates and with
/// three different sample rates.
library mumble_sounds;

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const int _wavHeaderSize = 44;

/// Used to describe the audio format of samples.
enum AudioFormat {
  /// A wav file with header.
  wav,

  /// Signed 16-bit little endian integers without any header.
  s16le,

  /// 32-bit little endian floating point numbers without any header.
  f32le
}

/// Speficies all possible sample rates in Hz.
enum AudioSampleRate {
  /// Sample rate of 16000hz.
  hz16000,

  /// Sample rate of 44100hz.
  hz44100,

  /// Sample rate of 48000hz.
  hz48000
}

String _audioFormatToString(AudioFormat audioFormat) {
  switch (audioFormat) {
    case AudioFormat.wav:
      return 'wav';
    case AudioFormat.s16le:
      return 's16le';
    case AudioFormat.f32le:
      return 'f32le';
  }
}

String _audioSampleRateToString(AudioSampleRate audioSampleRate) {
  switch (audioSampleRate) {
    case AudioSampleRate.hz16000:
      return '16000';
    case AudioSampleRate.hz44100:
      return '44100';
    case AudioSampleRate.hz48000:
      return '48000';
  }
}

/// Used to represent the [mumble sound samples](https://github.com/mumble-voip/mumble/tree/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples).
class SoundSample {
  /// Represents [Critical](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/Critical.ogg).
  static const SoundSample critical = const SoundSample._('Critical');

  /// Represents [Off](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/Off.ogg).
  static const SoundSample off = const SoundSample._('Off');

  /// Represents [On](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/On.ogg).
  static const SoundSample on = const SoundSample._('On');

  /// Represents [PermissionDenied](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/PermissionDenied.ogg).
  static const SoundSample permissionDenied =
      const SoundSample._('PermissionDenied');

  /// Represents [RecordingStateChanged](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/RecordingStateChanged.ogg).
  static const SoundSample recordingStateChanged =
      const SoundSample._('RecordingStateChanged');

  /// Represents [SelfMutedDeafened](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/SelfMutedDeafened.ogg).
  static const SoundSample selfMutedDeafened =
      const SoundSample._('SelfMutedDeafened');

  /// Represents [ServerConnected](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/ServerConnected.ogg).
  static const SoundSample serverConnected =
      const SoundSample._('ServerConnected');

  /// Represents [ServerDisconnected](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/ServerDisconnected.ogg).
  static const SoundSample serverDisconnected =
      const SoundSample._('ServerDisconnected');

  /// Represents [TextMessage](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/TextMessage.ogg).
  static const SoundSample textMessage = const SoundSample._('TextMessage');

  /// Represents [UserJoinedChannel](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/UserJoinedChannel.ogg).
  static const SoundSample userJoinedChannel =
      const SoundSample._('UserJoinedChannel');

  /// Represents [UserKickedYouOrByYou](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/UserKickedYouOrByYou.ogg).
  static const SoundSample userKickedYouOrByYou =
      const SoundSample._('UserKickedYouOrByYou');

  /// Represents [UserLeftChannel](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/UserLeftChannel.ogg).
  static const SoundSample userLeftChannel =
      const SoundSample._('UserLeftChannel');

  /// Represents [UserMutedYouOrByYou](https://github.com/mumble-voip/mumble/blob/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples/UserMutedYouOrByYou.ogg).
  static const SoundSample userMutedYouOrByYou =
      const SoundSample._('UserMutedYouOrByYou');

  /// The name of this sample.
  final String name;

  const SoundSample._(this.name);

  String _key(AudioFormat format, AudioSampleRate sampleRate) {
    format = format == AudioFormat.s16le ? AudioFormat.wav : format;
    return 'packages/mumble_sounds/assets/${name}_${_audioSampleRateToString(sampleRate)}.${_audioFormatToString(format)}';
  }

  /// Loads the sample in the given [format] and with the given [sampleRate].
  ///
  /// If [context] is not `null` the [DefaultAssetBundle.of] [context] will be used,
  /// if it is `null` the [rootBundle] is used instead.
  Future<Uint8List> load(
      {BuildContext? context,
      AudioFormat format = AudioFormat.wav,
      AudioSampleRate sampleRate = AudioSampleRate.hz48000}) async {
    AssetBundle bundle =
        context != null ? DefaultAssetBundle.of(context) : rootBundle;
    ByteData data = await bundle.load(_key(format, sampleRate));
    int offset = format == AudioFormat.s16le ? _wavHeaderSize : 0;
    return data.buffer
        .asUint8List(data.offsetInBytes + offset, data.lengthInBytes - offset);
  }

  /// Behaves exactly as [load], but returns the bytes as stream.
  ///
  /// All lists in this stream are actually [Uint8List], so this stream
  /// can safely be casted.
  Stream<List<int>> stream(
      {BuildContext? context,
      AudioFormat format = AudioFormat.wav,
      AudioSampleRate sampleRate = AudioSampleRate.hz48000}) async* {
    List<int> data =
        await load(context: context, format: format, sampleRate: sampleRate);
    yield data;
  }
}
