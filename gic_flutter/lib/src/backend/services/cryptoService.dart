import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class CryptoService {
    static final String salt = 'f-NS5Qnhn@sdC%_7RAD3K3GmYU5ZHW*\$';
    static final String passphrase = 'WCu8rer-kuJ58UZKcz*ABL\$?&=@pw=_d4L\$tr^cfFgdad-NxCUXRUz8LL*_5z?Xm^zFMP4FXRUvdEhNH=kwKJp8^-D3Uf8AG?6DtKrQH%HYC*c6KqW&XR2gF7hndfu+u';
    static final String iv = 'kYW-*%n^t!JkV3FU';
    static final int iterations = 100;
    static final int size = 32;
    static const Mode = 'CBC';

    static Future<String> encrypt(String toEncrypt) async {
        Uint8List derivedKey = _buildKey();
        KeyParameter keyParam = new KeyParameter(derivedKey);
        BlockCipher aes = new AESFastEngine();
        Uint8List ivBytes = _createUint8ListFromString(iv);
        BlockCipher cipher = new CBCBlockCipher(aes);
        ParametersWithIV params = new ParametersWithIV(keyParam, ivBytes);

        cipher.init(true, params);

        Uint8List textBytes = _createUint8ListFromString(toEncrypt);
        Uint8List paddedText = _pad(textBytes, aes.blockSize);
        Uint8List cipherBytes = _processBlocks(cipher, paddedText);

        return base64.encode(cipherBytes);
    }

    static Future<String> decrypt(String toDecrypt) async {
        Uint8List derivedKey = _buildKey();
        KeyParameter keyParam = new KeyParameter(derivedKey);
        BlockCipher aes = new AESFastEngine();
        Uint8List ivBytes = _createUint8ListFromString(iv);
        BlockCipher cipher = new CBCBlockCipher(aes);
        ParametersWithIV params = new ParametersWithIV(keyParam, ivBytes);

        Uint8List cipherBytesFromEncode = base64.decode(toDecrypt);

        Uint8List cipherIvBytes = new Uint8List(cipherBytesFromEncode.length + ivBytes.length)
            ..setAll(0, ivBytes)
            ..setAll(ivBytes.length, cipherBytesFromEncode);

        cipher.init(false, params);

        int cipherLen = cipherIvBytes.length - aes.blockSize;
        Uint8List cipherBytes = new Uint8List(cipherLen)
            ..setRange(0, cipherLen, cipherIvBytes, aes.blockSize);
        Uint8List paddedText = _processBlocks(cipher, cipherBytes);
        Uint8List textBytes = _unpad(paddedText);

        if (textBytes == null)
            return "";

        return new String.fromCharCodes(textBytes);
    }

    static Uint8List _buildKey() {
        if (passphrase == null || passphrase.isEmpty) {
            throw new ArgumentError('passphrase must not be empty');
        }

        Uint8List passphraseBytes = _createUint8ListFromString(passphrase);
        Uint8List saltBytes = _createUint8ListFromString(salt);

        Pbkdf2Parameters params = new Pbkdf2Parameters(saltBytes, iterations, size);
        KeyDerivator keyDerivator = new PBKDF2KeyDerivator(new HMac(new SHA1Digest(), 64));
        keyDerivator.init(params);

        return keyDerivator.process(passphraseBytes);
    }

    static Uint8List _pad(Uint8List src, int blockSize) {
        var pad = new PKCS7Padding();
        pad.init(null);

        int padLength = blockSize - (src.length % blockSize);
        var out = new Uint8List(src.length + padLength)
            ..setAll(0, src);
        pad.addPadding(out, src.length);

        return out;
    }

    static Uint8List _unpad(Uint8List src) {
        try {
            PKCS7Padding pad = new PKCS7Padding();
            pad.init(null);

            int padLength = pad.padCount(src);
            int len = src.length - padLength;

            return new Uint8List(len)
                ..setRange(0, len, src);
        } catch (Exception) {
            return null;
        }
    }

    static Uint8List _processBlocks(BlockCipher cipher, Uint8List inp) {
        var out = new Uint8List(inp.lengthInBytes);

        for (var offset = 0; offset < inp.lengthInBytes;) {
            var len = cipher.processBlock(inp, offset, out, offset);
            offset += len;
        }

        return out;
    }

    static Uint8List _createUint8ListFromString(String s) {
        Uint8List ret = Uint8List.fromList(s.codeUnits);
        return ret;
    }
}

