/// Provides access to sound samples which might be useful in a voip app.
///
/// All samples can be accessed in three different sound formates and with
/// three different sample rates.
library mumble_sounds;

import 'dart:async';
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

/// Returns the name of [audioFromat].
String audioFormatToString(AudioFormat audioFormat) {
  switch (audioFormat) {
    case AudioFormat.wav:
      return 'wav';
    case AudioFormat.s16le:
      return 's16le';
    case AudioFormat.f32le:
      return 'f32le';
  }
}

/// Converts the [audioSampleRate] into a numerical value.
int audioSampleRateToInt(AudioSampleRate audioSampleRate) {
  switch (audioSampleRate) {
    case AudioSampleRate.hz16000:
      return 16000;
    case AudioSampleRate.hz44100:
      return 44100;
    case AudioSampleRate.hz48000:
      return 48000;
  }
}

/// Used to represent the [mumble sound samples](https://github.com/mumble-voip/mumble/tree/1bcbb79706a3aa8f7127469f0347bebd6d812c32/samples).
///
/// All sound samples are mono (one channel)!
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
    return 'packages/mumble_sounds/assets/${name}_${audioSampleRateToInt(sampleRate)}.${audioFormatToString(format)}';
  }

  /// Loads the sample in the given [format] and with the given [sampleRate].
  /// The sample will always be mono (one channel)!
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

  /// Streams a sample in approximated real time in frames of duration [frameTimeMs].
  /// The streamed data will always be mono (one channel)!
  ///
  /// The data of this sample are loaded into memory and afterwards fragmented to sublists,
  /// so that each sublists holds data to play for [frameTimeMs] with respect to the [format]
  /// and [sampleRate]. If the last sublist is not long enought it is filled with zeroes.
  ///
  /// Approximated real time means that the stream yields the sublists, while waiting
  /// [frameTimeMs] between yields. For waiting, a [Timer] is used, which is more precise
  /// than [Future.delayed].
  ///
  /// Only [AudioFormat.f32le] and [AudioFormat.s16le] can be streamed, [AudioFormat.wav]
  /// will result in an [ArgumentError]!
  Stream<Uint8List> stream(
      {BuildContext? context,
      required int frameTimeMs,
      AudioFormat format = AudioFormat.s16le,
      AudioSampleRate sampleRate = AudioSampleRate.hz48000}) {
    int bytesPerSample;
    switch (format) {
      case AudioFormat.wav:
        throw new ArgumentError(
            'Only ${AudioFormat.f32le} and ${AudioFormat.s16le} can be streamed!');
      case AudioFormat.s16le:
        bytesPerSample = 2;
        break;
      case AudioFormat.f32le:
        bytesPerSample = 4;
        break;
    }
    int bytesPerFragment = bytesPerSample *
        (audioSampleRateToInt(sampleRate) * frameTimeMs) ~/
        1000;
    Timer? t;
    StreamController<Uint8List>? controller =
        new StreamController<Uint8List>(onCancel: t?.cancel);
    load(format: format, sampleRate: sampleRate).then((Uint8List value) {
      List<Uint8List> data = value.fragment(bytesPerFragment).toList();
      if (!controller.isClosed && data.isNotEmpty) {
        controller.add(data[0]);
        if (data.length > 1) {
          int index = 1;
          t = new Timer.periodic(new Duration(milliseconds: frameTimeMs),
              (Timer t) {
            if (t.isActive) {
              controller.add(data[index]);
              index++;
              if (index == data.length) {
                t.cancel();
                controller.close();
              }
            }
          });
        }
      }
    });
    return controller.stream;
  }
}

extension _Fragment on Uint8List {
  Iterable<Uint8List> fragment(int bytesPerFragment) sync* {
    int index = 0;
    while (index + bytesPerFragment <= length) {
      yield buffer.asUint8List(offsetInBytes + index, bytesPerFragment);
      index += bytesPerFragment;
    }
    int leftOver = length - index;
    if (leftOver != 0) {
      Uint8List filledUp = new Uint8List(bytesPerFragment);
      filledUp.setRange(0, leftOver, this, index);
      yield filledUp;
    }
  }
}
