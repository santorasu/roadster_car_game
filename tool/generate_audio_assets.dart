// ignore_for_file: avoid_print
import 'dart:io';

import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  final dir = Directory('assets/audio');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // 1. Generate UI tap sound (120ms dual frequency chirp)
  File('assets/audio/sfx_ui_tap.wav').writeAsBytesSync(
    _generateWav(
      durationSeconds: 0.12,
      sampleRate: 22050,
      generator: (t) {
        final env = math.exp(-25.0 * t);
        final freq = 880.0 + 880.0 * (1.0 - t / 0.12);
        return env * (0.6 * math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(2 * math.pi * (freq * 1.5) * t));
      },
    ),
  );

  // 2. Generate Collision sound (450ms punch + crunchy noise + bass thump)
  final random = math.Random(42);
  File('assets/audio/sfx_collision.wav').writeAsBytesSync(
    _generateWav(
      durationSeconds: 0.45,
      sampleRate: 22050,
      generator: (t) {
        final env = math.exp(-9.0 * t);
        final bass = math.sin(2 * math.pi * (75.0 * math.exp(-5.0 * t)) * t);
        final noise = (random.nextDouble() * 2.0 - 1.0) * math.exp(-15.0 * t);
        final metal = math.sin(2 * math.pi * 320.0 * t) * math.exp(-12.0 * t);
        return env * (0.65 * bass + 0.35 * noise + 0.25 * metal);
      },
    ),
  );

  // 3. Generate Verge Spark sound (250ms crackling electricity)
  File('assets/audio/sfx_verge_spark.wav').writeAsBytesSync(
    _generateWav(
      durationSeconds: 0.25,
      sampleRate: 22050,
      generator: (t) {
        final env = (1.0 - t / 0.25) * math.exp(-4.0 * t);
        final buzz = math.sin(2 * math.pi * 180.0 * t) > 0 ? 0.3 : -0.3;
        final hiss = (random.nextDouble() * 2.0 - 1.0) * 0.4;
        return env * (buzz + hiss);
      },
    ),
  );

  // 4. Generate Engine Loop (1.2s electric turbine whine loop)
  File('assets/audio/sfx_engine_loop.wav').writeAsBytesSync(
    _generateWav(
      durationSeconds: 1.2,
      sampleRate: 22050,
      generator: (t) {
        // Smooth loop boundary crossfade
        final fade = math.sin(math.pi * t / 1.2);
        final baseFreq = 160.0;
        final h1 = 0.5 * math.sin(2 * math.pi * baseFreq * t);
        final h2 = 0.3 * math.sin(2 * math.pi * (baseFreq * 2.0) * t);
        final h3 = 0.15 * math.sin(2 * math.pi * (baseFreq * 4.0) * t);
        final hum = 0.1 * math.sin(2 * math.pi * 60.0 * t);
        return fade * (h1 + h2 + h3 + hum);
      },
    ),
  );

  // 5. Generate BGM Cyber Drive Loop (6.0s melodic synth wave groove at 120 BPM)
  File('assets/audio/bgm_cyber_drive.wav').writeAsBytesSync(
    _generateWav(
      durationSeconds: 6.0,
      sampleRate: 22050,
      generator: (t) {
        // Loop window fade at edges (50ms)
        double edgeFade = 1.0;
        if (t < 0.05) edgeFade = t / 0.05;
        if (t > 5.95) edgeFade = (6.0 - t) / 0.05;

        // Bassline sequence in D minor: D2 (73.4Hz), F2 (87.3Hz), C2 (65.4Hz), G2 (98.0Hz)
        final beat = (t * 2.0); // 120 BPM = 2 beats per second
        final bar = (beat / 4.0) % 4.0;
        double bassFreq = 73.42;
        if (bar >= 1.0 && bar < 2.0) bassFreq = 87.31;
        if (bar >= 2.0 && bar < 3.0) bassFreq = 65.41;
        if (bar >= 3.0) bassFreq = 97.99;

        final beatFract = beat % 1.0;
        final kickEnv = math.exp(-12.0 * beatFract);
        final kick = kickEnv * math.sin(2 * math.pi * (110.0 * math.exp(-20.0 * beatFract)) * (beatFract / 2.0));

        // Sub bass
        final bassEnv = 0.8 + 0.2 * math.sin(2 * math.pi * beat);
        final bass = bassEnv * (0.5 * math.sin(2 * math.pi * bassFreq * t) + 0.25 * math.sin(2 * math.pi * (bassFreq * 2) * t));

        // Arp synth melody: D4 (293.66), F4 (349.23), A4 (440.0), C5 (523.25)
        final arpStep = (t * 8.0).floor() % 4;
        final arpFreqs = [293.66, 349.23, 440.0, 523.25];
        final arpFreq = arpFreqs[arpStep];
        final arpFract = (t * 8.0) % 1.0;
        final arpEnv = math.exp(-6.0 * arpFract);
        final arp = arpEnv * 0.25 * (math.sin(2 * math.pi * arpFreq * t) + 0.15 * math.sin(2 * math.pi * (arpFreq * 2) * t));

        return edgeFade * (0.5 * kick + 0.45 * bass + 0.3 * arp);
      },
    ),
  );

  print('Audio assets generated successfully in assets/audio/');
}

Uint8List _generateWav({
  required double durationSeconds,
  required int sampleRate,
  required double Function(double t) generator,
}) {
  final numSamples = (durationSeconds * sampleRate).toInt();
  final subChunk2Size = numSamples * 2; // 16-bit mono = 2 bytes per sample
  final chunkSize = 36 + subChunk2Size;

  final byteData = ByteData(44 + subChunk2Size);

  // RIFF Chunk
  byteData.setUint8(0, 0x52); // 'R'
  byteData.setUint8(1, 0x49); // 'I'
  byteData.setUint8(2, 0x46); // 'F'
  byteData.setUint8(3, 0x46); // 'F'
  byteData.setUint32(4, chunkSize, Endian.little);
  byteData.setUint8(8, 0x57);  // 'W'
  byteData.setUint8(9, 0x41);  // 'A'
  byteData.setUint8(10, 0x56); // 'V'
  byteData.setUint8(11, 0x45); // 'E'

  // 'fmt ' Chunk
  byteData.setUint8(12, 0x66); // 'f'
  byteData.setUint8(13, 0x6D); // 'm'
  byteData.setUint8(14, 0x74); // 't'
  byteData.setUint8(15, 0x20); // ' '
  byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
  byteData.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
  byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
  byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate (SampleRate * NumChannels * BitsPerSample/8)
  byteData.setUint16(32, 2, Endian.little);  // BlockAlign (NumChannels * BitsPerSample/8)
  byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16 bits)

  // 'data' Chunk
  byteData.setUint8(36, 0x64); // 'd'
  byteData.setUint8(37, 0x61); // 'a'
  byteData.setUint8(38, 0x74); // 't'
  byteData.setUint8(39, 0x61); // 'a'
  byteData.setUint32(40, subChunk2Size, Endian.little);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final val = generator(t).clamp(-1.0, 1.0);
    final int16Val = (val * 32767).toInt().clamp(-32768, 32767);
    byteData.setInt16(44 + i * 2, int16Val, Endian.little);
  }

  return byteData.buffer.asUint8List();
}
