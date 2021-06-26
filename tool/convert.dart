import 'dart:io';

void main(List<String> args) async {
  List<File> files = [];
  await for (FileSystemEntity entity in new Directory('./input').list()) {
    if (entity is File) {
      files.add(entity);
    }
  }
  List<String> outputs =
      (await Future.wait(files.map(convertFile))).flatten().toList();
  print(outputs);
}

Future<List<String>> convertFile(File file) async {
  List<Future<ProcessResult>> futures = [];
  List<String> paths = [];
  List<int> ar = [16000, 44100, 48000];
  List<String> f = ['wav', 'f32le'];
  for (int i = 0; i < ar.length; i++) {
    for (int j = 0; j < f.length; j++) {
      List<String> args = [
        '-i',
        file.path,
        '-ar',
        ar[i].toString(),
        '-ac',
        '1',
        '-f',
        f[j]
      ];
      if (j == 0) {
        args.add('-bitexact');
      }
      String outPath = file.path.substring(0, file.path.lastIndexOf('.')) +
          '_' +
          ar[i].toString() +
          '.' +
          f[j];
      outPath = outPath.replaceAll('\\', '/').replaceAll('./input/', 'assets/');
      args.add(outPath);
      paths.add(outPath);
      futures.add(Process.run('ffmpeg', args));
    }
  }
  await Future.wait(futures);
  return paths;
}

extension Flatten<T> on List<List<T>> {
  Iterable<T> flatten() sync* {
    for (List<T> sublist in this) {
      yield* sublist;
    }
  }
}
