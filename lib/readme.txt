  public void testAYTFARMobile() {
    AsYouTypeFormatter formatter = phoneUtil.getAsYouTypeFormatter(RegionCode.AR);
    assertEquals("+", formatter.inputDigit('+'));
    assertEquals("+5", formatter.inputDigit('5'));
    assertEquals("+54 ", formatter.inputDigit('4'));
    assertEquals("+54 9", formatter.inputDigit('9'));
    assertEquals("+54 91", formatter.inputDigit('1'));
    assertEquals("+54 9 11", formatter.inputDigit('1'));
    assertEquals("+54 9 11 2", formatter.inputDigit('2'));
    assertEquals("+54 9 11 23", formatter.inputDigit('3'));
    assertEquals("+54 9 11 231", formatter.inputDigit('1'));
    assertEquals("+54 9 11 2312", formatter.inputDigit('2'));
    assertEquals("+54 9 11 2312 1", formatter.inputDigit('1'));
    assertEquals("+54 9 11 2312 12", formatter.inputDigit('2'));
    assertEquals("+54 9 11 2312 123", formatter.inputDigit('3'));
    assertEquals("+54 9 11 2312 1234", formatter.inputDigit('4'));
  }

  https://github.com/MichaelRocks/libphonenumber-android/blob/7cc47dc5f4ef8b656b483ce56b5b83447dc52d3b/library/src/test/java/io/michaelrocks/libphonenumber/android/AsYouTypeFormatterTest.java