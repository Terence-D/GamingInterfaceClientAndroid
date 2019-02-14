package ca.coffeeshopstudio.gaminginterfaceclient.utils;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

/**
 * Copyright [2019] [Terence Doerksen]
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public class ZipHelper {
    private static int BUFFER_SIZE = 6 * 1024;

    public static void zip(String[] filesToZip, String zipFileName) throws IOException {
        BufferedInputStream origin;
        FileOutputStream destination = new FileOutputStream(zipFileName);
        ZipOutputStream out = new ZipOutputStream(new BufferedOutputStream(destination));
        byte data[] = new byte[BUFFER_SIZE];

        for (int i = 0; i < filesToZip.length; i++) {
            FileInputStream fileInputStream = new FileInputStream(filesToZip[i]);
            origin = new BufferedInputStream(fileInputStream, BUFFER_SIZE);

            ZipEntry entry = new ZipEntry(filesToZip[i].substring(filesToZip[i].lastIndexOf("/") + 1));
            out.putNextEntry(entry);
            int count;

            while ((count = origin.read(data, 0, BUFFER_SIZE)) != -1) {
                out.write(data, 0, count);
            }
            origin.close();
        }
        out.close();
    }

    public void unzip(String zipFile, String destinationDir) throws IOException {
        File f = new File(destinationDir);
        if (!f.isDirectory()) {
            f.mkdirs();
        }

        ZipInputStream zipInputStream = new ZipInputStream(new FileInputStream(zipFile));
        ZipEntry zipEntry;

        while ((zipEntry = zipInputStream.getNextEntry()) != null) {
            String path = destinationDir + File.separator + zipEntry.getName();

// Unnecessary for our needs
//            if (zipEntry.isDirectory()) {
//                File unzipFile = new File(path);
//                if (!unzipFile.isDirectory()) {
//                    unzipFile.mkdirs();
//                }
//            } else {
            FileOutputStream fileOutputStream = new FileOutputStream(path, false);

            for (int c = zipInputStream.read(); c != -1; c = zipInputStream.read()) {
                fileOutputStream.write(c);
            }
            zipInputStream.closeEntry();
            fileOutputStream.close();
//            }
        }
        zipInputStream.close();
    }
}
