class AppLangVersionUtils {
  static int getLangVersion() {
    return 1;
    // 1 = cn 91
    // 2 = yd xo
    // 3 = tk
  }

  static bool isCn() {
    return getLangVersion() == 1;
  }

  static bool isYd() {
    return getLangVersion() == 2;
  }

  static bool isTk() {
    return getLangVersion() == 3;
  }

  static String getLogoPath() {
    switch (getLangVersion()) {
      case 1:
        return "lib/assets/logo-cn.png";
      case 2:
        return "lib/assets/logo-yd.jpg";
      case 3:
        return "lib/assets/logo-tk.png";
      default:
        return "lib/assets/logo-cn.png";
    }
  }

  static String getBackgroundLogoPath() {
    switch (getLangVersion()) {
      case 1:
        return "lib/assets/bg-cn.jpg";
      case 2:
        return "lib/assets/bg-yd.png";
      case 3:
        return "lib/assets/bg-tk.jpg";
      default:
        return "lib/assets/bg-cn.jpg";
    }
  }

  static String getAppName() {
    switch (getLangVersion()) {
      case 1:
        return "91";
      case 2:
        return "Xo";
      case 3:
        return "Tk";
      default:
        return "91";
    }
  }

  static String getAppId() {
    switch (getLangVersion()) {
      case 1:
        return "live.bogo.app.live_app.cn";
      case 2:
        return "live.bogo.app.live_app.xo";
      case 3:
        return "live.bogo.app.live_app.tk";
      default:
        return "live.bogo.app.live_app.cn";
    }
  }

  static String getAppFullName() {
    switch (getLangVersion()) {
      case 1:
        return "91 App";
      case 2:
        return "XO App";
      case 3:
        return "Tk App";
      default:
        return "91 App";
    }
  }

  static String getLanguageCode() {
    switch (getLangVersion()) {
      case 1:
        return "cn_zh";
      case 2:
        return "us_en";
      case 3:
        return "cn_zh";
      default:
        return "cn_zh";
    }
  }

  static String getLocaleLang() {
    switch (getLangVersion()) {
      case 1:
        return "zh";
      case 2:
        return "en";
      case 3:
        return "zh";
      default:
        return "zh";
    }
  }

  static String getLocaleCountry() {
    switch (getLangVersion()) {
      case 1:
        return "CN";
      case 2:
        return "US";
      case 3:
        return "CN";
      default:
        return "CN";
    }
  }
}
