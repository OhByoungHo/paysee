final baseurl = 'http://14.63.172.72:8080/TESTDP/rest/';
final imageurl = 'http://14.63.172.72:8080';
final appStore = 'https://itunes.apple.com/us/app/%EA%B8';
final APP_VERSION = '1.0.30';
final GOOGLE_API_KEY = 'AIzaSyAwV_dUTpqMtsDxHrZXo6niGGXkY0yWS3k';

List<Map<String, dynamic>> gsbueso = [];
List<Map<String, dynamic>> gsjikcheck = [];
List<Map<String, dynamic>> gsjijum = [];
List<Map<String, dynamic>> gscountry = [];
List<Map<String, dynamic>> gsstay = [];
List<Map<String, dynamic>> gsworktype = [];


bool gsUser = false;
bool gsGpsMrg = false;
bool gsPayMgr = false;
bool gsNoSTCode = false;
bool gsJijum = false;
bool USER_INFO_newSignUp = false; //--신규회원 가입유저

String modelName = '';
String serialNumber = 'Unknown';
String gsSTGPSYN = 'N';           //-- GPS 사용여부
String gsSTBeaconYN = 'N';        //-- Beacon 사용여부
String gsShiftWorker = '';
String PlatformOS = '';
String USER_INFO_SUId = '';
String USER_INFO_SUPw = '';

String USER_INFO_SUMyPicYN = '';
String USER_INFO_MyPicURL = '';

String USER_INFO_SCCode = '';
String USER_INFO_SCHostIp = '';
String USER_INFO_SCDBName = '';
String USER_INFO_SUJJCode = '';
String USER_INFO_SCGroupwareYN = 'N';
String USER_INFO_SCPayAdminSUCode = '';
String USER_INFO_SCPayAdminSUName = '';
String USER_INFO_SCAccountAdminSUName = '';
String USER_INFO_SCAccountAdminSUCode = '';
String USER_INFO_SCBeaconMajor = '';
String USER_INFO_SCBeaconUUID = '';
String USER_INFO_SCMobileOpenTime = '';
String USER_INFO_SCBeaconYN = '';
String USER_INFO_SCGpsYN = '';
String USER_INFO_SUSTCode = '';
String USER_INFO_SUCode = '';
String USER_INFO_SUName = '';
String USER_INFO_STMobileKey = '';
String USER_INFO_SULevel = '';
String USER_INFO_Token = '';
String USER_INFO_SCCoordinate = '';
String USER_INFO_SCYenchaGubun = '';
String USER_INFO_SWYenchaBase = '';
String USER_INFO_STSex = 'M';
