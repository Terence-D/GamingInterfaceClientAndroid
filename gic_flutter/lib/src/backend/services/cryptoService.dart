import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class CryptoService {
  static final String salt = 'f-NS5Qnhn@sdC%_7RAD3K3GmYU5ZHW*\$';
  static final String passphrase =
      'WCu8rer-kuJ58UZKcz*ABL\$?&=@pw=_d4L\$tr^cfFgdad-NxCUXRUz8LL*_5z?Xm^zFMP4FXRUvdEhNH=kwKJp8^-D3Uf8AG?6DtKrQH%HYC*c6KqW&XR2gF7hndfu+u';
  static final String iv = 'kYW-*%n^t!JkV3FU';
  static final int iterations = 100;
  static final int size = 32;
  static const Mode = 'CBC';

  static String encrypt(String toEncrypt) {
    Uint8List derivedKey = _buildKey();
    KeyParameter keyParam = KeyParameter(derivedKey);
    BlockCipher aes = AESFastEngine();
    Uint8List ivBytes = _createUint8ListFromString(iv);
    BlockCipher cipher = CBCBlockCipher(aes);
    ParametersWithIV params = ParametersWithIV(keyParam, ivBytes);

    cipher.init(true, params);

    Uint8List textBytes = _createUint8ListFromString(toEncrypt);
    Uint8List paddedText = _pad(textBytes, aes.blockSize);
    Uint8List cipherBytes = _processBlocks(cipher, paddedText);

    return base64.encode(cipherBytes);
  }

  static String decrypt(String toDecrypt) {
    Uint8List derivedKey = _buildKey();
    KeyParameter keyParam = KeyParameter(derivedKey);
    BlockCipher aes = AESFastEngine();
    Uint8List ivBytes = _createUint8ListFromString(iv);
    BlockCipher cipher = CBCBlockCipher(aes);
    ParametersWithIV params = ParametersWithIV(keyParam, ivBytes);

    String decryptThis = toDecrypt;
    if (decryptThis.length % 4 > 0) {
      decryptThis += '=' * (4 - decryptThis.length % 4);
    }

    Uint8List cipherBytesFromEncode;
    try {
      cipherBytesFromEncode = base64.decode(decryptThis);
    } catch (e) {
      return "";
    }

    Uint8List cipherIvBytes =
        Uint8List(cipherBytesFromEncode.length + ivBytes.length)
          ..setAll(0, ivBytes)
          ..setAll(ivBytes.length, cipherBytesFromEncode);

    cipher.init(false, params);

    int cipherLen = cipherIvBytes.length - aes.blockSize;
    Uint8List cipherBytes = Uint8List(cipherLen)
      ..setRange(0, cipherLen, cipherIvBytes, aes.blockSize);
    Uint8List paddedText = _processBlocks(cipher, cipherBytes);
    Uint8List? textBytes = _unpad(paddedText);

    if (textBytes == null) {
      return "";
    }

    return String.fromCharCodes(textBytes);
  }

  static Uint8List _buildKey() {
    if (passphrase.isEmpty) {
      throw ArgumentError('passphrase must not be empty');
    }

    Uint8List passphraseBytes = _createUint8ListFromString(passphrase);
    Uint8List saltBytes = _createUint8ListFromString(salt);

    Pbkdf2Parameters params = Pbkdf2Parameters(saltBytes, iterations, size);
    KeyDerivator keyDerivator = PBKDF2KeyDerivator(HMac(SHA1Digest(), 64));
    keyDerivator.init(params);

    return keyDerivator.process(passphraseBytes);
  }

  static Uint8List _pad(Uint8List src, int blockSize) {
    var pad = PKCS7Padding();
    pad.init(null);

    int padLength = blockSize - (src.length % blockSize);
    var out = Uint8List(src.length + padLength)..setAll(0, src);
    pad.addPadding(out, src.length);

    return out;
  }

  static Uint8List? _unpad(Uint8List src) {
    try {
      PKCS7Padding pad = PKCS7Padding();
      pad.init(null);

      int padLength = pad.padCount(src);
      int len = src.length - padLength;

      return Uint8List(len)..setRange(0, len, src);
    } catch (_) {
      return null;
    }
  }

  static Uint8List _processBlocks(BlockCipher cipher, Uint8List inp) {
    var out = Uint8List(inp.lengthInBytes);

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
