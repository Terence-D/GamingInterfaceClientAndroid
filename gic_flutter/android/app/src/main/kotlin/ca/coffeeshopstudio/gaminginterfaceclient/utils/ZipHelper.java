package ca.coffeeshopstudio.gaminginterfaceclient.utils;

import android.os.ParcelFileDescriptor;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
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

    public static void zip(String[] filesToZip, ParcelFileDescriptor pfd) throws IOException {

        FileOutputStream fileOutputStream = new FileOutputStream(pfd.getFileDescriptor());
        ZipOutputStream out = new ZipOutputStream(new BufferedOutputStream(fileOutputStream));

        byte data[] = new byte[BUFFER_SIZE];
        BufferedInputStream origin;
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
        fileOutputStream.close();
        pfd.close();
    }

    public static boolean unzip(InputStream zipFile, String destinationDir) throws IOException {
        File f = new File(destinationDir);
        if (!f.isDirectory()) {
            f.mkdirs();
        }

        //first validate
        boolean validZip = false;
        byte[] buffer = new byte[8192];
        //now extract
        ZipInputStream zipInputStream = new ZipInputStream(zipFile);
        ZipEntry zipEntry;
        int count;
        while ((zipEntry = zipInputStream.getNextEntry()) != null) {
            String path = destinationDir + File.separator + zipEntry.getName();
            if (path.contains("data.json")) {
                validZip = true;
            }

// Unnecessary for our needs
//            if (zipEntry.isDirectory()) {
//                File unzipFile = new File(path);
//                if (!unzipFile.isDirectory()) {
//                    unzipFile.mkdirs();
//                }
//            } else {
            FileOutputStream fileOutputStream = new FileOutputStream(path, false);

            try {
                while ((count = zipInputStream.read(buffer)) != -1)
                    fileOutputStream.write(buffer, 0, count);
            } finally {
                fileOutputStream.close();
            }
//            for (int c = zipInputStream.read(buffer); c != -1; c = zipInputStream.read(buffer)) {
//                fileOutputStream.write(c);
//            }
            zipInputStream.closeEntry();
            fileOutputStream.close();
//            }
        }
        zipInputStream.close();

        return validZip;
    }
}
