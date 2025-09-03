import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SupportedLanguage { english, hindi, tamil }

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  SupportedLanguage _currentLanguage = SupportedLanguage.english;

  SupportedLanguage get currentLanguage => _currentLanguage;

  final Map<SupportedLanguage, String> _languageNames = {
    SupportedLanguage.english: 'English',
    SupportedLanguage.hindi: 'हिंदी',
    SupportedLanguage.tamil: 'தமிழ்',
  };

  final Map<String, Map<SupportedLanguage, String>> _translations = {
    // App Title and Navigation
    'WasteWise India': {
      SupportedLanguage.english: 'WasteWise India',
      SupportedLanguage.hindi: 'वेस्टवाइज़ इंडिया',
      SupportedLanguage.tamil: 'வேஸ்ட்வைஸ் இந்தியா',
    },
    'Welcome back': {
      SupportedLanguage.english: 'Welcome back',
      SupportedLanguage.hindi: 'वापसी पर स्वागत है',
      SupportedLanguage.tamil: 'மீண்டும் வரவேற்கிறோம்',
    },
    'Home': {
      SupportedLanguage.english: 'Home',
      SupportedLanguage.hindi: 'होम',
      SupportedLanguage.tamil: 'முகப்பு',
    },
    'Training': {
      SupportedLanguage.english: 'Training',
      SupportedLanguage.hindi: 'प्रशिक्षण',
      SupportedLanguage.tamil: 'பயிற்சி',
    },
    'Report': {
      SupportedLanguage.english: 'Report',
      SupportedLanguage.hindi: 'रिपोर्ट',
      SupportedLanguage.tamil: 'அறிக்கை',
    },
    'Facilities': {
      SupportedLanguage.english: 'Facilities',
      SupportedLanguage.hindi: 'सुविधाएं',
      SupportedLanguage.tamil: 'வசதிகள்',
    },
    'Profile': {
      SupportedLanguage.english: 'Profile',
      SupportedLanguage.hindi: 'प्रोफ़ाइल',
      SupportedLanguage.tamil: 'சுயவிவரம்',
    },

    // Authentication
    'Sign In': {
      SupportedLanguage.english: 'Sign In',
      SupportedLanguage.hindi: 'साइन इन करें',
      SupportedLanguage.tamil: 'உள்நுழைக',
    },
    'Sign Up': {
      SupportedLanguage.english: 'Sign Up',
      SupportedLanguage.hindi: 'साइन अप करें',
      SupportedLanguage.tamil: 'பதிவு செய்க',
    },
    'Email Address': {
      SupportedLanguage.english: 'Email Address',
      SupportedLanguage.hindi: 'ईमेल पता',
      SupportedLanguage.tamil: 'மின்னஞ்சல் முகவரி',
    },
    'Password': {
      SupportedLanguage.english: 'Password',
      SupportedLanguage.hindi: 'पासवर्ड',
      SupportedLanguage.tamil: 'கடவுச்சொல்',
    },
    'Full Name': {
      SupportedLanguage.english: 'Full Name',
      SupportedLanguage.hindi: 'पूरा नाम',
      SupportedLanguage.tamil: 'முழு பெயர்',
    },
    'Phone Number': {
      SupportedLanguage.english: 'Phone Number',
      SupportedLanguage.hindi: 'फोन नंबर',
      SupportedLanguage.tamil: 'தொலைபேசி எண்',
    },

    // Waste Management
    'Report Waste Issue': {
      SupportedLanguage.english: 'Report Waste Issue',
      SupportedLanguage.hindi: 'कचरे की समस्या की रिपोर्ट करें',
      SupportedLanguage.tamil: 'கழிவு பிரச்சினையை புகாரளிக்கவும்',
    },
    'Help keep India clean': {
      SupportedLanguage.english: 'Help keep India clean',
      SupportedLanguage.hindi: 'भारत को साफ रखने में मदद करें',
      SupportedLanguage.tamil: 'இந்தியாவை சுத்தமாக வைக்க உதவுங்கள்',
    },
    'Photo/Video Evidence': {
      SupportedLanguage.english: 'Photo/Video Evidence',
      SupportedLanguage.hindi: 'फोटो/वीडियो प्रमाण',
      SupportedLanguage.tamil: 'புகைப்படம்/வீடியோ ஆதாரம்',
    },
    'Report Title': {
      SupportedLanguage.english: 'Report Title',
      SupportedLanguage.hindi: 'रिपोर्ट शीर्षक',
      SupportedLanguage.tamil: 'அறிக்கை தலைப்பு',
    },
    'Location': {
      SupportedLanguage.english: 'Location',
      SupportedLanguage.hindi: 'स्थान',
      SupportedLanguage.tamil: 'இடம்',
    },
    'Waste Type': {
      SupportedLanguage.english: 'Waste Type',
      SupportedLanguage.hindi: 'कचरे का प्रकार',
      SupportedLanguage.tamil: 'கழிவு வகை',
    },
    'Priority Level': {
      SupportedLanguage.english: 'Priority Level',
      SupportedLanguage.hindi: 'प्राथमिकता स्तर',
      SupportedLanguage.tamil: 'முன்னுரிமை நிலை',
    },
    'Detailed Description': {
      SupportedLanguage.english: 'Detailed Description',
      SupportedLanguage.hindi: 'विस्तृत विवरण',
      SupportedLanguage.tamil: 'விரிவான விளக்கம்',
    },
    'Submit Report': {
      SupportedLanguage.english: 'Submit Report',
      SupportedLanguage.hindi: 'रिपोर्ट जमा करें',
      SupportedLanguage.tamil: 'அறிக்கையை சமர்பிக்கவும்',
    },

    // Training
    'Waste Management Training': {
      SupportedLanguage.english: 'Waste Management Training',
      SupportedLanguage.hindi: 'अपशिष्ट प्रबंधन प्रशिक्षण',
      SupportedLanguage.tamil: 'கழிவு மேலாண்மை பயிற்சி',
    },
    'Master the skills for a cleaner India': {
      SupportedLanguage.english: 'Master the skills for a cleaner India',
      SupportedLanguage.hindi: 'स्वच्छ भारत के लिए कौशल में महारत हासिल करें',
      SupportedLanguage.tamil: 'சுத்தமான இந்தியாவுக்கான திறமைகளில் தேர்ச்சி பெறுங்கள்',
    },
    'Start Module': {
      SupportedLanguage.english: 'Start Module',
      SupportedLanguage.hindi: 'मॉड्यूल शुरू करें',
      SupportedLanguage.tamil: 'தொகுதியைத் தொடங்கவும்',
    },
    'Completed': {
      SupportedLanguage.english: 'Completed',
      SupportedLanguage.hindi: 'पूर्ण',
      SupportedLanguage.tamil: 'முடிந்தது',
    },

    // Games
    'Daily Eco Games': {
      SupportedLanguage.english: 'Daily Eco Games',
      SupportedLanguage.hindi: 'दैनिक इको गेम्स',
      SupportedLanguage.tamil: 'தினசரி சுற்றுச்சூழல் விளையாட்டுகள்',
    },
    'Learn while having fun!': {
      SupportedLanguage.english: 'Learn while having fun!',
      SupportedLanguage.hindi: 'मज़े करते हुए सीखें!',
      SupportedLanguage.tamil: 'வேடிக்கையாக கற்றுக்கொள்ளுங்கள்!',
    },
    'Play Now': {
      SupportedLanguage.english: 'Play Now',
      SupportedLanguage.hindi: 'अभी खेलें',
      SupportedLanguage.tamil: 'இப்போது விளையாடுங்கள்',
    },

    // Facilities
    'Waste Management Facilities': {
      SupportedLanguage.english: 'Waste Management Facilities',
      SupportedLanguage.hindi: 'अपशिष्ट प्रबंधन सुविधाएं',
      SupportedLanguage.tamil: 'கழிவு மேலாண்மை வசதிகள்',
    },
    'Find nearby treatment centers': {
      SupportedLanguage.english: 'Find nearby treatment centers',
      SupportedLanguage.hindi: 'नजदीकी उपचार केंद्र खोजें',
      SupportedLanguage.tamil: 'அருகிலுள்ள சிகிச்சை மையங்களைக் கண்டறியவும்',
    },
    'Call': {
      SupportedLanguage.english: 'Call',
      SupportedLanguage.hindi: 'कॉल करें',
      SupportedLanguage.tamil: 'அழைக்கவும்',
    },
    'Directions': {
      SupportedLanguage.english: 'Directions',
      SupportedLanguage.hindi: 'दिशा-निर्देश',
      SupportedLanguage.tamil: 'திசைகள்',
    },

    // Rewards
    'Rewards Store': {
      SupportedLanguage.english: 'Rewards Store',
      SupportedLanguage.hindi: 'रिवार्ड स्टोर',
      SupportedLanguage.tamil: 'வெகுமதி கடை',
    },
    'Redeem your eco-points for rewards': {
      SupportedLanguage.english: 'Redeem your eco-points for rewards',
      SupportedLanguage.hindi: 'रिवार्ड के लिए अपने इको-पॉइंट्स रिडीम करें',
      SupportedLanguage.tamil: 'வெகுமதிகளுக்காக உங்கள் சுற்றுச்சூழல் புள்ளிகளை மீட்டெடுக்கவும்',
    },
    'Redeem': {
      SupportedLanguage.english: 'Redeem',
      SupportedLanguage.hindi: 'रिडीम करें',
      SupportedLanguage.tamil: 'மீட்டெடுக்கவும்',
    },

    // Green Champion
    'Green Champion Program': {
      SupportedLanguage.english: 'Green Champion Program',
      SupportedLanguage.hindi: 'ग्रीन चैंपियन कार्यक्रम',
      SupportedLanguage.tamil: 'பசுமை சாம்பியன் திட்டம்',
    },
    'Lead your community to sustainability': {
      SupportedLanguage.english: 'Lead your community to sustainability',
      SupportedLanguage.hindi: 'अपने समुदाय को स्थिरता की ओर ले जाएं',
      SupportedLanguage.tamil: 'உங்கள் சமூகத்தை நிலைத்தன்மைக்கு வழிநடத்துங்கள்',
    },

    // Common Actions
    'Continue': {
      SupportedLanguage.english: 'Continue',
      SupportedLanguage.hindi: 'जारी रखें',
      SupportedLanguage.tamil: 'தொடரவும்',
    },
    'Cancel': {
      SupportedLanguage.english: 'Cancel',
      SupportedLanguage.hindi: 'रद्द करें',
      SupportedLanguage.tamil: 'ரத்து செய்',
    },
    'Save': {
      SupportedLanguage.english: 'Save',
      SupportedLanguage.hindi: 'सेव करें',
      SupportedLanguage.tamil: 'சேமிக்கவும்',
    },
    'Delete': {
      SupportedLanguage.english: 'Delete',
      SupportedLanguage.hindi: 'हटाएं',
      SupportedLanguage.tamil: 'நீக்கவும்',
    },
    'Edit': {
      SupportedLanguage.english: 'Edit',
      SupportedLanguage.hindi: 'संपादित करें',
      SupportedLanguage.tamil: 'திருத்தவும்',
    },
    'View': {
      SupportedLanguage.english: 'View',
      SupportedLanguage.hindi: 'देखें',
      SupportedLanguage.tamil: 'பார்க்கவும்',
    },
    'Search': {
      SupportedLanguage.english: 'Search',
      SupportedLanguage.hindi: 'खोजें',
      SupportedLanguage.tamil: 'தேடவும்',
    },

    // Status Messages
    'Pending': {
      SupportedLanguage.english: 'Pending',
      SupportedLanguage.hindi: 'लंबित',
      SupportedLanguage.tamil: 'நிலுவையில்',
    },
    'Assigned': {
      SupportedLanguage.english: 'Assigned',
      SupportedLanguage.hindi: 'सौंपा गया',
      SupportedLanguage.tamil: 'ஒதுக்கப்பட்டது',
    },
    'In Progress': {
      SupportedLanguage.english: 'In Progress',
      SupportedLanguage.hindi: 'प्रगति में',
      SupportedLanguage.tamil: 'முன்னேற்றத்தில்',
    },
    'Resolved': {
      SupportedLanguage.english: 'Resolved',
      SupportedLanguage.hindi: 'हल हो गया',
      SupportedLanguage.tamil: 'தீர்க்கப்பட்டது',
    },

    // Waste Types
    'Mixed Waste': {
      SupportedLanguage.english: 'Mixed Waste',
      SupportedLanguage.hindi: 'मिश्रित कचरा',
      SupportedLanguage.tamil: 'கலப்பு கழிவு',
    },
    'Plastic Waste': {
      SupportedLanguage.english: 'Plastic Waste',
      SupportedLanguage.hindi: 'प्लास्टिक कचरा',
      SupportedLanguage.tamil: 'பிளாஸ்டிக் கழிவு',
    },
    'Organic Waste': {
      SupportedLanguage.english: 'Organic Waste',
      SupportedLanguage.hindi: 'जैविक कचरा',
      SupportedLanguage.tamil: 'இயற்கை கழிவு',
    },
    'Electronic Waste': {
      SupportedLanguage.english: 'Electronic Waste',
      SupportedLanguage.hindi: 'इलेक्ट्रॉनिक कचरा',
      SupportedLanguage.tamil: 'மின்னணு கழிவு',
    },
    'Construction Debris': {
      SupportedLanguage.english: 'Construction Debris',
      SupportedLanguage.hindi: 'निर्माण मलबा',
      SupportedLanguage.tamil: 'கட்டுமான குப்பைகள்',
    },
    'Hazardous Waste': {
      SupportedLanguage.english: 'Hazardous Waste',
      SupportedLanguage.hindi: 'खतरनाक कचरा',
      SupportedLanguage.tamil: 'ஆபத்தான கழிவு',
    },

    // Training Modules
    'Basic Waste Management for Citizens': {
      SupportedLanguage.english: 'Basic Waste Management for Citizens',
      SupportedLanguage.hindi: 'नागरिकों के लिए बुनियादी अपशिष्ट प्रबंधन',
      SupportedLanguage.tamil: 'குடிமக்களுக்கான அடிப்படை கழிவு மேலாண்மை',
    },
    'Home Composting Mastery': {
      SupportedLanguage.english: 'Home Composting Mastery',
      SupportedLanguage.hindi: 'घरेलू कंपोस्टिंग में महारत',
      SupportedLanguage.tamil: 'வீட்டு உரமாக்கல் தேர்ச்சி',
    },
    'Creative Plastic Reuse': {
      SupportedLanguage.english: 'Creative Plastic Reuse',
      SupportedLanguage.hindi: 'रचनात्मक प्लास्टिक पुन: उपयोग',
      SupportedLanguage.tamil: 'ஆக்கபூர்வமான பிளாஸ்டிக் மறுபயன்பாடு',
    },

    // Facility Types
    'Recycling Centers': {
      SupportedLanguage.english: 'Recycling Centers',
      SupportedLanguage.hindi: 'रीसाइक्लिंग केंद्र',
      SupportedLanguage.tamil: 'மறுசுழற்சி மையங்கள்',
    },
    'Waste-to-Energy': {
      SupportedLanguage.english: 'Waste-to-Energy',
      SupportedLanguage.hindi: 'कचरे से ऊर्जा',
      SupportedLanguage.tamil: 'கழிவிலிருந்து ஆற்றல்',
    },
    'Composting Units': {
      SupportedLanguage.english: 'Composting Units',
      SupportedLanguage.hindi: 'कंपोस्टिंग इकाइयां',
      SupportedLanguage.tamil: 'உரமாக்கல் அலகுகள்',
    },
    'Biogas Plants': {
      SupportedLanguage.english: 'Biogas Plants',
      SupportedLanguage.hindi: 'बायोगैस प्लांट',
      SupportedLanguage.tamil: 'உயிர்வாயு ஆலைகள்',
    },
    'Scrap Shops': {
      SupportedLanguage.english: 'Scrap Shops',
      SupportedLanguage.hindi: 'स्क्रैप की दुकानें',
      SupportedLanguage.tamil: 'ஸ்கிராப் கடைகள்',
    },

    // Error Messages
    'Please enter your email': {
      SupportedLanguage.english: 'Please enter your email',
      SupportedLanguage.hindi: 'कृपया अपना ईमेल दर्ज करें',
      SupportedLanguage.tamil: 'தயவுசெய்து உங்கள் மின்னஞ்சலை உள்ளிடவும்',
    },
    'Please enter your password': {
      SupportedLanguage.english: 'Please enter your password',
      SupportedLanguage.hindi: 'कृपया अपना पासवर्ड दर्ज करें',
      SupportedLanguage.tamil: 'தயவுசெய்து உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
    },
    'Please enter a title': {
      SupportedLanguage.english: 'Please enter a title',
      SupportedLanguage.hindi: 'कृपया एक शीर्षक दर्ज करें',
      SupportedLanguage.tamil: 'தயவுசெய்து ஒரு தலைப்பை உள்ளிடவும்',
    },
    'Please enter location': {
      SupportedLanguage.english: 'Please enter location',
      SupportedLanguage.hindi: 'कृपया स्थान दर्ज करें',
      SupportedLanguage.tamil: 'தயவுசெய்து இடத்தை உள்ளிடவும்',
    },
    'Please provide a description': {
      SupportedLanguage.english: 'Please provide a description',
      SupportedLanguage.hindi: 'कृपया एक विवरण प्रदान करें',
      SupportedLanguage.tamil: 'தயவுசெய்து ஒரு விளக்கம் அளிக்கவும்',
    },

    // Success Messages
    'Report submitted successfully!': {
      SupportedLanguage.english: 'Report submitted successfully!',
      SupportedLanguage.hindi: 'रिपोर्ट सफलतापूर्वक जमा की गई!',
      SupportedLanguage.tamil: 'அறிக்கை வெற்றிகரமாக சமர்பிக்கப்பட்டது!',
    },
    'Training completed!': {
      SupportedLanguage.english: 'Training completed!',
      SupportedLanguage.hindi: 'प्रशिक्षण पूरा हुआ!',
      SupportedLanguage.tamil: 'பயிற்சி முடிந்தது!',
    },
    'Game completed!': {
      SupportedLanguage.english: 'Game completed!',
      SupportedLanguage.hindi: 'गेम पूरा हुआ!',
      SupportedLanguage.tamil: 'விளையாட்டு முடிந்தது!',
    },

    // Community
    'Community Dashboard': {
      SupportedLanguage.english: 'Community Dashboard',
      SupportedLanguage.hindi: 'सामुदायिक डैशबोर्ड',
      SupportedLanguage.tamil: 'சமூக டாஷ்போர்டு',
    },
    'Track collective impact': {
      SupportedLanguage.english: 'Track collective impact',
      SupportedLanguage.hindi: 'सामूहिक प्रभाव को ट्रैक करें',
      SupportedLanguage.tamil: 'கூட்டு தாக்கத்தை கண்காணிக்கவும்',
    },
    'Live Feed': {
      SupportedLanguage.english: 'Live Feed',
      SupportedLanguage.hindi: 'लाइव फीड',
      SupportedLanguage.tamil: 'நேரடி ஊட்டம்',
    },
    'Leaderboard': {
      SupportedLanguage.english: 'Leaderboard',
      SupportedLanguage.hindi: 'लीडरबोर्ड',
      SupportedLanguage.tamil: 'தலைமை பலகை',
    },
    'Challenges': {
      SupportedLanguage.english: 'Challenges',
      SupportedLanguage.hindi: 'चुनौतियां',
      SupportedLanguage.tamil: 'சவால்கள்',
    },

    // Points and Rewards
    'points': {
      SupportedLanguage.english: 'points',
      SupportedLanguage.hindi: 'अंक',
      SupportedLanguage.tamil: 'புள்ளிகள்',
    },
    'eco-points': {
      SupportedLanguage.english: 'eco-points',
      SupportedLanguage.hindi: 'इको-पॉइंट्स',
      SupportedLanguage.tamil: 'சுற்றுச்சூழல் புள்ளிகள்',
    },

    // Settings
    'Settings': {
      SupportedLanguage.english: 'Settings',
      SupportedLanguage.hindi: 'सेटिंग्स',
      SupportedLanguage.tamil: 'அமைப்புகள்',
    },
    'Language': {
      SupportedLanguage.english: 'Language',
      SupportedLanguage.hindi: 'भाषा',
      SupportedLanguage.tamil: 'மொழி',
    },
    'Dark Mode': {
      SupportedLanguage.english: 'Dark Mode',
      SupportedLanguage.hindi: 'डार्क मोड',
      SupportedLanguage.tamil: 'இருண்ட பயன்முறை',
    },
    'Notifications': {
      SupportedLanguage.english: 'Notifications',
      SupportedLanguage.hindi: 'सूचनाएं',
      SupportedLanguage.tamil: 'அறிவிப்புகள்',
    },
    'Logout': {
      SupportedLanguage.english: 'Logout',
      SupportedLanguage.hindi: 'लॉग आउट',
      SupportedLanguage.tamil: 'வெளியேறு',
    },

    // Priority Levels
    'Low': {
      SupportedLanguage.english: 'Low',
      SupportedLanguage.hindi: 'कम',
      SupportedLanguage.tamil: 'குறைவு',
    },
    'Medium': {
      SupportedLanguage.english: 'Medium',
      SupportedLanguage.hindi: 'मध्यम',
      SupportedLanguage.tamil: 'நடுத்தர',
    },
    'High': {
      SupportedLanguage.english: 'High',
      SupportedLanguage.hindi: 'उच्च',
      SupportedLanguage.tamil: 'உயர்',
    },
    'Urgent': {
      SupportedLanguage.english: 'Urgent',
      SupportedLanguage.hindi: 'तत्काल',
      SupportedLanguage.tamil: 'அவசர',
    },

    // Game Types
    'Waste Sorting Challenge': {
      SupportedLanguage.english: 'Waste Sorting Challenge',
      SupportedLanguage.hindi: 'कचरा छंटाई चुनौती',
      SupportedLanguage.tamil: 'கழிவு வரிசைப்படுத்தல் சவால்',
    },
    'Eco Knowledge Quiz': {
      SupportedLanguage.english: 'Eco Knowledge Quiz',
      SupportedLanguage.hindi: 'इको नॉलेज क्विज़',
      SupportedLanguage.tamil: 'சுற்றுச்சூழல் அறிவு வினாடி வினா',
    },
    'Green Memory Match': {
      SupportedLanguage.english: 'Green Memory Match',
      SupportedLanguage.hindi: 'ग्रीन मेमोरी मैच',
      SupportedLanguage.tamil: 'பசுமை நினைவக பொருத்தம்',
    },
    'Clean City Runner': {
      SupportedLanguage.english: 'Clean City Runner',
      SupportedLanguage.hindi: 'क्लीन सिटी रनर',
      SupportedLanguage.tamil: 'சுத்தமான நகர ஓட்டப்பந்தய',
    },

    // Rewards
    'Eco-Friendly Jute Bag': {
      SupportedLanguage.english: 'Eco-Friendly Jute Bag',
      SupportedLanguage.hindi: 'पर्यावरण-अनुकूल जूट बैग',
      SupportedLanguage.tamil: 'சுற்றுச்சூழல் நட்பு சணல் பை',
    },
    'Home Composting Kit': {
      SupportedLanguage.english: 'Home Composting Kit',
      SupportedLanguage.hindi: 'होम कंपोस्टिंग किट',
      SupportedLanguage.tamil: 'வீட்டு உரமாக்கல் கிட்',
    },
    '3-Bin Waste Segregation Set': {
      SupportedLanguage.english: '3-Bin Waste Segregation Set',
      SupportedLanguage.hindi: '3-बिन कचरा पृथक्करण सेट',
      SupportedLanguage.tamil: '3-தொட்டி கழிவு பிரிப்பு தொகுப்பு',
    },
    'Native Plant Seeds Pack': {
      SupportedLanguage.english: 'Native Plant Seeds Pack',
      SupportedLanguage.hindi: 'देशी पौधों के बीज पैक',
      SupportedLanguage.tamil: 'உள்ளூர் தாவர விதை பேக்',
    },

    // Quick Actions
    'Quick Actions': {
      SupportedLanguage.english: 'Quick Actions',
      SupportedLanguage.hindi: 'त्वरित कार्य',
      SupportedLanguage.tamil: 'விரைவு செயல்கள்',
    },
    'Report Waste': {
      SupportedLanguage.english: 'Report Waste',
      SupportedLanguage.hindi: 'कचरे की रिपोर्ट करें',
      SupportedLanguage.tamil: 'கழிவு புகாரளிக்கவும்',
    },
    'Document improper disposal': {
      SupportedLanguage.english: 'Document improper disposal',
      SupportedLanguage.hindi: 'अनुचित निपटान का दस्तावेजीकरण',
      SupportedLanguage.tamil: 'முறையற்ற அகற்றலை ஆவணப்படுத்தவும்',
    },
    'Training Hub': {
      SupportedLanguage.english: 'Training Hub',
      SupportedLanguage.hindi: 'प्रशिक्षण केंद्र',
      SupportedLanguage.tamil: 'பயிற்சி மையம்',
    },
    'Learn waste management': {
      SupportedLanguage.english: 'Learn waste management',
      SupportedLanguage.hindi: 'अपशिष्ट प्रबंधन सीखें',
      SupportedLanguage.tamil: 'கழிவு மேலாண்மையை கற்றுக்கொள்ளுங்கள்',
    },
    'Redeem eco-points': {
      SupportedLanguage.english: 'Redeem eco-points',
      SupportedLanguage.hindi: 'इको-पॉइंट्स रिडीम करें',
      SupportedLanguage.tamil: 'சுற்றுச்சூழல் புள்ளிகளை மீட்டெடுக்கவும்',
    },
    'Lead your community': {
      SupportedLanguage.english: 'Lead your community',
      SupportedLanguage.hindi: 'अपने समुदाय का नेतृत्व करें',
      SupportedLanguage.tamil: 'உங்கள் சமூகத்தை வழிநடத்துங்கள்',
    },

    // Impact Stats
    'Your Impact Today': {
      SupportedLanguage.english: 'Your Impact Today',
      SupportedLanguage.hindi: 'आज आपका प्रभाव',
      SupportedLanguage.tamil: 'இன்று உங்கள் தாக்கம்',
    },
    'Reports': {
      SupportedLanguage.english: 'Reports',
      SupportedLanguage.hindi: 'रिपोर्ट्स',
      SupportedLanguage.tamil: 'அறிக்கைகள்',
    },
    'Rank': {
      SupportedLanguage.english: 'Rank',
      SupportedLanguage.hindi: 'रैंक',
      SupportedLanguage.tamil: 'தரவரிசை',
    },

    // Community Activity
    'Community Activity': {
      SupportedLanguage.english: 'Community Activity',
      SupportedLanguage.hindi: 'सामुदायिक गतिविधि',
      SupportedLanguage.tamil: 'சமூக செயல்பாடு',
    },
    'View All': {
      SupportedLanguage.english: 'View All',
      SupportedLanguage.hindi: 'सभी देखें',
      SupportedLanguage.tamil: 'அனைத்தையும் பார்க்கவும்',
    },
    'No community activity yet': {
      SupportedLanguage.english: 'No community activity yet',
      SupportedLanguage.hindi: 'अभी तक कोई सामुदायिक गतिविधि नहीं',
      SupportedLanguage.tamil: 'இன்னும் சமூக செயல்பாடு இல்லை',
    },
    'Be the first to report waste in your area': {
      SupportedLanguage.english: 'Be the first to report waste in your area',
      SupportedLanguage.hindi: 'अपने क्षेत्र में कचरे की रिपोर्ट करने वाले पहले व्यक्ति बनें',
      SupportedLanguage.tamil: 'உங்கள் பகுதியில் கழிவுகளை புகாரளிக்கும் முதல் நபராக இருங்கள்',
    },

    // Time Formats
    'ago': {
      SupportedLanguage.english: 'ago',
      SupportedLanguage.hindi: 'पहले',
      SupportedLanguage.tamil: 'முன்பு',
    },
    'days': {
      SupportedLanguage.english: 'days',
      SupportedLanguage.hindi: 'दिन',
      SupportedLanguage.tamil: 'நாட்கள்',
    },
    'hours': {
      SupportedLanguage.english: 'hours',
      SupportedLanguage.hindi: 'घंटे',
      SupportedLanguage.tamil: 'மணிநேரங்கள்',
    },
    'minutes': {
      SupportedLanguage.english: 'minutes',
      SupportedLanguage.hindi: 'मिनट',
      SupportedLanguage.tamil: 'நிமிடங்கள்',
    },
  };

  String getLanguageName(SupportedLanguage language) {
    return _languageNames[language] ?? 'English';
  }

  Future<void> initializeTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selected_language') ?? 'english';
    
    _currentLanguage = SupportedLanguage.values.firstWhere(
      (lang) => lang.toString().split('.').last == languageCode,
      orElse: () => SupportedLanguage.english,
    );
  }

  Future<void> setLanguage(SupportedLanguage language) async {
    _currentLanguage = language;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language.toString().split('.').last);
  }

  String translate(String text) {
    if (_currentLanguage == SupportedLanguage.english) {
      return text;
    }

    final translations = _translations[text];
    if (translations != null && translations.containsKey(_currentLanguage)) {
      return translations[_currentLanguage]!;
    }
    
    return text; // Return original text if translation not found
  }

  Map<String, String> translateMap(Map<String, String> data) {
    if (_currentLanguage == SupportedLanguage.english) {
      return data;
    }

    final translatedData = <String, String>{};
    
    for (final entry in data.entries) {
      translatedData[entry.key] = translate(entry.value);
    }
    
    return translatedData;
  }
}