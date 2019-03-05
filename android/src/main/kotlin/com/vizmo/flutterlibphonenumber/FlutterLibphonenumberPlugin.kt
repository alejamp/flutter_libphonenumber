package com.vizmo.flutterlibphonenumber

import android.app.Activity
import android.content.Context
import android.telephony.TelephonyManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.michaelrocks.libphonenumber.android.NumberParseException
import io.michaelrocks.libphonenumber.android.PhoneNumberUtil
import android.util.Log


class FlutterLibphonenumberPlugin(private val activity: Activity) : MethodCallHandler {

  private val phoneNumberUtil = PhoneNumberUtil.createInstance(activity)

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "com.vizmo.flutterlibphonenumber")
      channel.setMethodCallHandler(FlutterLibphonenumberPlugin(registrar.activity()))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    val method = call.method
    if ("parse" == method) {
      val args = call.arguments as? HashMap<*, *> ?: HashMap<String, Any>()

      val phoneNumber = args["phoneNumber"] as? String
      if(phoneNumber.isNullOrEmpty()) {
        result.error("invalidNumber", "Phone number is invalid", null)
        return
      }

      val defaultRegion = args["defaultRegion"] as? String ?: autoDetectCountry()
      //val ignoreType = args["ignoreType"] as? Boolean ?: true
      Log.d("KYC360", "Region:" + defaultRegion)

      try {
        val aytf = phoneNumberUtil.getAsYouTypeFormatter(defaultRegion)
        val parsedNumber = phoneNumberUtil.parse(phoneNumber, defaultRegion)
        val formatedNumber = phoneNumberUtil.format(parsedNumber, PhoneNumberUtil.PhoneNumberFormat.INTERNATIONAL)
        var aytPhoneNumber = ""

        for(c in phoneNumber?: ""){
          aytPhoneNumber = aytf.inputDigit(c)
          Log.d("KYC360", "aytf:" + aytPhoneNumber + " input:" + c);
        }

        val phoneMap = hashMapOf<String, Any?>(
            "countryCode" to parsedNumber.countryCode,
            "nationalNumber" to parsedNumber.nationalNumber,
            "numberExtension" to parsedNumber.extension,
            "formated" to formatedNumber,
            "aytf" to aytPhoneNumber
        )
        result.success(phoneMap)
      }catch (e: NumberParseException) {
        if(e.errorType == NumberParseException.ErrorType.TOO_SHORT_AFTER_IDD || e.errorType == NumberParseException.ErrorType.TOO_SHORT_AFTER_IDD){
          result.error("TOO_SHORT", e.message, null)
        }else {
          result.error(e.errorType.name, e.message, null)
        }
      }catch (e: Exception) {
        result.error("PARSE_ERROR", "Unknown error while parsing", e.message)
      }

    } else {
      result.notImplemented()
    }
  }

  private fun autoDetectCountry(): String {
    var country = detectSIMCountry()
    if(country != null) return country

    country = detectNetworkCountry()
    if(country!= null) return country

    country = detectLocaleCountry()
    if(country!= null) return country

    return "US"
  }

  /**
   * This will detect country from SIM info and then load it into CCP.
   *
   * @return true if it successfully sets country, false otherwise
   */
  private fun detectSIMCountry(): String? {
    return try {
      val telephonyManager = activity.getSystemService(Context.TELEPHONY_SERVICE) as
          TelephonyManager
      telephonyManager.simCountryIso
    } catch (e: Exception) {
      e.printStackTrace()
      null
    }

  }

  /**
   * This will detect country from NETWORK info and then load it into CCP.
   *
   * @return true if it successfully sets country, false otherwise
   */
  private fun detectNetworkCountry(): String? {
    return try {
      val telephonyManager = activity.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
      telephonyManager.networkCountryIso
    } catch (e: Exception) {
      e.printStackTrace()
      null
    }

  }

  /**
   * This will detect country from LOCALE info and then load it into CCP.
   *
   * @return true if it successfully sets country, false otherwise
   */
  private fun detectLocaleCountry(): String? {
    return try {
      activity.resources.configuration.locale.country
    } catch (e: Exception) {
      e.printStackTrace()
      null
    }

  }

}
