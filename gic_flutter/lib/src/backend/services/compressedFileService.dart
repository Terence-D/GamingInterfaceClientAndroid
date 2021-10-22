import 'dart:developer';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;

class CompressedFileService {
  /// Extracts the supplied compressed file path to the supplied path
  /// screen id saved on success, empty string on fail
  static String extract(String file, String tempPath) {
    String fileId = "";
    try {
      final File compressedFile = File(file);
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
        fileId = path.split(filename)[0];
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    return fileId;
  }

  /// Creates a compressed file
  /// folderToCompress is the folder containing the files we want compressed
  /// destinationFolder is the destination folder
  /// exportFile is the file we are creating
  /// Returns 0 on success, -1 on error
  static Future<int> compressFolder(String folderToCompress, String destinationFolder, String exportFile) async {
    //add the zip extension if required
    try {
      if (!exportFile.endsWith(".zip")) {
        exportFile += ".zip";
      }

      Directory source = Directory(folderToCompress);

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
