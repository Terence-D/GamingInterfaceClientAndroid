import 'dart:developer';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;

class CompressedFileService {
  /// Extracts the supplied compressed file path to the supplied path
  /// 0 on success, sub zero on fail
  static int extract(String file, String tempPath) {
    try {
      final File compressedFile = new File(file);
      // Read the Zip file from disk.
      final bytes = compressedFile.readAsBytesSync();
      // Decode the Zip file
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract the contents of the Zip archive to the temp path.
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File(path.join(tempPath, filename))
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        }
      }
      return 0;
    } on Exception catch (e) {
      log(e.toString());
      return -1;
    }
  }

  /// Creates a compressed file
  /// folderToCompress is the folder containing the files we want compressed
  /// destinationFolder is the destination folder
  /// exportFile is the file we are creating
  /// Returns a File of the created folder, or null on error
  static Future<int> compressFolder(String folderToCompress, String destinationFolder, String exportFile) async {
    //add the zip extension if required
    try {
      if (!exportFile.endsWith(".zip"))
        exportFile += ".zip";

      Directory source = new Directory(folderToCompress);

      ZipFileEncoder zipFileEncoder = ZipFileEncoder();
      zipFileEncoder.create(path.join(destinationFolder, exportFile));
      zipFileEncoder.addDirectory(source);

      zipFileEncoder.close();
    } on Exception catch (e) {
      log(e.toString());
      return -1;
    }
    return 0;
  }
}
