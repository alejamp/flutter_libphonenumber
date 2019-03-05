import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/countryCodeProvider.dart';
import 'package:flutter_libphonenumber/custom-textfield-controller.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:country_code_picker/country_code_picker.dart';


class TextFieldPhone extends StatefulWidget {

  _TextFieldPhone state;
  bool internationalCodeOnText;
  String fixedRegionCode;
  String hintText;
  
  CountryCode currentCountryCode;

  // Everytime a key is pressed
  ValueChanged<String> onChange;
  // Everytime a phone is parsed succesfully.
  ValueChanged<PhoneNumber> onPhoneChange;
  bool autofocus;
  FocusNode focusNode;
  String errorText;
  bool maxLengthEnforced;
  int maxLength;

  TextFieldPhone({
    this.internationalCodeOnText = true,
    this.fixedRegionCode = '',
    this.onChange,
    this.onPhoneChange,
    this.autofocus = false,
    this.focusNode,
    this.hintText,
    this.errorText,
    this.maxLength = 11,
    this.maxLengthEnforced = true
  });

  @override
  _TextFieldPhone createState() {
     state = new _TextFieldPhone();
     return state;
  }
}

class _TextFieldPhone extends State<TextFieldPhone> {

  final _phoneController = TextEditingControllerWorkaroud();
  PhoneNumber _phoneNumber;
  CountryCodeProvider ccp;

  @override
  void initState() {
    super.initState();
    ccp = new  CountryCodeProvider();

    _parsePhoneNumber();

  }

  @override
  Widget build(BuildContext context) {


    return TextField(
              maxLengthEnforced: widget.maxLengthEnforced,
              maxLength: widget.maxLength,
              focusNode: widget.focusNode,
              style: Theme.of(context).textTheme.display2,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                _parsePhoneNumber();
              },
              controller: _phoneController,
              decoration: InputDecoration(
                errorText: widget.errorText,
                hintText: widget.hintText,
                hintStyle: Theme.of(context).textTheme.display2.copyWith(color: Color.fromRGBO(200, 200, 200, 1.0)),
                // labelText: "Phone"
              ),
            );    
  }

  clear() {
    _phoneController.clear();
  }

  void _parsePhoneNumber() async {
    try{


      if (widget.fixedRegionCode != null &&
          widget.fixedRegionCode != '' && 
          widget.fixedRegionCode.length >= 2 && 
          widget.fixedRegionCode != widget.currentCountryCode?.code ?? '') {
            print("fixedRegionCode:" + widget.fixedRegionCode);
            widget.currentCountryCode = ccp.getByCode(widget.fixedRegionCode);
            print("Got CountryCode:" + widget.currentCountryCode.toString());
      }

      String cleaned = _phoneController.text.replaceAll(' ', '').replaceAll('-', '').replaceAll('(', '').replaceAll(')', '');

      // Add country dialcode prefix, late at the end remove it
      if (widget.currentCountryCode != null && !widget.internationalCodeOnText) {
        cleaned = widget.currentCountryCode.dialCode + cleaned.replaceAll(widget.currentCountryCode.dialCode, "");
      }

      print("Send number to parse:" + cleaned);
      final parsed = await FlutterLibPhoneNumber.parse(cleaned);
      String newPhone = parsed?.aytf != null ? parsed?.aytf : parsed?.nationalNumber.toString();

      if (widget.currentCountryCode != null && !widget.internationalCodeOnText) {
        newPhone = newPhone.replaceAll(widget.currentCountryCode.dialCode, "").trim();        
      }
      setState(() {
        // Over write textfield value and set cursor position to the end.
        _phoneController.setTextAndPosition(newPhone);
      });
      if (widget.onPhoneChange != null) widget.onPhoneChange(parsed);
      // {numberExtension: , nationalNumber: 5491166937848, countryCode: 1, formated: +1 5491166937848, aytf: +54 9 11 6693-7848}

    } on PlatformException catch(e){
      // debugPrint(e.code +' --- '+e.message);
    }
  }  
}