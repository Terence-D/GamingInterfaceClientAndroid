package ca.coffeeshopstudio.gaminginterfaceclient.utils;

import android.util.Base64;

import java.nio.charset.StandardCharsets;
import java.security.Key;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

/**
 Copyright [2019] [Terence Doerksen]

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
public class Encryption {
    private final String METHOD = "AES/CBC/PKCS5Padding";

    public String encrypt(String valueToEncrypt) throws Exception
    {
        Key key = generateKey();
        Cipher cipher = Cipher.getInstance(METHOD);
        cipher.init(Cipher.ENCRYPT_MODE, key);
        byte [] encryptedByteValue = cipher.doFinal(valueToEncrypt.getBytes(StandardCharsets.UTF_8));

        return Base64.encodeToString(encryptedByteValue, Base64.DEFAULT);
    }

    public String decrypt(String encryptedString) throws Exception
    {
        Key key = generateKey();
        Cipher cipher = Cipher.getInstance(METHOD);
        cipher.init(Cipher.DECRYPT_MODE, key);
        byte[] decryptedValue64 = Base64.decode(encryptedString, Base64.DEFAULT);
        byte [] decryptedByteValue = cipher.doFinal(decryptedValue64);
        return new String(decryptedByteValue, StandardCharsets.UTF_8);

    }


    private Key generateKey() throws Exception
    {
        String ENCRYPT_KEY = "x8crOReGeKjalZmtpnGm";
        return new SecretKeySpec(ENCRYPT_KEY.getBytes(), METHOD);
    }
}
