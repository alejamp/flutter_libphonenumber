
import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_codes.dart';

class CountryCodeProvider {

  List<CountryCode> _countryCodes; 


  CountryCodeProvider() {
    init();
  }

  init() {
    print("Load country codes");
    List<Map> jsonList = codes;
    _countryCodes = jsonList
    .map((s) => new CountryCode(
          name: s['name'],
          code: s['code'],
          dialCode: s['dial_code'],
          flagUri: 'flags/${s['code'].toLowerCase()}.png',
        ))
    .toList();
  }

  CountryCode getByCode(String code){
      CountryCode r = _countryCodes.firstWhere(
                          (e){
                            return e.code.toLowerCase() == code.toLowerCase();
                          }, orElse: ()=>null);
      return r;
  }

  CountryCode getByDialCode(String dialCode){
      if(dialCode == '+1') return getByCode('US');

      CountryCode r = _countryCodes.firstWhere(
                          (e){
                            return e.dialCode.toLowerCase() == dialCode.toLowerCase();
                          }, orElse: ()=>null);
      return r;
  }
}


