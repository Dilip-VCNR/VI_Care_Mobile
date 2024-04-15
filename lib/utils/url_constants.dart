class UrlConstants {
  static const String imageBaseUrl = "http://52.172.157.45:91/";
  static const String apiBaseUrl = "http://52.172.157.45:91/api/";
  static const String sendOtpToRegister = "${apiBaseUrl}Account/SendOtp/";
  static const String getRoleMaster = "${apiBaseUrl}Role";
  static const String registerUser = "${apiBaseUrl}Account/Registration";
  static const String loginUser = "${apiBaseUrl}Account/LogIn";
  static const String sendOtpToResetPassword = "${apiBaseUrl}Account/ForgotPassword/";
  static const String resetPassword = "${apiBaseUrl}Account/ResetPassword";
  static const String addIndividualProfile = "${apiBaseUrl}IndividualProfile";
  static const String addEnterpriseProfile = "${apiBaseUrl}EnterpriseProfile";
  static const String getIndividualProfiles = "${apiBaseUrl}IndividualProfile";
  static const String getEnterpriseProfiles = "${apiBaseUrl}EnterpriseProfile";
  static const String userAndDevice = "${apiBaseUrl}UserAndDevice";
  static const String getAllDurations = "${apiBaseUrl}Duration";
  static const String updateProfile = "${apiBaseUrl}user";
  static const String getStateMaster = "${apiBaseUrl}State";
  static const String requestDeviceData = "${apiBaseUrl}RequestDeviceData";
  static const String MResponseReport = "${apiBaseUrl}MResponseReport/GetReportsBySearchFilter";
  static const String MDashboard = "${apiBaseUrl}MDashboard/GetProfileDashboardCounts";
}
