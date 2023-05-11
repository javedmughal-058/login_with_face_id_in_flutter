import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
   static final auth = LocalAuthentication();

  static Future<void> authenticate() async {

    final canCheck = await hasBiometrics();

    print(canCheck);
    if(canCheck){
      final List<BiometricType> availableBiometricsList = await auth.getAvailableBiometrics();

      print(availableBiometricsList);

      if(availableBiometricsList.contains(BiometricType.face)){
          await auth.authenticate(
              biometricOnly: true,
              localizedReason: 'Scan Face to Authenticate',
              useErrorDialogs: true,
              stickyAuth: true,
              androidAuthStrings:
              const AndroidAuthMessages(signInTitle: 'Face ID Required',),
              iOSAuthStrings: const IOSAuthMessages(localizedFallbackTitle: 'Face ID Required',));
        }
      else if(availableBiometricsList.contains(BiometricType.fingerprint)){
        await auth.authenticate(
          biometricOnly: true,
            localizedReason: 'Scan Finger to Authenticate',
            useErrorDialogs: true,
            stickyAuth: true,
            androidAuthStrings:
            const AndroidAuthMessages(signInTitle: 'Finger ID Required',),
            iOSAuthStrings: const IOSAuthMessages(localizedFallbackTitle: 'Finger ID Required',),
        ).then((fingerData) {
              print("Finger Status $fingerData");
        });
      }

    }
    else{
      print('cannot check');
    }


  }

  static Future<bool> hasBiometrics() async{
    try{
      return await auth.canCheckBiometrics;
    } on PlatformException catch(e){
      return false;
    }
  }
}