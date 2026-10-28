import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/client.dart';
import 'models/invoice.dart';
import 'models/invoice_item.dart';
import 'package:printing/printing.dart';
import 'services/invoice_pdf_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<Client> clients = [];

final List<Map<String, dynamic>> savedInvoices = [];

final List<Invoice> invoices = [];
String selectedFilter = 'All';
bool isLoading = true;


String selectedCurrencyCode = 'GBP';

String currencySymbolFor(String code) {
  switch (code) {
    case 'AED': return 'د.إ';
    case 'AFN': return '؋';
    case 'ALL': return 'L';
    case 'AMD': return '֏';
    case 'ANG': return 'ƒ';
    case 'AOA': return 'Kz';
    case 'ARS': return r'$';
    case 'AUD': return r'A$';
    case 'AWG': return 'ƒ';
    case 'AZN': return '₼';
    case 'BAM': return 'KM';
    case 'BBD': return r'Bds$';
    case 'BDT': return '৳';
    case 'BGN': return 'лв';
    case 'BHD': return 'د.ب';
    case 'BIF': return 'FBu';
    case 'BMD': return r'BD$';
    case 'BND': return r'B$';
    case 'BOB': return 'Bs.';
    case 'BRL': return r'R$';
    case 'BSD': return r'B$';
    case 'BTN': return 'Nu.';
    case 'BWP': return 'P';
    case 'BYN': return 'Br';
    case 'BZD': return r'BZ$';
    case 'CAD': return r'CA$';
    case 'CDF': return 'FC';
    case 'CHF': return 'CHF';
    case 'CLP': return r'CL$';
    case 'CNY': return '¥';
    case 'COP': return r'COL$';
    case 'CRC': return '₡';
    case 'CUP': return '₱';
    case 'CVE': return r'CV$';
    case 'CZK': return 'Kč';
    case 'DJF': return 'Fdj';
    case 'DKK': return 'kr';
    case 'DOP': return r'RD$';
    case 'DZD': return 'دج';
    case 'EGP': return 'E£';
    case 'ERN': return 'Nfk';
    case 'ETB': return 'Br';
    case 'EUR': return '€';
    case 'FJD': return r'FJ$';
    case 'FKP': return '£';
    case 'GBP': return '£';
    case 'GEL': return '₾';
    case 'GHS': return '₵';
    case 'GIP': return '£';
    case 'GMD': return 'D';
    case 'GNF': return 'FG';
    case 'GTQ': return 'Q';
    case 'GYD': return r'G$';
    case 'HKD': return r'HK$';
    case 'HNL': return 'L';
    case 'HTG': return 'G';
    case 'HUF': return 'Ft';
    case 'IDR': return 'Rp';
    case 'ILS': return '₪';
    case 'INR': return '₹';
    case 'IQD': return 'ع.د';
    case 'IRR': return '﷼';
    case 'ISK': return 'kr';
    case 'JMD': return r'J$';
    case 'JOD': return 'د.ا';
    case 'JPY': return '¥';
    case 'KES': return 'KSh';
    case 'KGS': return 'сом';
    case 'KHR': return '៛';
    case 'KMF': return 'CF';
    case 'KPW': return '₩';
    case 'KRW': return '₩';
    case 'KWD': return 'د.ك';
    case 'KYD': return r'CI$';
    case 'KZT': return '₸';
    case 'LAK': return '₭';
    case 'LBP': return 'ل.ل';
    case 'LKR': return 'රු';
    case 'LRD': return r'L$';
    case 'LSL': return 'L';
    case 'LYD': return 'ل.د';
    case 'MAD': return 'د.م.';
    case 'MDL': return 'L';
    case 'MGA': return 'Ar';
    case 'MKD': return 'ден';
    case 'MMK': return 'K';
    case 'MNT': return '₮';
    case 'MOP': return r'MOP$';
    case 'MRU': return 'UM';
    case 'MUR': return '₨';
    case 'MVR': return 'Rf';
    case 'MWK': return 'MK';
    case 'MXN': return r'MX$';
    case 'MYR': return 'RM';
    case 'MZN': return 'MT';
    case 'NAD': return r'N$';
    case 'NGN': return '₦';
    case 'NIO': return r'C$';
    case 'NOK': return 'kr';
    case 'NPR': return 'रू';
    case 'NZD': return r'NZ$';
    case 'OMR': return 'ر.ع.';
    case 'PAB': return 'B/.';
    case 'PEN': return 'S/';
    case 'PGK': return 'K';
    case 'PHP': return '₱';
    case 'PKR': return '₨';
    case 'PLN': return 'zł';
    case 'PYG': return '₲';
    case 'QAR': return 'ر.ق';
    case 'RON': return 'lei';
    case 'RSD': return 'дин.';
    case 'RUB': return '₽';
    case 'RWF': return 'FRw';
    case 'SAR': return 'ر.س';
    case 'SBD': return r'SI$';
    case 'SCR': return '₨';
    case 'SDG': return 'ج.س.';
    case 'SEK': return 'kr';
    case 'SGD': return r'S$';
    case 'SHP': return '£';
    case 'SLE': return 'Le';
    case 'SOS': return 'Sh';
    case 'SRD': return r'SR$';
    case 'SSP': return '£';
    case 'STN': return 'Db';
    case 'SYP': return '£';
    case 'SZL': return 'L';
    case 'THB': return '฿';
    case 'TJS': return 'ЅМ';
    case 'TMT': return 'm';
    case 'TND': return 'د.ت';
    case 'TOP': return r'T$';
    case 'TRY': return '₺';
    case 'TTD': return r'TT$';
    case 'TWD': return r'NT$';
    case 'TZS': return 'TSh';
    case 'UAH': return '₴';
    case 'UGX': return 'USh';
    case 'USD': return r'$';
    case 'UYU': return r'$U';
    case 'UZS': return 'soʻm';
    case 'VES': return 'Bs.';
    case 'VND': return '₫';
    case 'VUV': return 'VT';
    case 'WST': return r'WS$';
    case 'XAF': return 'FCFA';
    case 'XCD': return r'EC$';
    case 'XOF': return 'CFA';
    case 'XPF': return 'CFP';
    case 'YER': return '﷼';
    case 'ZAR': return 'R';
    case 'ZMW': return 'ZK';
    case 'ZWL': return r'Z$';
    default: return code;
  }
}


String get currencySymbol => currencySymbolFor(selectedCurrencyCode);

Map<String, dynamic> suggestedTaxForCountry(String country) {
  // Format: tax name, standard rate.
  // A null rate means the user should confirm it manually.
  const taxData = <String, List<dynamic>>{
    // Europe
    'Albania': ['VAT', 20.0],
    'Andorra': ['IGI', 4.5],
    'Armenia': ['VAT', 20.0],
    'Austria': ['VAT', 20.0],
    'Azerbaijan': ['VAT', 18.0],
    'Belarus': ['VAT', 20.0],
    'Belgium': ['VAT', 21.0],
    'Bosnia and Herzegovina': ['VAT', 17.0],
    'Bulgaria': ['VAT', 20.0],
    'Croatia': ['VAT', 25.0],
    'Cyprus': ['VAT', 19.0],
    'Czechia': ['VAT', 21.0],
    'Denmark': ['VAT', 25.0],
    'Estonia': ['VAT', 24.0],
    'Finland': ['VAT', 25.5],
    'France': ['VAT', 20.0],
    'Georgia': ['VAT', 18.0],
    'Germany': ['VAT', 19.0],
    'Greece': ['VAT', 24.0],
    'Hungary': ['VAT', 27.0],
    'Iceland': ['VAT', 24.0],
    'Ireland': ['VAT', 23.0],
    'Italy': ['VAT', 22.0],
    'Kosovo': ['VAT', 18.0],
    'Latvia': ['VAT', 21.0],
    'Liechtenstein': ['VAT', 8.1],
    'Lithuania': ['VAT', 21.0],
    'Luxembourg': ['VAT', 17.0],
    'Malta': ['VAT', 18.0],
    'Moldova': ['VAT', 20.0],
    'Monaco': ['VAT', 20.0],
    'Montenegro': ['VAT', 21.0],
    'Netherlands': ['VAT', 21.0],
    'North Macedonia': ['VAT', 18.0],
    'Norway': ['VAT', 25.0],
    'Poland': ['VAT', 23.0],
    'Portugal': ['VAT', 23.0],
    'Romania': ['VAT', 21.0],
    'Russia': ['VAT', 22.0],
    'San Marino': ['VAT', 0.0],
    'Serbia': ['VAT', 20.0],
    'Slovakia': ['VAT', 23.0],
    'Slovenia': ['VAT', 22.0],
    'Spain': ['VAT', 21.0],
    'Sweden': ['VAT', 25.0],
    'Switzerland': ['VAT', 8.1],
    'Turkey': ['VAT', 20.0],
    'Ukraine': ['VAT', 20.0],
    'United Kingdom': ['VAT', 20.0],

    // Asia
    'Afghanistan': ['Sales Tax', null],
    'Bangladesh': ['VAT', 15.0],
    'Bhutan': ['GST', 5.0],
    'Brunei': ['Sales Tax', null],
    'Cambodia': ['VAT', 10.0],
    'China': ['VAT', null],
    'India': ['GST', 18.0],
    'Indonesia': ['VAT', 12.0],
    'Iran': ['VAT', 10.0],
    'Iraq': ['Sales Tax', null],
    'Israel': ['VAT', 18.0],
    'Japan': ['Consumption Tax', 10.0],
    'Jordan': ['Sales Tax', 16.0],
    'Kazakhstan': ['VAT', 16.0],
    'Kuwait': ['VAT', null],
    'Kyrgyzstan': ['VAT', 12.0],
    'Laos': ['VAT', 10.0],
    'Lebanon': ['VAT', 11.0],
    'Malaysia': ['SST', null],
    'Maldives': ['GST', null],
    'Mongolia': ['VAT', 10.0],
    'Myanmar': ['Commercial Tax', null],
    'Nepal': ['VAT', 13.0],
    'North Korea': ['Sales Tax', null],
    'Oman': ['VAT', 5.0],
    'Pakistan': ['GST', null],
    'Palestine': ['VAT', 16.0],
    'Philippines': ['VAT', 12.0],
    'Qatar': ['VAT', null],
    'Saudi Arabia': ['VAT', 15.0],
    'Singapore': ['GST', 9.0],
    'South Korea': ['VAT', 10.0],
    'Sri Lanka': ['VAT', 18.0],
    'Syria': ['Sales Tax', null],
    'Taiwan': ['VAT', 5.0],
    'Tajikistan': ['VAT', null],
    'Thailand': ['VAT', 7.0],
    'Timor-Leste': ['Sales Tax', null],
    'Turkmenistan': ['VAT', 16.0],
    'United Arab Emirates': ['VAT', 5.0],
    'Uzbekistan': ['VAT', 12.0],
    'Vietnam': ['VAT', 10.0],
    'Yemen': ['Sales Tax', null],

    // Africa
    'Algeria': ['VAT', 19.0],
    'Angola': ['VAT', 14.0],
    'Benin': ['VAT', 18.0],
    'Botswana': ['VAT', 14.0],
    'Burkina Faso': ['VAT', 18.0],
    'Burundi': ['VAT', 18.0],
    'Cabo Verde': ['VAT', 15.0],
    'Cameroon': ['VAT', 19.25],
    'Central African Republic': ['VAT', 19.0],
    'Chad': ['VAT', 18.0],
    'Comoros': ['VAT', 10.0],
    'Democratic Republic of the Congo': ['VAT', 16.0],
    'Republic of the Congo': ['VAT', 18.9],
    'Côte d’Ivoire': ['VAT', 18.0],
    'Djibouti': ['VAT', 10.0],
    'Egypt': ['VAT', 14.0],
    'Equatorial Guinea': ['VAT', 15.0],
    'Eritrea': ['Sales Tax', null],
    'Eswatini': ['VAT', 15.0],
    'Ethiopia': ['VAT', 15.0],
    'Gabon': ['VAT', 18.0],
    'Gambia': ['VAT', 15.0],
    'Ghana': ['VAT', null],
    'Guinea': ['VAT', 18.0],
    'Guinea-Bissau': ['VAT', 15.0],
    'Kenya': ['VAT', 16.0],
    'Lesotho': ['VAT', 15.0],
    'Liberia': ['GST', 10.0],
    'Libya': ['Sales Tax', null],
    'Madagascar': ['VAT', 20.0],
    'Malawi': ['VAT', 16.5],
    'Mali': ['VAT', 18.0],
    'Mauritania': ['VAT', 16.0],
    'Mauritius': ['VAT', 15.0],
    'Morocco': ['VAT', 20.0],
    'Mozambique': ['VAT', 16.0],
    'Namibia': ['VAT', 15.0],
    'Niger': ['VAT', 19.0],
    'Nigeria': ['VAT', 7.5],
    'Rwanda': ['VAT', 18.0],
    'São Tomé and Príncipe': ['VAT', 15.0],
    'Senegal': ['VAT', 18.0],
    'Seychelles': ['VAT', 15.0],
    'Sierra Leone': ['GST', 15.0],
    'Somalia': ['Sales Tax', null],
    'South Africa': ['VAT', 15.0],
    'South Sudan': ['Sales Tax', null],
    'Sudan': ['VAT', 17.0],
    'Tanzania': ['VAT', 18.0],
    'Togo': ['VAT', 18.0],
    'Tunisia': ['VAT', 19.0],
    'Uganda': ['VAT', 18.0],
    'Zambia': ['VAT', 16.0],
    'Zimbabwe': ['VAT', 15.5],

    // North and Central America, Caribbean
    'Antigua and Barbuda': ['ABST', 17.0],
    'Bahamas': ['VAT', 10.0],
    'Barbados': ['VAT', 17.5],
    'Belize': ['GST', 12.5],
    'Canada': ['GST/HST', null],
    'Costa Rica': ['VAT', 13.0],
    'Cuba': ['Sales Tax', null],
    'Dominica': ['VAT', 15.0],
    'Dominican Republic': ['ITBIS', 18.0],
    'El Salvador': ['VAT', 13.0],
    'Grenada': ['VAT', 15.0],
    'Guatemala': ['VAT', 12.0],
    'Haiti': ['VAT', 10.0],
    'Honduras': ['Sales Tax', 15.0],
    'Jamaica': ['GCT', 15.0],
    'Mexico': ['VAT', 16.0],
    'Nicaragua': ['VAT', 15.0],
    'Panama': ['ITBMS', 7.0],
    'Saint Kitts and Nevis': ['VAT', 17.0],
    'Saint Lucia': ['VAT', 12.5],
    'Saint Vincent and the Grenadines': ['VAT', 16.0],
    'Trinidad and Tobago': ['VAT', 12.5],
    'United States': ['Sales Tax', null],

    // South America
    'Argentina': ['VAT', 21.0],
    'Bolivia': ['VAT', 13.0],
    'Brazil': ['Consumption Taxes', null],
    'Chile': ['VAT', 19.0],
    'Colombia': ['VAT', 19.0],
    'Ecuador': ['VAT', 15.0],
    'Guyana': ['VAT', 14.0],
    'Paraguay': ['VAT', 10.0],
    'Peru': ['IGV', 18.0],
    'Suriname': ['Sales Tax', null],
    'Uruguay': ['VAT', 22.0],
    'Venezuela': ['VAT', 16.0],

    // Oceania
    'Australia': ['GST', 10.0],
    'Fiji': ['VAT', 12.5],
    'Kiribati': ['VAT', 12.5],
    'Marshall Islands': ['Sales Tax', null],
    'Micronesia': ['Sales Tax', null],
    'Nauru': ['VAT', null],
    'New Zealand': ['GST', 15.0],
    'Palau': ['Sales Tax', null],
    'Papua New Guinea': ['GST', 10.0],
    'Samoa': ['VAT', 15.0],
    'Solomon Islands': ['Sales Tax', null],
    'Tonga': ['Consumption Tax', 15.0],
    'Tuvalu': ['VAT', null],
    'Vanuatu': ['VAT', 15.0],
  };

  final suggestion = taxData[country];

  if (suggestion == null) {
    return {'taxName': null, 'taxRate': null};
  }

  return {
    'taxName': suggestion[0],
    'taxRate': suggestion[1],
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const InvoicePilotApp());
}

class InvoicePilotApp extends StatelessWidget {
  const InvoicePilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InvoicePilot',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2864E8),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            return const DashboardScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

// ============================================================
// WELCOME / AUTH
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();
  bool _obscurePassword = true;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
        ),
      );
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }


    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'Unable to sign in. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId:
        '479283642397-nu3t15ldg2sr3mfj2oa5vbo78uetdvda.apps.googleusercontent.com',
      );

      final GoogleSignInAccount googleUser =
      await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.message}')),
      );

    } catch (e, stackTrace) {
      debugPrint('Google sign-in error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $e'),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Welcome to InvoicePilot',
      subtitle: 'Sign in to manage your invoices with ease.',
      children: [
        _FieldLabel('Email'),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Enter your email'),
        ),

        const SizedBox(height: 18),
        _FieldLabel('Password'),

        TextField(
          controller: passwordController,
          obscureText: _obscurePassword,
          decoration: _inputDecoration('Password').copyWith(
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: const Text(
              'Forgot your password? Reset it here',
              style: TextStyle(color: Color(0xFF2864E8)),
            ),
          ),
        ),
        const SizedBox(height: 8),

        _PrimaryButton(
          text: 'Sign In',
          onPressed: _login,
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            const Expanded(
              child: Divider(color: Color(0xFFDCE4F0)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Color(0xFF8795AA),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: Color(0xFFDCE4F0)),
            ),
          ],
        ),

        const SizedBox(height: 18),

        OutlinedButton.icon(
          onPressed: _signInWithGoogle,
          icon: Image.asset(
            'assets/google_logo.png',
            width: 26,
            height: 26,
            fit: BoxFit.contain,
          ),
          label: const Text('Continue with Google'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            foregroundColor: const Color(0xFF202124),
            side: const BorderSide(color: Color(0xFFDADCE0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              );
            },
            child: const Text(
              "New to InvoicePilot? Create an account",
              style: TextStyle(color: Color(0xFF2864E8)),
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController fullNameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();


  Future<void> _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final fullName = fullNameController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return;
    }



    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;

      await user?.updateDisplayName(fullName);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Your password is too weak.';
          break;
        case 'operation-not-allowed':
          message = 'Email and password accounts are not enabled.';
          break;
        default:
          message = 'Unable to create your account. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create Account',
      subtitle: 'Create your InvoicePilot account',
      children: [
        _FieldLabel('Full Name'),
        TextField(
          controller: fullNameController,
          decoration: _inputDecoration('Enter your full name'),
        ),
        const SizedBox(height: 18),
        _FieldLabel('Email'),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Enter your email'),
        ),
        const SizedBox(height: 18),
        _FieldLabel('Password'),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: _inputDecoration('Create a password'),
        ),
        const SizedBox(height: 18),
        _FieldLabel('Confirm Password'),
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: _inputDecoration('Confirm your password'),
        ),

        const SizedBox(height: 28),

        _PrimaryButton(
          text: 'Create Account',
          onPressed: _register,
        ),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Already have an account? Sign In',
              style: TextStyle(color: Color(0xFF2864E8)),
            ),
          ),
        ),
      ],
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final TextEditingController emailController =
  TextEditingController();

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address.'),
        ),
      );
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }


    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        default:
          message = 'Unable to send the reset link. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Forgot Password?',
      subtitle:
      'Enter your email address and we will send you a link to reset your password.',
      children: [
        _FieldLabel('Email'),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Enter your email'),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          text: 'Send Reset Link',
          onPressed: _resetPassword,
        ),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(color: Color(0xFF2864E8)),
            ),
          ),
        ),
      ],
    );
  }
}


class _AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Soft blue wave header
              SizedBox(
                height: 225,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      color: const Color(0xFFF8FBFF),
                      child: CustomPaint(
                        painter: InvoicePilotWavePainter(),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      top: 55,
                      child: Container(
                        width: 250,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB9E0FF).withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -60,
                      top: 100,
                      child: Container(
                        width: 280,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF79BCFF).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 35,
                      top: 75,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1687FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 75,
                      top: 115,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1687FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF32B8FF),
                                    Color(0xFF075BEE),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1677FF).withValues(alpha: 0.25),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),

                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // White invoice sheet
                                  Container(
                                    width: 29,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.fromLTRB(5, 7, 5, 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                            height: 3,
                                            child: ColoredBox(color: Color(0xFF8BD5FF)),
                                          ),
                                          SizedBox(height: 4),
                                          SizedBox(
                                            width: 16,
                                            height: 2,
                                            child: ColoredBox(color: Color(0xFF58B5FF)),
                                          ),
                                          SizedBox(height: 4),
                                          SizedBox(
                                            width: 13,
                                            height: 2,
                                            child: ColoredBox(color: Color(0xFF58B5FF)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Delicate white feather accent
                                  Positioned(
                                    right: 5,
                                    top: 20,
                                    child: SizedBox(
                                      width: 10,
                                      height: 14,
                                      child: CustomPaint(
                                        painter: FeatherLogoPainter(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'InvoicePilot',
                              style: TextStyle(
                                color: Color(0xFF101828),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Fly Through Your Invoicing',
                              style: TextStyle(
                                color: Color(0xFF667895),
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 27, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ...children,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Invoice> dashboardInvoices = [];


  String _formatCurrencyTotals(Iterable<Invoice> source) {
    final totals = <String, double>{};

    for (final invoice in source) {
      totals.update(
        invoice.currencyCode,
            (current) => current + invoice.total,
        ifAbsent: () => invoice.total,
      );
    }

    if (totals.isEmpty) {
      return '${currencySymbolFor(selectedCurrencyCode)}0.00';
    }

    final entries = totals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.length == 1) {
      final entry = entries.first;
      return '${currencySymbolFor(entry.key)}${entry.value.toStringAsFixed(2)}';
    }

    return entries.map((entry) {
      return '${entry.key} ${currencySymbolFor(entry.key)}${entry.value.toStringAsFixed(2)}';
    }).join('\n');
  }

  String _calculateDashboardRevenue() {
    return _formatCurrencyTotals(dashboardInvoices);
  }

  String _calculateDashboardOutstanding() {
    return _formatCurrencyTotals(
      dashboardInvoices.where((invoice) => invoice.status != 'Paid'),
    );
  }

  Future<void> _loadDashboardInvoices() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('invoices')
        .get();

    final loadedInvoices = snapshot.docs.map((doc) {
      return Invoice.fromMap(
        doc.data(),
        id: doc.id,
      );
    }).toList();

    if (!mounted) return;

    setState(() {
      dashboardInvoices = loadedInvoices;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadDashboardInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB0B0B0),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 28, 14, 20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateTime.now().hour < 12
                                    ? 'Good Morning,'
                                    : DateTime.now().hour < 17
                                    ? 'Good Afternoon,'
                                    : 'Good Evening,',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 6),
                              Text(
                                FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'InvoicePilot User',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        _CircleIconButton(
                          icon: Icons.notifications_none,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Revenue',
                            value: _calculateDashboardRevenue(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Outstanding',
                            value: _calculateDashboardOutstanding(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    _PrimaryButton(
                      text: '+ New Invoices',
                      onPressed: () async {
                        final saved = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateInvoiceScreen(),
                          ),
                        );

                        if (!mounted) return;

                        if (saved == true) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFE8F5E9),
                              behavior: SnackBarBehavior.floating,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFC8E6C9),
                                ),
                              ),
                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2E7D32),
                                    size: 16,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Invoice created successfully.',
                                      style: TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        _loadDashboardInvoices();
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Recent Invoices',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 13),

                    if (dashboardInvoices.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No invoices yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                    ...dashboardInvoices.map((invoice) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ClickableInvoiceCard(
                          invoiceNumber: invoice.invoiceNumber,
                          clientName: invoice.client,
                          date: 'Issued: ${invoice.issueDate}',
                          amount:
                          '${currencySymbolFor(invoice.currencyCode)}${invoice.total.toStringAsFixed(2)}',
                          status: invoice.status,
                          statusColor: invoice.status == 'Paid'
                              ? const Color(0xFF12B76A)
                              : invoice.status == 'Overdue'
                              ? const Color(0xFFD92D20)
                              : const Color(0xFF2864E8),
                          onTap: () async {
                            final String? changed = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InvoiceDetailsScreen(
                                  invoiceId: invoice.id,
                                  invoice: invoice,
                                  invoiceNumber: invoice.invoiceNumber,
                                  currencyCode: invoice.currencyCode,
                                  clientName: invoice.client,
                                  clientId: invoice.clientId,
                                  status: invoice.status,
                                  amount:
                                  '${currencySymbolFor(invoice.currencyCode)}${invoice.total.toStringAsFixed(2)}',
                                  vat: invoice.vat,
                                  items: invoice.items
                                      .map((item) => item.toMap())
                                      .toList(),
                                  issueDate: invoice.issueDate,
                                  dueDate: invoice.dueDate,
                                ),
                              ),
                            );

                            if (!mounted) return;

                            await _loadDashboardInvoices();

                            if (changed == 'updated' || changed == 'deleted') {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFFE8F5E9),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: Color(0xFFC8E6C9),
                                        ),
                                      ),
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF2E7D32),
                                            size: 16,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Invoice updated successfully!',
                                              style: TextStyle(
                                                color: Color(0xFF2E7D32),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
      const _BottomNavigation(selectedIndex: 0),
    );
  }
}

// ============================================================
// INVOICE LIST
// ============================================================

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() =>
      _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  String searchQuery = '';
  bool isLoading = true;

  Future<void> _loadInvoicesFromFirestore() async {
    setState(() {
      isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('invoices')
        .get();

    final loadedInvoices = snapshot.docs.map((doc) {
      return Invoice.fromMap(
        doc.data(),
        id: doc.id,
      );
    }).toList();

    if (!mounted) return;

    setState(() {
      invoices
        ..clear()
        ..addAll(loadedInvoices);
      isLoading = false;
    });
  }

  List<Invoice> get filteredInvoices {
    return invoices.where((invoice) {
      final matchesSearch =
          searchQuery.isEmpty ||
              '${invoice.client} ${invoice.invoiceNumber}'
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());

      final matchesFilter =
          selectedFilter == 'All' ||
              invoice.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadInvoicesFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    42,
                    15,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 28,
                            ),
                            onPressed: () =>
                                Navigator.pop(context),
                          ),
                          const SizedBox(width: 3),
                          const Expanded(
                            child: Text(
                              'Invoices',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _CircleIconButton(
                            icon: Icons.notifications_none,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration:
                        _inputDecoration('Search invoices...')
                            .copyWith(
                          prefixIcon:
                          const Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 19),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterButton(
                              label: 'All',
                              selected: selectedFilter == 'All',
                              onTap: () {
                                setState(() {
                                  selectedFilter = 'All';
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            _FilterButton(
                              label: 'Paid',
                              selected: selectedFilter == 'Paid',
                              onTap: () {
                                setState(() {
                                  selectedFilter = 'Paid';
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            _FilterButton(
                              label: 'Pending',
                              selected: selectedFilter == 'Pending',
                              onTap: () {
                                setState(() {
                                  selectedFilter = 'Pending';
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            _FilterButton(
                              label: 'Overdue',
                              selected: selectedFilter == 'Overdue',
                              onTap: () {
                                setState(() {
                                  selectedFilter = 'Overdue';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      ...filteredInvoices.map((invoice) {
                        final number = invoice.invoiceNumber;
                        return Padding(
                          padding:
                          const EdgeInsets.only(top: 12),
                          child: _ClickableInvoiceCard(
                            invoiceNumber: number,
                            clientName: invoice.client,
                            date:
                            'Issued: ${invoice.issueDate}',
                            amount:
                            '${currencySymbolFor(invoice.currencyCode)}${invoice.total.toStringAsFixed(2)}',
                            status: invoice.status,
                            statusColor:
                            invoice.status == 'Paid'
                                ? const Color(0xFF12B76A)
                                : invoice.status == 'Overdue'
                                ? const Color(0xFFD92D20)
                                : const Color(0xFF2864E8),
                            onTap: () async {
                              final changed = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InvoiceDetailsScreen(
                                        invoiceId: invoice.id,
                                        invoice: invoice,
                                        invoiceNumber: number,
                                        currencyCode: invoice.currencyCode,
                                        clientName: invoice.client,
                                        status: invoice.status,
                                        amount:
                                        '${currencySymbolFor(
                                            invoice.currencyCode)}${invoice
                                            .total.toStringAsFixed(2)}',
                                        items: invoice.items
                                            .map((item) => item.toMap())
                                            .toList(),
                                        issueDate: invoice.issueDate,
                                        dueDate: invoice.dueDate,
                                      ),
                                ),
                              );

                              if (!mounted) return;

                              // Only reload and show a message when an invoice changed.
                              if (changed == 'updated' ||
                                  changed == 'deleted') {
                                await _loadInvoicesFromFirestore();

                                if (!mounted) return;

                                final message = changed == 'deleted'
                                    ? 'Invoice deleted successfully!'
                                    : 'Invoice updated successfully!';

                                WidgetsBinding.instance.addPostFrameCallback((
                                    _) {
                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF2E7D32),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                message,
                                                style: const TextStyle(
                                                  color: Color(0xFF2E7D32),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(
                                            0xFFE8F5E9),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 3),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12),
                                          side: const BorderSide(
                                            color: Color(0xFFC8E6C9),
                                          ),
                                        ),
                                      ),
                                    );
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      const _BottomNavigation(selectedIndex: 1),
    );
  }
}

// ============================================================
// INVOICE DETAILS
// ============================================================

class InvoiceDetailsScreen extends StatelessWidget {
  final String? invoiceId;
  final Invoice? invoice;
  final String invoiceNumber;
  final String currencyCode;
  final String clientName;
  final String? clientId;
  final String status;
  final String amount;
  final double? vat;
  final List<dynamic>? items;
  final String issueDate;
  final String dueDate;

  const InvoiceDetailsScreen({
    super.key,
    this.invoiceId,
    this.invoice,
    required this.invoiceNumber,
    this.currencyCode = 'GBP',
    required this.clientName,
    this.clientId,
    required this.status,
    required this.amount,
    this.vat,
    this.items,
    this.issueDate = '24/07/2026',
    this.dueDate = '07/08/2026',
  });

  Future<Map<String, String>> _getClientContactDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    const emptyDetails = {
      'email': '',
      'phone': '',
      'address': '',
    };

    if (user == null) {
      return emptyDetails;
    }

    try {
      final clientsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('clients');

      // Prefer the exact client document when an ID is available.
      if (clientId != null && clientId!.isNotEmpty) {
        final clientDoc = await clientsRef.doc(clientId!).get();

        if (clientDoc.exists) {
          final data = clientDoc.data() ?? {};

          return {
            'email': (data['email'] ?? '').toString(),
            'phone': (data['phone'] ?? '').toString(),
            'address': (data['address'] ?? '').toString(),
          };
        }
      }

      // Backward compatibility for older invoices without clientId.
      final snapshot = await clientsRef
          .where('name', isEqualTo: clientName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return emptyDetails;
      }

      final data = snapshot.docs.first.data();

      return {
        'email': (data['email'] ?? '').toString(),
        'phone': (data['phone'] ?? '').toString(),
        'address': (data['address'] ?? '').toString(),
      };
    } catch (e, stackTrace) {
      debugPrint('Could not load client contact details: $e');
      debugPrintStack(stackTrace: stackTrace);
      return emptyDetails;
    }
  }

  Future<Map<String, String>> _getBusinessProfile() async {
    const emptyProfile = {
      'businessName': '',
      'email': '',
      'phone': '',
      'address': '',
      'website': '',
      'taxNumber': '',
    };

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return emptyProfile;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final rawProfile = userDoc.data()?['businessProfile'];
      if (rawProfile is! Map) return emptyProfile;

      return {
        for (final key in emptyProfile.keys)
          key: (rawProfile[key] ?? '').toString(),
      };
    } catch (e, stackTrace) {
      debugPrint('Could not load business profile for PDF: $e');
      debugPrintStack(stackTrace: stackTrace);
      return emptyProfile;
    }
  }

  Future<Map<String, String>> _getPaymentSettings() async {
    const emptySettings = <String, String>{
      'stripePaymentLink': '',
      'paypalPaymentLink': '',
      'customPaymentMethodName': '',
      'customPaymentLink': '',
      'bankAccountName': '',
      'bankName': '',
      'bankAccountNumber': '',
      'bankRouting': '',
      'bankPaymentInstructions': '',
    };

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return emptySettings;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final rawSettings = userDoc.data()?['paymentSettings'];

      if (rawSettings is! Map<String, dynamic>) {
        return emptySettings;
      }

      return {
        for (final key in emptySettings.keys)
          key: rawSettings[key]?.toString() ?? '',
      };
    } catch (e, stackTrace) {
      debugPrint('Failed to load payment settings: $e');
      debugPrintStack(stackTrace: stackTrace);
      return emptySettings;
    }
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: Text(
          'Are you sure you want to delete $invoiceNumber?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );

    // Do nothing if the user cancels.
    if (shouldDelete != true) {
      return false;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('You must be signed in to delete an invoice.');
      }

      if (invoiceId == null || invoiceId!.isEmpty) {
        throw Exception('Invoice ID is missing. Please reopen the invoice.');
      }

      // Delete the invoice from Firestore.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('invoices')
          .doc(invoiceId!)
          .delete();

      // Remove it from the local list.
      invoices.removeWhere(
            (item) => item.id == invoiceId,
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint('Invoice deletion failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('Could not delete invoice: $e'),
              backgroundColor: Colors.red.shade700,
            ),
          );
      }

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = items ??
        [
          {
            'description': 'Logo Design',
            'amount': 250.0,
          },
          {
            'description': 'Business Cards',
            'amount': 200.0,
          },
        ];

    final displaySubtotal =
    displayItems.fold<double>(
      0,
          (total, item) =>
      total + (item['amount'] as num).toDouble(),
    );
    final displayVatRate = invoice?.vatRate ?? 20.0;
    final displayVat = vat ??
        (displaySubtotal * (displayVatRate / 100));
    final displayTotal = displaySubtotal + displayVat;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 8, 18, 8),
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              18,
              25,
              18,
              30,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _PageHeader(title: 'Invoice Details'),
                const SizedBox(height: 18),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          invoiceNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(),
                _detailLabel('Client'),
                _detailValue(clientName),
                const SizedBox(height: 14),
                const Divider(),
                _detailLabel('Issue Date'),
                _detailValue(issueDate),
                const SizedBox(height: 14),
                const Divider(),
                _detailLabel('Due Date'),
                _detailValue(dueDate),

                const SizedBox(height: 18),

                OutlinedButton(
                  onPressed: () async {
                    final newStatus = await showDialog<String>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Change Invoice Status'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('Pending'),
                                onTap: () {
                                  Navigator.pop(dialogContext, 'Pending');
                                },
                              ),
                              ListTile(
                                title: const Text('Paid'),
                                onTap: () {
                                  Navigator.pop(dialogContext, 'Paid');
                                },
                              ),
                              ListTile(
                                title: const Text('Overdue'),
                                onTap: () {
                                  Navigator.pop(dialogContext, 'Overdue');
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    if (newStatus == null) {
                      return;
                    }

                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      return;
                    }

                    if (invoiceId == null) {
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('invoices')
                        .doc(invoiceId)
                        .update({
                      'status': newStatus,
                    });

                    for (int i = 0; i < invoices.length; i++) {
                      if (invoices[i].id == invoiceId) {
                        final oldInvoice = invoices[i];

                        invoices[i] = Invoice(
                          id: oldInvoice.id,
                          invoiceNumber: oldInvoice.invoiceNumber,
                          currencyCode: oldInvoice.currencyCode,
                          client: oldInvoice.client,
                          issueDate: oldInvoice.issueDate,
                          dueDate: oldInvoice.dueDate,
                          subtotal: oldInvoice.subtotal,
                          vat: oldInvoice.vat,
                          vatRate: oldInvoice.vatRate,
                          total: oldInvoice.total,
                          status: newStatus,
                          items: oldInvoice.items,
                        );

                        break;
                      }
                    }

                    if (context.mounted) {
                      Navigator.pop(context, 'updated');
                    }
                  },
                  child: Text('Change Status'),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF999999),
                    ),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (int i = 0;
                      i < displayItems.length;
                      i++) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayItems[i]
                                ['description']
                                    .toString(),
                              ),
                            ),
                            Text(
                              '${currencySymbolFor(currencyCode)}${(displayItems[i]['amount'] as num).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        if (i <
                            displayItems.length - 1)
                          const Padding(
                            padding:
                            EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: Divider(),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _totalRow(
                  'SubTotal',
                  '${currencySymbolFor(currencyCode)}${displaySubtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 14),
                _totalRow(
                  '${invoice?.taxName ?? 'VAT'} (${displayVatRate.toStringAsFixed(2)}%)',
                  '${currencySymbolFor(currencyCode)}${displayVat.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _totalRow(
                  'Total',
                  '${currencySymbolFor(currencyCode)}${displayTotal.toStringAsFixed(2)}',
                  large: true,
                ),
                const SizedBox(height: 15),
                _PrimaryButton(
                  text: 'Edit Invoice',
                  onPressed: () async {
                    if (invoice == null) {
                      return;
                    }

                    final changed = await Navigator.push(

                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateInvoiceScreen(
                          invoice: invoice,
                        ),
                      ),
                    );
                    if (changed == 'updated' && context.mounted) {
                      Navigator.pop<String>(context, 'updated');
                    }
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child:
                  OutlinedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null || invoiceId == null) {
                        return;
                      }

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('invoices')
                          .doc(invoiceId)
                          .update({
                        'status': 'Paid',
                      });

                      for (int i = 0; i < invoices.length; i++) {
                        if (invoices[i].id == invoiceId) {
                          final oldInvoice = invoices[i];

                          invoices[i] = Invoice(
                            id: oldInvoice.id,
                            invoiceNumber: oldInvoice.invoiceNumber,
                            currencyCode: oldInvoice.currencyCode,
                            client: oldInvoice.client,
                            issueDate: oldInvoice.issueDate,
                            dueDate: oldInvoice.dueDate,
                            subtotal: oldInvoice.subtotal,
                            vat: oldInvoice.vat,
                            vatRate: oldInvoice.vatRate,
                            total: oldInvoice.total,
                            status: 'Paid',
                            items: oldInvoice.items,
                          );

                          break;
                        }
                      }

                      if (context.mounted) {
                        Navigator.pop<String>(context, 'updated');
                      }
                    },
                    child: const Text('Mark as Paid'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () async {
                      final contactDetails = await _getClientContactDetails();
                      final businessProfile = await _getBusinessProfile();
                      final paymentSettings = await _getPaymentSettings();

                      if (!context.mounted) return;

                      final pdfData = await InvoicePdfService.generateInvoicePdf(
                        stripePaymentLink: paymentSettings['stripePaymentLink'] ?? '',
                        paypalPaymentLink: paymentSettings['paypalPaymentLink'] ?? '',
                        customPaymentMethodName:
                        paymentSettings['customPaymentMethodName'] ?? '',
                        customPaymentLink:
                        paymentSettings['customPaymentLink'] ?? '',
                        bankAccountName: paymentSettings['bankAccountName'] ?? '',
                        bankName: paymentSettings['bankName'] ?? '',
                        bankAccountNumber: paymentSettings['bankAccountNumber'] ?? '',
                        bankRouting: paymentSettings['bankRouting'] ?? '',
                        bankPaymentInstructions:
                        paymentSettings['bankPaymentInstructions'] ?? '',
                        invoiceNumber: invoiceNumber,
                        clientName: clientName,
                        clientEmail: contactDetails['email']!,
                        clientPhone: contactDetails['phone']!,
                        clientAddress: contactDetails['address']!,
                        businessName: businessProfile['businessName']!,
                        businessEmail: businessProfile['email']!,
                        businessPhone: businessProfile['phone']!,
                        businessAddress: businessProfile['address']!,
                        businessWebsite: businessProfile['website']!,
                        businessTaxNumber: businessProfile['taxNumber']!,
                        issueDate: issueDate,
                        dueDate: dueDate,
                        status: status,
                        subtotal: displaySubtotal,
                        vat: displayVat,
                        vatRate: displayVatRate,
                        taxName: invoice?.taxName ?? 'VAT',
                        total: displayTotal,
                        items: displayItems
                            .map<Map<String, dynamic>>(
                              (item) => Map<String, dynamic>.from(item),
                        )
                            .toList(),
                        currencySymbol: currencySymbolFor(currencyCode),
                      );

                      await Printing.layoutPdf(
                        onLayout: (_) async => pdfData,
                      );
                    },
                    child: const Text('Generate PDF'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () async {
                      final businessProfile = await _getBusinessProfile();
                      final paymentSettings = await _getPaymentSettings();
                      final pdfData =
                      await InvoicePdfService.generateInvoicePdf(
                        stripePaymentLink: paymentSettings['stripePaymentLink'] ?? '',
                        paypalPaymentLink: paymentSettings['paypalPaymentLink'] ?? '',
                        customPaymentMethodName:
                        paymentSettings['customPaymentMethodName'] ?? '',
                        customPaymentLink:
                        paymentSettings['customPaymentLink'] ?? '',
                        bankAccountName: paymentSettings['bankAccountName'] ?? '',
                        bankName: paymentSettings['bankName'] ?? '',
                        bankAccountNumber: paymentSettings['bankAccountNumber'] ?? '',
                        bankRouting: paymentSettings['bankRouting'] ?? '',
                        bankPaymentInstructions:
                        paymentSettings['bankPaymentInstructions'] ?? '',
                        invoiceNumber: invoiceNumber,
                        clientName: clientName,
                        businessName: businessProfile['businessName']!,
                        businessEmail: businessProfile['email']!,
                        businessPhone: businessProfile['phone']!,
                        businessAddress: businessProfile['address']!,
                        businessWebsite: businessProfile['website']!,
                        businessTaxNumber: businessProfile['taxNumber']!,
                        issueDate: issueDate,
                        dueDate: dueDate,
                        status: status,
                        subtotal: displaySubtotal,
                        vat: displayVat,
                        vatRate: displayVatRate,
                        taxName: invoice?.taxName ?? 'VAT',
                        total: displayTotal,
                        items: displayItems
                            .map((item) => Map<String, dynamic>.from(item))
                            .toList(),
                        currencySymbol: currencySymbolFor(currencyCode),
                      );

                      await Printing.sharePdf(
                        bytes: pdfData,
                        filename: 'invoice_$invoiceNumber.pdf',
                      );
                    },
                    child: const Text('Share PDF'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () async {
                      final deleted = await _showDeleteConfirmation(context);

                      if (!context.mounted) return;

                      if (deleted == true) {
                        Navigator.pop(context, 'deleted');
                      }
                    },
                    child: const Text('Delete Invoice'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _detailLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _detailValue(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF808080),
        ),
      ),
    );
  }

  static Widget _totalRow(
      String label,
      String value, {
        bool large = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: large ? 20 : 13,
                fontWeight:
                large ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 23 : 13,
              fontWeight:
              large ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CREATE INVOICE
// ============================================================

class CreateInvoiceScreen extends StatefulWidget {
  final Invoice? invoice;

  const CreateInvoiceScreen({
    super.key,
    this.invoice,
  });

  @override
  State<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState
    extends State<CreateInvoiceScreen> {
  bool isSaving = false;
  bool showValidationErrors = false;
  String? selectedClient;
  String? selectedClientId;
  late String invoiceCurrencyCode;
  double vatRate = 20.0;
  String taxName = 'VAT';
  bool isCustomTaxRate = false;
  final TextEditingController customTaxRateController =
  TextEditingController();
  String issueDate = '';
  String dueDate = '';

  final List<String> itemDescriptions = [];

  final List<double> itemAmounts = [];

  Future<void> _loadClients() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('clients')
        .get();

    final loadedClients = snapshot.docs.map((doc) {
      return Client.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      clients
        ..clear()
        ..addAll(loadedClients);
    });
  }



  Future<void> _loadDefaultTaxSettings() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.invoice != null) {
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = doc.data() ?? {};

      final settings =
      data['taxSettings'] as Map<String, dynamic>?;

      String suggestedTaxName = 'VAT';
      double suggestedTaxRate = 20.0;

      // Use saved tax settings first.
      if (settings != null) {
        suggestedTaxName =
            settings['taxName'] as String? ?? 'VAT';

        suggestedTaxRate =
            (settings['taxRate'] as num?)?.toDouble() ?? 20.0;
      } else {
        // Only suggest tax based on country when settings
        // have not been saved yet.
        final location =
        data['businessLocation'] as Map<String, dynamic>?;

        final country = location?['country'] as String?;

        if (country != null && country.isNotEmpty) {
          final suggestion = suggestedTaxForCountry(country);

          final name = suggestion['taxName'];
          final rate = suggestion['taxRate'];

          if (name is String && name.isNotEmpty) {
            suggestedTaxName = name;
          }
          if (rate is num) {
            suggestedTaxRate = rate.toDouble();
          } else {
            // No automatic rate available for this country.
            suggestedTaxRate = 0.0;
          }
        }
      }

      setState(() {
        vatRate = suggestedTaxRate;
        taxName = suggestedTaxName;

        isCustomTaxRate =
        ![0.0, 5.0, 10.0, 20.0].contains(suggestedTaxRate);

        customTaxRateController.text =
        isCustomTaxRate ? suggestedTaxRate.toString() : '';
      });
    } catch (e) {
      debugPrint('Could not load default tax settings: $e');
    }
  }


  @override
  void initState() {
    super.initState();

    _loadClients();

    final invoice = widget.invoice;
    invoiceCurrencyCode = invoice?.currencyCode ?? selectedCurrencyCode;

    if (invoice != null) {
      selectedClient = invoice.client;
      selectedClientId = invoice.clientId;
      issueDate = invoice.issueDate;
      dueDate = invoice.dueDate;
      vatRate = invoice.vatRate;
      taxName = invoice.taxName;

      isCustomTaxRate =
      ![0.0, 5.0, 10.0, 20.0].contains(vatRate);

      if (isCustomTaxRate) {
        customTaxRateController.text = vatRate.toString();
      }

      itemDescriptions.addAll(
        invoice.items.map((item) => item.description),
      );

      itemAmounts.addAll(
        invoice.items.map((item) => item.amount),
      );
    } else {
      if (widget.invoice == null) {
        _loadDefaultTaxSettings();
      }

      final today = DateTime.now();
      final defaultDueDate = today.add(const Duration(days: 14));

      issueDate =
      '${today.day.toString().padLeft(2, '0')}/'
          '${today.month.toString().padLeft(2, '0')}/'
          '${today.year}';

      dueDate =
      '${defaultDueDate.day.toString().padLeft(2, '0')}/'
          '${defaultDueDate.month.toString().padLeft(2, '0')}/'
          '${defaultDueDate.year}';

      itemDescriptions.add('');
      itemAmounts.add(0.00);
    }
  }

  double get subtotal =>
      itemAmounts.fold(0, (total, amount) => total + amount);

  double get vat => subtotal * (vatRate / 100);

  double get total => subtotal + vat;


  Future<void> _pickDate(bool issue) async {
    final currentDate = (issue ? issueDate : dueDate).split('/');

    final initialDate = currentDate.length == 3
        ? DateTime(
      int.parse(currentDate[2]),
      int.parse(currentDate[1]),
      int.parse(currentDate[0]),
    )
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    final value =
        '${picked.day.toString().padLeft(2, '0')}/'
        '${picked.month.toString().padLeft(2, '0')}/'
        '${picked.year}';

    setState(() {
      if (issue) {
        issueDate = value;
      } else {
        dueDate = value;
      }
    });
  }

  Future<void> _saveInvoice() async {
    debugPrint(
      'SAVE CHECK: editing=${widget.invoice != null}, '
          'id=${widget.invoice?.id}',
    );
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }


    setState(() {
      showValidationErrors = true;
    });

    final issueParts = issueDate.split('/');
    final dueParts = dueDate.split('/');

    final issue = DateTime(
      int.parse(issueParts[2]),
      int.parse(issueParts[1]),
      int.parse(issueParts[0]),
    );

    final due = DateTime(
      int.parse(dueParts[2]),
      int.parse(dueParts[1]),
      int.parse(dueParts[0]),
    );

    final today = DateUtils.dateOnly(DateTime.now());

    final hasClient =
        selectedClient != null && selectedClient!.isNotEmpty;

    final issueDateValid = !issue.isAfter(today);
    final dueDateValid = !due.isBefore(issue);

    final descriptionsValid = itemDescriptions.isNotEmpty &&
        itemDescriptions.every(
              (description) =>
          description
              .trim()
              .isNotEmpty,
        );

    final amountsValid = itemAmounts.isNotEmpty &&
        itemAmounts.every((amount) => amount > 0);
    final customTaxRateValid = !isCustomTaxRate ||
        (customTaxRateController.text
            .trim()
            .isNotEmpty &&
            double.tryParse(customTaxRateController.text.trim()) != null &&
            double.parse(customTaxRateController.text.trim()) >= 0 &&
            double.parse(customTaxRateController.text.trim()) <= 100);

    if (!hasClient ||
        !issueDateValid ||
        !dueDateValid ||
        !descriptionsValid ||
        !amountsValid ||
        !customTaxRateValid) {
      setState(() {
        isSaving = false;
      });
      return;
    }


    final items = List.generate(
      itemDescriptions.length,
          (index) =>
          InvoiceItem(
            description: itemDescriptions[index],
            amount: itemAmounts[index],
          ),
    );
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text('Saving invoice...'),
              ),
            ],
          ),
        );
      },
    );

    try {
      // EDITING AN EXISTING INVOICE
      if (widget.invoice != null) {
        final oldInvoice = widget.invoice!;

        final updatedInvoice = Invoice(
          id: oldInvoice.id,
          invoiceNumber: oldInvoice.invoiceNumber,
          currencyCode: oldInvoice.currencyCode,
          client: selectedClient ?? oldInvoice.client,
          clientId: selectedClientId ?? oldInvoice.clientId,
          issueDate: issueDate,
          dueDate: dueDate,
          subtotal: subtotal,
          vat: vat,
          vatRate: vatRate,
          taxName: taxName,
          total: total,
          status: oldInvoice.status,
          items: items,
        );

        if (oldInvoice.id == null) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();

            setState(() {
              isSaving = false;
            });
          }
          return;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('invoices')
            .doc(oldInvoice.id)
            .update(updatedInvoice.toMap());
        debugPrint('EDIT SAVE: Firestore update completed');

        for (int i = 0; i < invoices.length; i++) {
          if (invoices[i].id == oldInvoice.id) {
            invoices[i] = updatedInvoice;
            break;
          }
        }

        if (!mounted) return;

        // Close the loading dialog.
        Navigator.of(context, rootNavigator: true).pop();

// Return an update result to the invoice details screen.
        if (!mounted) return;

        Navigator.pop<String>(context, 'updated');
        return;
      }

// CREATING A NEW INVOICE
      final number = await _generateInvoiceNumber();

      final invoice = Invoice(
        invoiceNumber: number,
        currencyCode: invoiceCurrencyCode,
        client: selectedClient ?? 'No client',
        clientId: selectedClientId,
        issueDate: issueDate,
        dueDate: dueDate,
        subtotal: subtotal,
        vat: vat,
        vatRate: vatRate,
        taxName: taxName,
        total: total,
        status: 'Pending',
        items: items,
      );

      savedInvoices.add(invoice.toMap());

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('invoices')
          .add(invoice.toMap());

      final savedInvoice = Invoice(
        id: docRef.id,
        invoiceNumber: invoice.invoiceNumber,
        currencyCode: invoice.currencyCode,
        clientId: invoice.clientId,
        client: invoice.client,
        issueDate: invoice.issueDate,
        dueDate: invoice.dueDate,
        subtotal: invoice.subtotal,
        vat: invoice.vat,
        vatRate: invoice.vatRate,
        taxName: invoice.taxName,
        total: invoice.total,
        status: invoice.status,
        items: invoice.items,
      );

      invoices.add(savedInvoice);

      if (!mounted) return;

// Close the loading dialog.
      Navigator.of(context, rootNavigator: true).pop();

      await Future<void>.delayed(Duration.zero);

      if (!mounted) return;

// Return success to the previous screen.
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Could not save invoice: $e');

      if (!mounted) return;

// Close the loading dialog.
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong while saving the invoice.',
          ),
        ),
      );
    }
  }

  Future<String> _generateInvoiceNumber() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'INV-0001';
    }

    final counterRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('invoiceCounter');

    final invoicesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('invoices');

    final nextNumber = await FirebaseFirestore.instance
        .runTransaction<int>((transaction) async {
      final counterSnapshot = await transaction.get(counterRef);

      int currentNumber = 0;

      if (counterSnapshot.exists) {
        final data = counterSnapshot.data();

        if (data != null && data['value'] is num) {
          currentNumber = (data['value'] as num).toInt();
        }
      } else {
        final invoicesSnapshot = await invoicesRef.get();

        for (final doc in invoicesSnapshot.docs) {
          final invoiceNumber =
              doc.data()['invoiceNumber']?.toString() ?? '';

          if (invoiceNumber.startsWith('NEW-') ||
              invoiceNumber.startsWith('INV-')) {
            final numberText = invoiceNumber.startsWith('NEW-')
                ? invoiceNumber.replaceFirst('NEW-', '')
                : invoiceNumber.replaceFirst('INV-', '');

            final number = int.tryParse(numberText);

            if (number != null && number > currentNumber) {
              currentNumber = number;
            }
          }
        }
      }

      final newNumber = currentNumber + 1;

      transaction.set(
        counterRef,
        {
          'value': newNumber,
        },
      );

      return newNumber;
    });

    return 'INV-${nextNumber.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            8,
          ),
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              10,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _PageHeader(title: widget.invoice == null ? 'Create Invoice' : 'Edit Invoice'),

                const SizedBox(height: 25),
                const _FormLabel('Client'),
                const SizedBox(height: 7),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  decoration: _boxDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (() {
                        final validIds = clients
                            .map((client) => client.id)
                            .whereType<String>()
                            .toSet();

                        if (selectedClientId != null &&
                            validIds.contains(selectedClientId)) {
                          return selectedClientId;
                        }

                        return null;
                      })(),
                      isExpanded: true,
                      hint: const Text('Select a client'),
                      items: [
                        ...clients
                            .where((client) => client.id != null && client.id!.isNotEmpty)
                            .map(
                              (client) => DropdownMenuItem<String>(
                            value: client.id!,
                            child: Text(client.name),
                          ),
                        ),
                        if (widget.invoice != null &&
                            (selectedClientId == null ||
                                !clients.any((client) => client.id == selectedClientId)))
                          DropdownMenuItem<String>(
                            value: '__deleted_original_client__',
                            child: Text('${widget.invoice!.client} (deleted client)'),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          if (value == '__deleted_original_client__') {
                            selectedClient = widget.invoice!.client;
                            selectedClientId = widget.invoice!.clientId;
                          } else {
                            final client = clients.firstWhere(
                                  (client) => client.id == value,
                            );

                            selectedClient = client.name;
                            selectedClientId = client.id;
                          }
                        });
                      },
                    ),
                  ),
                ),

                if (showValidationErrors &&
                    (selectedClient == null || selectedClient!.isEmpty))
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Please select a client.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 13),

                _FormLabel('$taxName Rate'),
                const SizedBox(height: 7),

                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  decoration: _boxDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: isCustomTaxRate ? -1.0 : vatRate,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('0%')),
                        DropdownMenuItem(value: 5.0, child: Text('5%')),
                        DropdownMenuItem(value: 10.0, child: Text('10%')),
                        DropdownMenuItem(value: 20.0, child: Text('20%')),
                        DropdownMenuItem(value: -1.0, child: Text('Custom rate')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          if (value == -1.0) {
                            isCustomTaxRate = true;
                            customTaxRateController.text =
                                vatRate.toString();
                          } else {
                            isCustomTaxRate = false;
                            vatRate = value;
                          }
                        });
                      },
                    ),
                  ),
                ),

                if (isCustomTaxRate) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customTaxRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Enter tax rate (%)',
                      hintText: 'e.g. 7.5',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      final rate = double.tryParse(value.trim());

                      if (rate != null && rate >= 0 && rate <= 100) {
                        setState(() {
                          vatRate = rate;
                        });
                      }
                    },
                  ),
                  if (showValidationErrors &&
                      (customTaxRateController.text.trim().isEmpty ||
                          double.tryParse(customTaxRateController.text.trim()) == null ||
                          double.tryParse(customTaxRateController.text.trim())! < 0 ||
                          double.tryParse(customTaxRateController.text.trim())! > 100))
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter a tax rate between 0% and 100%.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],


                const _FormLabel('Issue Date'),
                const SizedBox(height: 7),
                InkWell(
                  onTap: () => _pickDate(true),
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            issueDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Color(0xFF667085),
                        ),
                      ],
                    ),
                  ),
                ),

                if (showValidationErrors &&
                    DateTime(
                      int.parse(issueDate.split('/')[2]),
                      int.parse(issueDate.split('/')[1]),
                      int.parse(issueDate.split('/')[0]),
                    ).isAfter(DateUtils.dateOnly(DateTime.now())))
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Issue date cannot be in the future.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 13),
                const _FormLabel('Due Date'),
                const SizedBox(height: 7),
                InkWell(
                  onTap: () => _pickDate(false),
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dueDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Color(0xFF667085),
                        ),
                      ],
                    ),
                  ),
                ),

                if (showValidationErrors &&
                    DateTime(
                      int.parse(dueDate.split('/')[2]),
                      int.parse(dueDate.split('/')[1]),
                      int.parse(dueDate.split('/')[0]),
                    ).isBefore(
                      DateTime(
                        int.parse(issueDate.split('/')[2]),
                        int.parse(issueDate.split('/')[1]),
                        int.parse(issueDate.split('/')[0]),
                      ),
                    ))
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Due date cannot be before the issue date.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 25),
                const Text(
                  'Invoice Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    12,
                  ),
                  decoration: _boxDecoration(),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (int index = 0;
                      index < itemDescriptions.length;
                      index++) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _EditableInvoiceInput(
                                initialText:
                                itemDescriptions[index],
                                height: 37,
                                onChanged: (value) {
                                  setState(() {
                                    itemDescriptions[index] = value;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete item',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (itemDescriptions.length ==
                                    1) {
                                  return;
                                }

                                setState(() {
                                  itemDescriptions
                                      .removeAt(index);
                                  itemAmounts.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),

                        if (showValidationErrors &&
                            itemDescriptions[index].trim().isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Please enter an item description.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),
                        const Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        _EditableInvoiceInput(
                          initialText: itemAmounts[index] == 0.00
                              ? ''
                              : itemAmounts[index].toStringAsFixed(2),
                          prefixText: currencySymbolFor(invoiceCurrencyCode),
                          height: 37,
                          onChanged: (value) {
                            final parsed = double.tryParse(value.trim());
                            setState(() {
                              itemAmounts[index] = parsed ?? 0.0;
                            });
                          },
                        ),
                        if (showValidationErrors && itemAmounts[index] <= 0)
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Amount must be greater than zero.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        if (index <
                            itemDescriptions.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    setState(() {
                      itemDescriptions.add('');
                      itemAmounts.add(0.00);
                    });
                  },
                  child: const Text(
                    '+ Add Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2864E8),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                _totalRow(
                  'Subtotal',
                  '${currencySymbolFor(invoiceCurrencyCode)}${subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 14),
                _totalRow(
                  '$taxName (${vatRate.toStringAsFixed(vatRate.truncateToDouble() == vatRate ? 0 : 2)}%)',
                  '${currencySymbolFor(invoiceCurrencyCode)}${vat.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 7),
                const Divider(),
                const SizedBox(height: 7),
                _totalRow(
                  'Total',
                  '${currencySymbolFor(invoiceCurrencyCode)}${total.toStringAsFixed(2)}',
                  large: true,
                ),
                const SizedBox(height: 13),
                _PrimaryButton(
                  text: isSaving ? 'Saving...' : (widget.invoice == null ? 'Save Invoice' : 'Save Changes'),
                  onPressed: isSaving ? null : _saveInvoice,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalRow(
      String label,
      String value, {
        bool large = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: large ? 20 : 14,
                fontWeight:
                large ? FontWeight.bold : FontWeight.w600,
                color: const Color(0xFF111111),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 23 : 14,
              fontWeight:
              large ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CLIENTS
// ============================================================

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  bool _isLoadingClients = true;
  String? _clientsLoadError;

  @override
  void initState() {
    super.initState();
    _loadClientsFromFirestore();
  }

  Future<void> _loadClientsFromFirestore() async {
    final stopwatch = Stopwatch()..start();
    final user = FirebaseAuth.instance.currentUser;

    debugPrint('========== CLIENT DEBUG ==========');
    debugPrint('Signed-in UID: ${user?.uid}');
    debugPrint('Signed-in email: ${user?.email}');

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoadingClients = false;
        _clientsLoadError = 'Please sign in to view your clients.';
      });
      return;
    }

    setState(() {
      _isLoadingClients = true;
      _clientsLoadError = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('clients')
          .get()
          .timeout(const Duration(seconds: 20));

      final loadedClients = snapshot.docs.map((doc) {
        return Client.fromMap({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();

      debugPrint(
        'Client fetch completed in '
            '${stopwatch.elapsedMilliseconds} ms',
      );
      debugPrint('Clients found: ${loadedClients.length}');
      debugPrint(
        'Client names: '
            '${loadedClients.map((client) => client.name).toList()}',
      );

      if (!mounted) return;

      setState(() {
        clients
          ..clear()
          ..addAll(loadedClients);

        _isLoadingClients = false;
        _clientsLoadError = null;
      });
    } catch (e, stackTrace) {
      debugPrint('CLIENT FETCH FAILED: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoadingClients = false;
        _clientsLoadError =
        'Unable to load clients. Please try again.';
      });
    } finally {
      debugPrint('========== END CLIENT DEBUG ==========');
    }
  }

  Future<void> _openAddClient() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddClientScreen(),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      await _loadClientsFromFirestore();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 16,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Client saved successfully!',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE8F5E9),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color(0xFFC8E6C9),
              ),
            ),
          ),
        );
    }
  }

  Future<void> _openClientDetails(Client client) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ClientDetailsScreen(
          client: client,
        ),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await _loadClientsFromFirestore();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 16,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Client updated successfully!',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE8F5E9),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color(0xFFC8E6C9),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildClientList() {
    if (_isLoadingClients) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_clientsLoadError != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: _boxDecoration(),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 45,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              _clientsLoadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadClientsFromFirestore,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (clients.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 20,
        ),
        decoration: _boxDecoration(),
        child: const Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 55,
              color: Color(0xFF98A2B3),
            ),
            SizedBox(height: 18),
            Text(
              'No clients yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first client to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final client in clients)
          GestureDetector(
            onTap: () => _openClientDetails(client),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Color(0xFF2864E8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (client.email.isNotEmpty)
                          Text(
                            client.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF667085),
                            ),
                          ),
                        if (client.phone.isNotEmpty)
                          Text(
                            client.phone,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF667085),
                            ),
                          ),
                        if (client.address.isNotEmpty)
                          Text(
                            client.address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF667085),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF98A2B3),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                10,
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    'Clients',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _PrimaryButton(
                    text: '+ Add Client',
                    onPressed: _openAddClient,
                  ),
                  const SizedBox(height: 20),
                  _buildClientList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavigation(
        selectedIndex: 2,
      ),
    );
  }
}

// ============================================================
// CLIENT DETAILS
// ============================================================

class ClientDetailsScreen extends StatelessWidget {
  final Client client;

  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  Future<bool?> _showDeleteConfirmation(
      BuildContext context,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Client?'),
          content: Text(
            'Are you sure you want to delete ${client.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    if (client.id != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('clients')
          .doc(client.id)
          .delete();
    }

    clients.remove(client);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            8,
          ),
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(
                  title: 'Client Details',
                ),

                const SizedBox(height: 30),

                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),

                const SizedBox(height: 25),

                const _FormLabel('Email'),
                const SizedBox(height: 8),

                _InfoCard(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: client.email.isEmpty
                      ? 'No email provided'
                      : client.email,
                ),

                const SizedBox(height: 8),

                const _FormLabel('Phone'),
                const SizedBox(height: 8),

                _InfoCard(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  subtitle: client.phone.isEmpty
                      ? 'No phone provided'
                      : client.phone,
                ),

                const SizedBox(height: 8),

                const _FormLabel('Address'),
                const SizedBox(height: 8),

                _InfoCard(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  subtitle: client.address.isEmpty
                      ? 'No address provided'
                      : client.address,
                ),

                const SizedBox(height: 25),

                _PrimaryButton(
                  text: 'Edit Client',
                  onPressed: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditClientScreen(
                          client: client,
                        ),
                      ),
                    );

                    if (changed == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                ),

                const SizedBox(height: 12),

                _PrimaryButton(
                  text: 'Delete Client',
                  onPressed: () async {
                    final deleted =
                    await _showDeleteConfirmation(context);

                    if (deleted == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EDIT CLIENT
// ============================================================

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({
    super.key,
    required this.client,
  });

  @override
  State<EditClientScreen> createState() =>
      _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.client.name);
    emailController =
        TextEditingController(text: widget.client.email);
    phoneController =
        TextEditingController(text: widget.client.phone);
    addressController =
        TextEditingController(text: widget.client.address);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a client name.'),
        ),
      );
      return;
    }

    if (email.isEmpty && phone.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Color(0xFFC62828),
                  size: 14,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please enter an email address or phone number.',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFEBEE),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),

            // Position the message above the bottom navigation.
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 84),

            // Keep it slim, like your green notifications.
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color(0xFFFFCDD2),
                width: 1,
              ),
            ),
          ),
        );
      return;
    }

    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
            .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    if (phone.isNotEmpty) {
      final digits = phone.replaceAll(RegExp(r'\D'), '');

      if (!RegExp(r'^[+\d\s().-]+$').hasMatch(phone) ||
          digits.length < 7 ||
          digits.length > 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid phone number.'),
          ),
        );
        return;
      }
    }


    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final index = clients.indexOf(widget.client);

    if (index == -1) {
      return;
    }

    final updatedClient = Client(
      id: widget.client.id,
      name: name,
      email: email,
      phone: phone,
      address: address,
    );

    clients[index] = updatedClient;

    if (widget.client.id != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('clients')
          .doc(widget.client.id)
          .update(updatedClient.toMap());
    }


    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            8,
          ),
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(
                  title: 'Edit Client',
                ),

                const SizedBox(height: 30),

                const _FormLabel('Name'),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: _inputDecoration(
                    'Enter client name',
                  ),
                ),

                const SizedBox(height: 18),

                const _FormLabel('Email'),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType:
                  TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    'Enter email address',
                  ),
                ),

                const SizedBox(height: 18),

                const _FormLabel('Phone'),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    'Enter phone number',
                  ),
                ),

                const SizedBox(height: 18),

                const _FormLabel('Address'),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    'Enter address',
                  ),
                ),

                const SizedBox(height: 30),

                _PrimaryButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() =>
      _AddClientScreenState();
}

class _AddClientScreenState
    extends State<AddClientScreen> {
  final TextEditingController nameController =
  TextEditingController();
  final TextEditingController emailController =
  TextEditingController();
  final TextEditingController phoneController =
  TextEditingController();


  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (isSaving) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    void showMessage(String message) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFC62828),
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFFC62828),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFEBEE),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 84),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            duration: const Duration(seconds: 3),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color(0xFFFFCDD2),
              ),
            ),
          ),
        );
    }

    // Validate the form.
    if (email.isEmpty && phone.isEmpty) {
      showMessage(
        'Please enter an email address or phone number.',
      );
      return;
    }

    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
            .hasMatch(email)) {
      showMessage('Please enter a valid email address.');
      return;
    }

    if (phone.isNotEmpty) {
      final digits = phone.replaceAll(RegExp(r'\D'), '');

      if (!RegExp(r'^[+\d\s().-]+$').hasMatch(phone) ||
          digits.length < 7 ||
          digits.length > 15) {
        showMessage('Please enter a valid phone number.');
        return;
      }
    }

    if (name.isEmpty) {
      showMessage('Please enter a client name.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('You must be signed in to add a client.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final client = Client(
        name: name,
        email: email,
        phone: phone,
      );

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('clients')
          .add(client.toMap());

      final savedClient = Client(
        id: docRef.id,
        name: name,
        email: email,
        phone: phone,
      );

      clients.removeWhere((c) => c.id == savedClient.id);
      clients.add(savedClient);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      // Close the Add Client screen and return success.
      Navigator.of(context).pop(true);
    } catch (e, stackTrace) {
      debugPrint('Failed to save client: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage(
        'Unable to save client. Please check your connection and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            8,
          ),
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(title: 'Add Client'),
                const SizedBox(height: 30),
                const _FormLabel('Client Name'),
                const SizedBox(height: 8),

                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    'Enter client name',
                  ),
                ),
                const SizedBox(height: 18),

                const _FormLabel('Email'),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    'Enter email address',
                  ),
                ),
                const SizedBox(height: 18),

                const _FormLabel('Phone'),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration(
                    'Enter phone number',
                  ),
                ),
                const SizedBox(height: 25),

                _PrimaryButton(
                  text: isSaving ? 'Saving...' : 'Save Client',
                  onPressed: isSaving ? null : _saveClient,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// OTHER SCREENS
// ============================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List<Invoice> notificationInvoices = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('invoices')
        .get();

    final loadedInvoices = snapshot.docs.map((doc) {
      return Invoice.fromMap(
        doc.data(),
        id: doc.id,
      );
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      notificationInvoices = loadedInvoices;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = <Widget>[];

    for (final invoice in notificationInvoices) {
      if (invoice.status == 'Paid') {
        notifications.add(
          _InfoCard(
            icon: Icons.receipt_long_outlined,
            title: 'Invoice payment received',
            subtitle:
            '${invoice.client} paid invoice ${invoice.invoiceNumber}.',
          ),
        );
      } else if (invoice.status == 'Overdue') {
        notifications.add(
          _InfoCard(
            icon: Icons.warning_amber_outlined,
            title: 'Invoice overdue',
            subtitle:
            'Invoice ${invoice.invoiceNumber} is overdue.',
          ),
        );
      } else if (invoice.status == 'Pending') {
        notifications.add(
          _InfoCard(
            icon: Icons.pending_outlined,
            title: 'Invoice pending',
            subtitle:
            'Invoice ${invoice.invoiceNumber} is still pending.',
          ),
        );
      }
    }

    return _SimplePage(
      title: 'Notifications',
      child: notifications.isEmpty
          ? const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      )
          : Column(
        children: notifications,
      ),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('invoices')
        .get();

    final loadedInvoices = snapshot.docs.map((doc) {
      final data = doc.data();

      return Invoice(
        id: doc.id,
        currencyCode: data['currencyCode']?.toString() ?? 'GBP',
        invoiceNumber: data['invoiceNumber']?.toString() ?? '',
        client: data['client']?.toString() ?? 'No client',
        issueDate: data['issueDate']?.toString() ?? '',
        dueDate: data['dueDate']?.toString() ?? '',
        subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
        vat: (data['vat'] as num?)?.toDouble() ?? 0,
        vatRate: (data['vatRate'] as num?)?.toDouble() ?? 20.0,
        total: (data['total'] as num?)?.toDouble() ?? 0,
        status: data['status']?.toString() ?? 'Pending',
        items: (data['items'] as List?)
            ?.map(
              (item) => InvoiceItem(
            description:
            item['description']?.toString() ?? '',
            amount:
            (item['amount'] as num?)?.toDouble() ?? 0,
          ),
        )
            .toList() ??
            [],
      );
    }).toList();

    if (!mounted) return;

    setState(() {
      invoices
        ..clear()
        ..addAll(loadedInvoices);
    });
  }

  String _formatReportTotals(Iterable<Invoice> source) {
    final totals = <String, double>{};

    for (final invoice in source) {
      totals.update(
        invoice.currencyCode,
            (current) => current + invoice.total,
        ifAbsent: () => invoice.total,
      );
    }

    if (totals.isEmpty) {
      return '${currencySymbolFor(selectedCurrencyCode)}0.00';
    }

    final entries = totals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.length == 1) {
      final entry = entries.first;
      return '${currencySymbolFor(entry.key)}${entry.value.toStringAsFixed(2)}';
    }

    return entries.map((entry) {
      return '${entry.key} ${currencySymbolFor(entry.key)}${entry.value.toStringAsFixed(2)}';
    }).join('\n');
  }

  String _calculateRevenue() {
    return _formatReportTotals(invoices);
  }

  String _calculateOutstanding() {
    return _formatReportTotals(
      invoices.where((invoice) => invoice.status != 'Paid'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            30,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Reports',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _SummaryCard(
                title: 'Revenue',
                value: _calculateRevenue(),
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Outstanding',
                value: _calculateOutstanding(),
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Invoices',
                value: invoices.length.toString(),
              ),

              const SizedBox(height: 20),

              const Text(
                'Revenue Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                  ),
                ),
                child: _RevenueChart(
                  invoices: invoices,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
      const _BottomNavigation(selectedIndex: 3),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<Invoice> invoices;

  const _RevenueChart({
    required this.invoices,
  });

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const Center(
        child: Text(
          'No invoice data yet',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    final values = invoices
        .map((invoice) => invoice.total)
        .toList();

    final maxValue = values.reduce(
          (a, b) => a > b ? a : b,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$currencySymbol${maxValue.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              values.length,
                  (index) {
                final value = values[index];

                final barHeight = maxValue == 0
                    ? 0.0
                    : (value / maxValue) * 120;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        Text(
                          '$currencySymbol${value.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F64E8),
                            borderRadius:
                            BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          invoices[index].client.length > 6
                              ? invoices[index].client.substring(0, 6)
                              :invoices[index].client,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            30,
            20,
            20,
          ),
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),

            _SettingsTile(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Log Out?'),
                    content: const Text(
                      'Are you sure you want to log out of your account?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout != true) return;

                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),

            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.currency_pound,
              title: 'Currency',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CurrencyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.receipt_long_outlined,
              title: 'Tax Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TaxSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.business_outlined,
              title: 'Business Profile',
              onTap: () async {
                final saved = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BusinessProfileScreen(),
                  ),
                );

                if (saved == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFFE8F5E9),
                      behavior: SnackBarBehavior.floating,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFC8E6C9),
                        ),
                      ),
                      content: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                            size: 16,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Business profile saved successfully.',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.payment_outlined,
              title: 'Payment Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.public,
              title: 'Business Location',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BusinessLocationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      const _BottomNavigation(selectedIndex: 4),
    );
  }
}

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState
    extends State<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController stripePaymentLinkController =
  TextEditingController();
  final TextEditingController customPaymentMethodNameController =
  TextEditingController();
  final TextEditingController customPaymentLinkController =
  TextEditingController();
  final TextEditingController paypalPaymentLinkController =
  TextEditingController();
  final TextEditingController bankAccountNameController =
  TextEditingController();
  final TextEditingController bankNameController =
  TextEditingController();
  final TextEditingController bankAccountNumberController =
  TextEditingController();
  final TextEditingController bankRoutingController =
  TextEditingController();
  final TextEditingController bankPaymentInstructionsController =
  TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentSettings();
  }

  @override
  void dispose() {
    stripePaymentLinkController.dispose();
    paypalPaymentLinkController.dispose();
    customPaymentMethodNameController.dispose();
    customPaymentLinkController.dispose();
    bankAccountNameController.dispose();
    bankNameController.dispose();
    bankAccountNumberController.dispose();
    bankRoutingController.dispose();
    bankPaymentInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final settings =
      doc.data()?['paymentSettings'] as Map<String, dynamic>?;

      if (settings != null) {
        stripePaymentLinkController.text =
            settings['stripePaymentLink'] as String? ?? '';
        paypalPaymentLinkController.text =
            settings['paypalPaymentLink'] as String? ?? '';
        customPaymentMethodNameController.text =
            settings['customPaymentMethodName'] as String? ?? '';
        customPaymentLinkController.text =
            settings['customPaymentLink'] as String? ?? '';
        bankAccountNameController.text =
            settings['bankAccountName'] as String? ?? '';
        bankNameController.text =
            settings['bankName'] as String? ?? '';
        bankAccountNumberController.text =
            settings['bankAccountNumber'] as String? ?? '';
        bankRoutingController.text =
            settings['bankRouting'] as String? ?? '';
        bankPaymentInstructionsController.text =
            settings['bankPaymentInstructions'] as String? ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load payment settings.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

  }

  Future<void> _savePaymentSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to save payment settings.'),
            ),
          );
        }
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'paymentSettings': {
          'stripePaymentLink': stripePaymentLinkController.text.trim(),
          'paypalPaymentLink': paypalPaymentLinkController.text.trim(),
          'customPaymentMethodName':
          customPaymentMethodNameController.text.trim(),
          'customPaymentLink': customPaymentLinkController.text.trim(),
          'bankAccountName': bankAccountNameController.text.trim(),
          'bankName': bankNameController.text.trim(),
          'bankAccountNumber': bankAccountNumberController.text.trim(),
          'bankRouting': bankRoutingController.text.trim(),
          'bankPaymentInstructions':
          bankPaymentInstructionsController.text.trim(),
        },
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Payment settings saved successfully.',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE8F5E9),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFFC8E6C9),
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      // Return to the previous screen after a successful save.
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save payment settings.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildPaymentField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Settings'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Configure how your customers can pay you. '
                  'Only configured payment options will be shown '
                  'on invoices.',
            ),
            _buildSectionTitle('Online Payment Methods'),
            _buildPaymentField(
              label: 'Stripe Payment Link',
              controller: stripePaymentLinkController,
              icon: Icons.credit_card_outlined,
              hint: 'https://buy.stripe.com/...',
              keyboardType: TextInputType.url,
            ),
            _buildPaymentField(
              label: 'PayPal Payment Link',
              controller: paypalPaymentLinkController,
              icon: Icons.credit_card_outlined,
              hint: 'https://paypal.me/...',
              keyboardType: TextInputType.url,
            ),
            _buildSectionTitle('Other Payment Methods'),
            _buildPaymentField(
              label: 'Payment Method Name',
              controller: customPaymentMethodNameController,
              icon: Icons.payments_outlined,
              hint: 'e.g. UPI, Pix, or another provider',
            ),
            _buildPaymentField(
              label: 'Custom Payment Link',
              controller: customPaymentLinkController,
              icon: Icons.link,
              hint: 'https://...',
              keyboardType: TextInputType.url,
            ),
            _buildSectionTitle('Bank Transfer Details'),
            _buildPaymentField(
              label: 'Account Holder Name',
              controller: bankAccountNameController,
              icon: Icons.person_outline,
            ),
            _buildPaymentField(
              label: 'Bank Name',
              controller: bankNameController,
              icon: Icons.account_balance_outlined,
            ),
            _buildPaymentField(
              label: 'Account Number / IBAN',
              controller: bankAccountNumberController,
              icon: Icons.tag,
            ),
            _buildPaymentField(
              label: 'Sort Code / BIC / SWIFT',
              controller: bankRoutingController,
              icon: Icons.account_balance_outlined,
            ),
            _buildPaymentField(
              label: 'Payment Instructions',
              controller: bankPaymentInstructionsController,
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                isSaving ? null : _savePaymentSettings,
                child: isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Save Payment Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {

  String selectedCurrency = 'GBP';
  String currencySearchQuery = '';

  final List<Map<String, String>> currencies = [
    {'code': 'AED', 'name': 'UAE Dirham'},
    {'code': 'AFN', 'name': 'Afghan Afghani'},
    {'code': 'ALL', 'name': 'Albanian Lek'},
    {'code': 'AMD', 'name': 'Armenian Dram'},
    {'code': 'ANG', 'name': 'Caribbean Guilder'},
    {'code': 'AOA', 'name': 'Angolan Kwanza'},
    {'code': 'ARS', 'name': 'Argentine Peso'},
    {'code': 'AUD', 'name': 'Australian Dollar'},
    {'code': 'AWG', 'name': 'Aruban Florin'},
    {'code': 'AZN', 'name': 'Azerbaijani Manat'},
    {'code': 'BAM', 'name': 'Convertible Mark'},
    {'code': 'BBD', 'name': 'Barbados Dollar'},
    {'code': 'BDT', 'name': 'Bangladeshi Taka'},
    {'code': 'BGN', 'name': 'Bulgarian Lev'},
    {'code': 'BHD', 'name': 'Bahraini Dinar'},
    {'code': 'BIF', 'name': 'Burundian Franc'},
    {'code': 'BMD', 'name': 'Bermudian Dollar'},
    {'code': 'BND', 'name': 'Brunei Dollar'},
    {'code': 'BOB', 'name': 'Boliviano'},
    {'code': 'BRL', 'name': 'Brazilian Real'},
    {'code': 'BSD', 'name': 'Bahamian Dollar'},
    {'code': 'BTN', 'name': 'Bhutanese Ngultrum'},
    {'code': 'BWP', 'name': 'Botswana Pula'},
    {'code': 'BYN', 'name': 'Belarusian Ruble'},
    {'code': 'BZD', 'name': 'Belize Dollar'},
    {'code': 'CAD', 'name': 'Canadian Dollar'},
    {'code': 'CDF', 'name': 'Congolese Franc'},
    {'code': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'CLP', 'name': 'Chilean Peso'},
    {'code': 'CNY', 'name': 'Chinese Yuan'},
    {'code': 'COP', 'name': 'Colombian Peso'},
    {'code': 'CRC', 'name': 'Costa Rican Colon'},
    {'code': 'CUP', 'name': 'Cuban Peso'},
    {'code': 'CVE', 'name': 'Cape Verde Escudo'},
    {'code': 'CZK', 'name': 'Czech Koruna'},
    {'code': 'DJF', 'name': 'Djiboutian Franc'},
    {'code': 'DKK', 'name': 'Danish Krone'},
    {'code': 'DOP', 'name': 'Dominican Peso'},
    {'code': 'DZD', 'name': 'Algerian Dinar'},
    {'code': 'EGP', 'name': 'Egyptian Pound'},
    {'code': 'ERN', 'name': 'Eritrean Nakfa'},
    {'code': 'ETB', 'name': 'Ethiopian Birr'},
    {'code': 'EUR', 'name': 'Euro'},
    {'code': 'FJD', 'name': 'Fiji Dollar'},
    {'code': 'FKP', 'name': 'Falkland Islands Pound'},
    {'code': 'GBP', 'name': 'British Pound (£)'},
    {'code': 'GEL', 'name': 'Georgian Lari'},
    {'code': 'GHS', 'name': 'Ghanaian Cedi'},
    {'code': 'GIP', 'name': 'Gibraltar Pound'},
    {'code': 'GMD', 'name': 'Gambian Dalasi'},
    {'code': 'GNF', 'name': 'Guinean Franc'},
    {'code': 'GTQ', 'name': 'Guatemalan Quetzal'},
    {'code': 'GYD', 'name': 'Guyanese Dollar'},
    {'code': 'HKD', 'name': 'Hong Kong Dollar'},
    {'code': 'HNL', 'name': 'Honduran Lempira'},
    {'code': 'HTG', 'name': 'Haitian Gourde'},
    {'code': 'HUF', 'name': 'Hungarian Forint'},
    {'code': 'IDR', 'name': 'Indonesian Rupiah'},
    {'code': 'ILS', 'name': 'Israeli New Shekel'},
    {'code': 'INR', 'name': 'Indian Rupee'},
    {'code': 'IQD', 'name': 'Iraqi Dinar'},
    {'code': 'IRR', 'name': 'Iranian Rial'},
    {'code': 'ISK', 'name': 'Icelandic Krona'},
    {'code': 'JMD', 'name': 'Jamaican Dollar'},
    {'code': 'JOD', 'name': 'Jordanian Dinar'},
    {'code': 'JPY', 'name': 'Japanese Yen'},
    {'code': 'KES', 'name': 'Kenyan Shilling'},
    {'code': 'KGS', 'name': 'Kyrgyzstani Som'},
    {'code': 'KHR', 'name': 'Cambodian Riel'},
    {'code': 'KMF', 'name': 'Comorian Franc'},
    {'code': 'KPW', 'name': 'North Korean Won'},
    {'code': 'KRW', 'name': 'South Korean Won'},
    {'code': 'KWD', 'name': 'Kuwaiti Dinar'},
    {'code': 'KYD', 'name': 'Cayman Islands Dollar'},
    {'code': 'KZT', 'name': 'Kazakhstani Tenge'},
    {'code': 'LAK', 'name': 'Lao Kip'},
    {'code': 'LBP', 'name': 'Lebanese Pound'},
    {'code': 'LKR', 'name': 'Sri Lankan Rupee'},
    {'code': 'LRD', 'name': 'Liberian Dollar'},
    {'code': 'LSL', 'name': 'Lesotho Loti'},
    {'code': 'LYD', 'name': 'Libyan Dinar'},
    {'code': 'MAD', 'name': 'Moroccan Dirham'},
    {'code': 'MDL', 'name': 'Moldovan Leu'},
    {'code': 'MGA', 'name': 'Malagasy Ariary'},
    {'code': 'MKD', 'name': 'Macedonian Denar'},
    {'code': 'MMK', 'name': 'Myanmar Kyat'},
    {'code': 'MNT', 'name': 'Mongolian Tugrik'},
    {'code': 'MOP', 'name': 'Macanese Pataca'},
    {'code': 'MRU', 'name': 'Mauritanian Ouguiya'},
    {'code': 'MUR', 'name': 'Mauritian Rupee'},
    {'code': 'MVR', 'name': 'Maldivian Rufiyaa'},
    {'code': 'MWK', 'name': 'Malawian Kwacha'},
    {'code': 'MXN', 'name': 'Mexican Peso'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit'},
    {'code': 'MZN', 'name': 'Mozambican Metical'},
    {'code': 'NAD', 'name': 'Namibian Dollar'},
    {'code': 'NGN', 'name': 'Nigerian Naira'},
    {'code': 'NIO', 'name': 'Nicaraguan Cordoba'},
    {'code': 'NOK', 'name': 'Norwegian Krone'},
    {'code': 'NPR', 'name': 'Nepalese Rupee'},
    {'code': 'NZD', 'name': 'New Zealand Dollar'},
    {'code': 'OMR', 'name': 'Omani Rial'},
    {'code': 'PAB', 'name': 'Panamanian Balboa'},
    {'code': 'PEN', 'name': 'Peruvian Sol'},
    {'code': 'PGK', 'name': 'Papua New Guinea Kina'},
    {'code': 'PHP', 'name': 'Philippine Peso'},
    {'code': 'PKR', 'name': 'Pakistani Rupee (₨)'},
    {'code': 'PLN', 'name': 'Polish Zloty'},
    {'code': 'PYG', 'name': 'Paraguayan Guarani'},
    {'code': 'QAR', 'name': 'Qatari Riyal'},
    {'code': 'RON', 'name': 'Romanian Leu'},
    {'code': 'RSD', 'name': 'Serbian Dinar'},
    {'code': 'RUB', 'name': 'Russian Ruble'},
    {'code': 'RWF', 'name': 'Rwandan Franc'},
    {'code': 'SAR', 'name': 'Saudi Riyal'},
    {'code': 'SBD', 'name': 'Solomon Islands Dollar'},
    {'code': 'SCR', 'name': 'Seychelles Rupee'},
    {'code': 'SDG', 'name': 'Sudanese Pound'},
    {'code': 'SEK', 'name': 'Swedish Krona'},
    {'code': 'SGD', 'name': 'Singapore Dollar'},
    {'code': 'SHP', 'name': 'Saint Helena Pound'},
    {'code': 'SLE', 'name': 'Sierra Leonean Leone'},
    {'code': 'SOS', 'name': 'Somali Shilling'},
    {'code': 'SRD', 'name': 'Surinamese Dollar'},
    {'code': 'SSP', 'name': 'South Sudanese Pound'},
    {'code': 'STN', 'name': 'Sao Tome and Principe Dobra'},
    {'code': 'SYP', 'name': 'Syrian Pound'},
    {'code': 'SZL', 'name': 'Eswatini Lilangeni'},
    {'code': 'THB', 'name': 'Thai Baht'},
    {'code': 'TJS', 'name': 'Tajikistani Somoni'},
    {'code': 'TMT', 'name': 'Turkmenistani Manat'},
    {'code': 'TND', 'name': 'Tunisian Dinar'},
    {'code': 'TOP', 'name': 'Tongan Paanga'},
    {'code': 'TRY', 'name': 'Turkish Lira'},
    {'code': 'TTD', 'name': 'Trinidad and Tobago Dollar'},
    {'code': 'TWD', 'name': 'New Taiwan Dollar'},
    {'code': 'TZS', 'name': 'Tanzanian Shilling'},
    {'code': 'UAH', 'name': 'Ukrainian Hryvnia'},
    {'code': 'UGX', 'name': 'Ugandan Shilling'},
    {'code': 'USD', 'name': 'US Dollar (\$)'},
    {'code': 'UYU', 'name': 'Uruguayan Peso'},
    {'code': 'UZS', 'name': 'Uzbekistani Som'},
    {'code': 'VES', 'name': 'Venezuelan Bolivar'},
    {'code': 'VND', 'name': 'Vietnamese Dong'},
    {'code': 'VUV', 'name': 'Vanuatu Vatu'},
    {'code': 'WST', 'name': 'Samoan Tala'},
    {'code': 'XAF', 'name': 'Central African CFA Franc'},
    {'code': 'XCD', 'name': 'East Caribbean Dollar'},
    {'code': 'XOF', 'name': 'West African CFA Franc'},
    {'code': 'XPF', 'name': 'CFP Franc'},
    {'code': 'YER', 'name': 'Yemeni Rial'},
    {'code': 'ZAR', 'name': 'South African Rand'},
    {'code': 'ZMW', 'name': 'Zambian Kwacha'},
    {'code': 'ZWL', 'name': 'Zimbabwean Dollar'},
  ];


  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCurrency = prefs.getString('selected_currency');

    if (savedCurrency != null && mounted) {
      setState(() {
        selectedCurrency = savedCurrency;
      });

      selectedCurrencyCode = savedCurrency;
    }
  }

  Future<void> _selectCurrency(String currency) async {
    setState(() {
      selectedCurrency = currency;
    });

    selectedCurrencyCode = currency;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'selected_currency',
      currency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCurrencies = [...currencies]
      ..sort((a, b) => a['name']!.compareTo(b['name']!));

    final results = filteredCurrencies.where((currency) {
      final name = currency['name']!.toLowerCase();
      final code = currency['code']!.toLowerCase();
      final symbol =
      currencySymbolFor(currency['code']!).toLowerCase();

      return name.contains(currencySearchQuery) ||
          code.contains(currencySearchQuery) ||
          symbol.contains(currencySearchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Currency'),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Default Currency',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            onChanged: (value) {
              setState(() {
                currencySearchQuery = value.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search currencies...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: currencySearchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    currencySearchQuery = '';
                  });
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),

          const SizedBox(height: 15),

          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'No currencies found',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...results.map((currency) {
              final isSelected =
                  selectedCurrency == currency['code'];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    '${currency['name']} (${currency['code']}) - ${currencySymbolFor(
                        currency['code']!)}',
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    _selectCurrency(currency['code']!);
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDeletingAccount = false;
  Future<void> _editProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    String editedName = user.displayName ?? '';

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: TextEditingController(
              text: editedName,
            ),
            onChanged: (value) {
              editedName = value;
            },
            decoration: const InputDecoration(
              labelText: 'Full Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  editedName.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName == null || newName.isEmpty) {
      return;
    }


    await user.updateDisplayName(newName);

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 22,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Profile updated successfully.',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE8F5E9),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFC8E6C9),
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }


  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This permanently deletes your InvoicePilot account, '
              'invoices, and clients. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final passwordController = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Your Password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Current Password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              passwordController.text,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    passwordController.dispose();

    if (password == null || password.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      final email = user.email;

      if (email == null || email.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to confirm your email. Please contact support.',
            ),
          ),
        );
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      for (final collectionName in [
        'invoices',
        'clients',
        'settings',
      ]) {
        final snapshot = await userRef.collection(collectionName).get();

        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      await userRef.delete();
      await user.delete();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.code == 'requires-recent-login'
          ? 'Please sign out, sign back in, and try again.'
          : 'Account deletion failed: ${e.message ?? e.code}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deletion failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final displayName =
    user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : 'No name set';

    final email =
        user?.email ?? 'No email';

    return _SimplePage(
      title: 'Profile',
      child: Column(
        children: [
          _InfoCard(
            icon: Icons.person_outline,
            title: displayName,
            subtitle: 'InvoicePilot User',
          ),
          _InfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: email,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _editProfile,
              child: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: _isDeletingAccount ? null : _deleteAccount,
              child: _isDeletingAccount
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text('Delete Account'),
            ),
          ),

        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================

class _SimplePage extends StatelessWidget {
  final String title;
  final Widget child;

  const _SimplePage({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            8,
          ),
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _PageHeader(title: title),
                const SizedBox(height: 25),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;

  const _PageHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 35,
            minHeight: 35,
          ),
          icon: const Icon(
            Icons.arrow_back,
            size: 28,
            color: Color(0xFF101828),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          const Color(0xFF2864E8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF344054),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF101828),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 25),
        onPressed: onPressed,
      ),
    );
  }
}


class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final currencyLines = value
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE1E5EA),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF808080),
            ),
          ),
          const SizedBox(height: 10),
          ...currencyLines.map(
                (line) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  line,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2864E8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClickableInvoiceCard extends StatelessWidget {
  final String invoiceNumber;
  final String clientName;
  final String date;
  final String amount;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  const _ClickableInvoiceCard({
    required this.invoiceNumber,
    required this.clientName,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          18,
          12,
          14,
          12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE1E5EA),
          ),
          borderRadius:
          BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    invoiceNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2864E8)
              : Colors.white,
          border: Border.all(
            color: selected
                ? const Color(0xFF2864E8)
                : const Color(0xFFD0D5DD),
          ),
          borderRadius:
          BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected
                  ? Colors.white
                  : const Color(0xFF344054),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE1E5EA),
        ),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2864E8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing:
        const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _EditableInvoiceInput
    extends StatefulWidget {
  final String initialText;
  final String? prefixText;
  final double height;
  final ValueChanged<String>? onChanged;

  const _EditableInvoiceInput({
    required this.initialText,
    this.prefixText,
    this.height = 44,
    this.onChanged,
  });

  @override
  State<_EditableInvoiceInput> createState() =>
      _EditableInvoiceInputState();
}

class _EditableInvoiceInputState
    extends State<_EditableInvoiceInput> {
  late final TextEditingController
  controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.initialText,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: TextField(
        controller: controller,
        onChanged: widget.onChanged,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF344054),
        ),
        decoration: _inputDecoration('').copyWith(
          prefixIcon: widget.prefixText == null
              ? null
              : Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 4,
            ),
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.prefixText!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF344054),
                ),
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}


// ============================================================
// BOTTOM NAVIGATION
// ============================================================

class _BottomNavigation
    extends StatelessWidget {
  final int selectedIndex;

  const _BottomNavigation({
    required this.selectedIndex,
  });

  void _navigate(
      BuildContext context,
      int index,
      ) {
    if (index == selectedIndex) {
      return;
    }

    Widget page;

    switch (index) {
      case 0:
        page = const DashboardScreen();
        break;
      case 1:
        page = const InvoiceListScreen();
        break;
      case 2:
        page = const ClientsScreen();
        break;
      case 3:
        page = const ReportsScreen();
        break;
      default:
        page = const SettingsScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E5E5),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () =>
                    _navigate(context, 0),
              ),
              _NavItem(
                icon: Icons.description_outlined,
                label: 'Invoices',
                selected: selectedIndex == 1,
                onTap: () =>
                    _navigate(context, 1),
              ),
              _NavItem(
                icon: Icons.people_outline,
                label: 'Clients',
                selected: selectedIndex == 2,
                onTap: () =>
                    _navigate(context, 2),
              ),
              _NavItem(
                icon: Icons.bar_chart,
                label: 'Reports',
                selected: selectedIndex == 3,
                onTap: () =>
                    _navigate(context, 3),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: selectedIndex == 4,
                onTap: () =>
                    _navigate(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected
                  ? const Color(0xFF2864E8)
                  : const Color(0xFF98A2B3),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: selected
                    ? const Color(0xFF2864E8)
                    : const Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

InputDecoration _inputDecoration(
    String hint,
    ) {
  return InputDecoration(
    hintText: hint.isEmpty ? null : hint,
    hintStyle: const TextStyle(
      fontSize: 13,
      color: Color(0xFF98A2B3),
    ),
    contentPadding:
    const EdgeInsets.symmetric(
      horizontal: 17,
      vertical: 12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color(0xFFD0D5DD),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color(0xFFD0D5DD),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color(0xFF2864E8),
      ),
    ),
  );
}

BoxDecoration _boxDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: const Color(0xFFE1E5EA),
    ),
    borderRadius: BorderRadius.circular(10),
  );
}


class InvoicePilotWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..style = PaintingStyle.fill;

    final wave1 = Path()
      ..moveTo(0, size.height * 0.30)
      ..cubicTo(
        size.width * 0.25, size.height * 0.05,
        size.width * 0.36, size.height * 0.72,
        size.width * 0.62, size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.80, size.height * 0.42,
        size.width * 0.88, size.height * 0.22,
        size.width, size.height * 0.36,
      )
      ..lineTo(size.width, size.height * 0.75)
      ..cubicTo(
        size.width * 0.75, size.height * 0.55,
        size.width * 0.64, size.height * 0.95,
        size.width * 0.40, size.height * 0.68,
      )
      ..cubicTo(
        size.width * 0.20, size.height * 0.46,
        size.width * 0.12, size.height * 0.78,
        0, size.height * 0.70,
      )
      ..close();

    wavePaint.color = const Color(0xFFB9DFFF).withValues(alpha: 0.55);
    canvas.drawPath(wave1, wavePaint);

    final wave2 = Path()
      ..moveTo(0, size.height * 0.52)
      ..cubicTo(
        size.width * 0.24, size.height * 0.30,
        size.width * 0.34, size.height * 0.94,
        size.width * 0.58, size.height * 0.70,
      )
      ..cubicTo(
        size.width * 0.78, size.height * 0.48,
        size.width * 0.87, size.height * 0.40,
        size.width, size.height * 0.55,
      )
      ..lineTo(size.width, size.height * 0.78)
      ..cubicTo(
        size.width * 0.74, size.height * 0.63,
        size.width * 0.64, size.height * 0.98,
        size.width * 0.38, size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.18, size.height * 0.62,
        size.width * 0.10, size.height * 0.88,
        0, size.height * 0.80,
      )
      ..close();

    wavePaint.color = const Color(0xFF6EB6FF).withValues(alpha: 0.42);
    canvas.drawPath(wave2, wavePaint);

    // Curved flight path
    final flightPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.48)
      ..cubicTo(
        size.width * 0.35, size.height * 0.25,
        size.width * 0.55, size.height * 0.80,
        size.width * 0.88, size.height * 0.18,
      );

    final flightPaint = Paint()
      ..color = const Color(0xFF1687FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final dashedPath = Path();
    for (final metric in flightPath.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + 7).clamp(0.0, metric.length);
        dashedPath.addPath(
          metric.extractPath(distance, end),
          Offset.zero,
        );
        distance += 12;
      }
    }
    canvas.drawPath(dashedPath, flightPaint);


    // Draw a clean blue airplane at the end of the flight path.
    canvas.save();
    canvas.translate(size.width * 0.88, size.height * 0.13);
    canvas.rotate(-0.65);

    final planePaint = Paint()
      ..color = const Color(0xFF1687FF)
      ..style = PaintingStyle.fill;

    final plane = Path()
      ..moveTo(0, -13)
      ..lineTo(4, 2)
      ..lineTo(12, 7)
      ..lineTo(12, 10)
      ..lineTo(3, 7)
      ..lineTo(2, 13)
      ..lineTo(5, 15)
      ..lineTo(5, 17)
      ..lineTo(0, 15)
      ..lineTo(-5, 17)
      ..lineTo(-5, 15)
      ..lineTo(-2, 13)
      ..lineTo(-3, 7)
      ..lineTo(-12, 10)
      ..lineTo(-12, 7)
      ..lineTo(-4, 2)
      ..close();

    canvas.drawPath(plane, planePaint);
    canvas.restore();


    // Small decorative dots
    final dotPaint = Paint()..color = const Color(0xFF1687FF);
    canvas.drawCircle(
      Offset(size.width * 0.28, size.height * 0.43),
      4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.65),
      3,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.38),
      3,
      dotPaint..color = const Color(0xFF9BD5FF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    final strokeWidth = size.width * 0.19;

    final circleRect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // Google's four-colour G.
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(circleRect, -0.12, 1.68, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(circleRect, 1.56, 1.45, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(circleRect, 3.01, 1.48, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(circleRect, 4.49, 1.67, false, paint);

    // The horizontal blue bar that forms the G.
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..isAntiAlias = true;

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - size.width * 0.02,
        center.dy - strokeWidth / 2,
        size.width * 0.43,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GoogleLogoPainter oldDelegate) => false;
}


class FeatherLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Curved feather silhouette
    final feather = Path()
      ..moveTo(size.width * 0.12, size.height * 0.94)
      ..quadraticBezierTo(
        size.width * 0.02,
        size.height * 0.30,
        size.width * 0.88,
        size.height * 0.06,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.64,
        size.width * 0.12,
        size.height * 0.94,
      );

    canvas.drawPath(feather, outlinePaint);

    // Fine central shaft
    final shaft = Path()
      ..moveTo(size.width * 0.12, size.height * 0.94)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.48,
        size.width * 0.88,
        size.height * 0.06,
      );

    canvas.drawPath(shaft, outlinePaint);

    // Delicate feather barbs
    final barbPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 0.65
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final t = 0.30 + i * 0.13;

      canvas.drawLine(
        Offset(
          size.width * t,
          size.height * (0.76 - i * 0.15),
        ),
        Offset(
          size.width * (t + 0.16),
          size.height * (0.59 - i * 0.15),
        ),
        barbPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FeatherLogoPainter oldDelegate) => false;
}


class TaxSettingsScreen extends StatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  State<TaxSettingsScreen> createState() =>
      _TaxSettingsScreenState();
}

class _TaxSettingsScreenState
    extends State<TaxSettingsScreen> {
  String taxName = 'VAT';
  double taxRate = 20.0;
  bool isCustomTaxName = false;
  bool isCustomTaxRate = false;
  bool isLoading = true;
  double? suggestedTaxRate;
  bool isSaving = false;
  String? suggestedTaxName;
  String? businessCountry;

  final TextEditingController customTaxNameController =
  TextEditingController();
  final TextEditingController customTaxRateController =
  TextEditingController();

  final List<String> taxNames = [
    'VAT',
    'GST',
    'Sales Tax',
    'HST',
    'PST',
    'QST',
    'SST',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _loadTaxSettings();
  }

  @override
  void dispose() {
    customTaxNameController.dispose();
    customTaxRateController.dispose();
    super.dispose();
  }

  Future<void> _loadTaxSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};

      final settings =
      data['taxSettings'] as Map<String, dynamic>?;

      final location =
      data['businessLocation'] as Map<String, dynamic>?;

      final country = location?['country'] as String?;

      final suggestion = country != null
          ? suggestedTaxForCountry(country)
          : <String, dynamic>{'taxName': null, 'taxRate': null};

      if (mounted) {
        setState(() {
          businessCountry = country;
          suggestedTaxName = suggestion['taxName'] as String?;
          suggestedTaxRate =
              (suggestion['taxRate'] as num?)?.toDouble();
        });
      }

      if (settings != null && mounted) {
        final savedName =
            settings['taxName'] as String? ?? 'VAT';
        final savedRate =
            (settings['taxRate'] as num?)?.toDouble() ?? 20.0;

        setState(() {
          isCustomTaxName = !taxNames
              .where((name) => name != 'Custom')
              .contains(savedName);

          taxName = isCustomTaxName ? 'Custom' : savedName;

          if (isCustomTaxName) {
            customTaxNameController.text = savedName;
          }

          isCustomTaxRate =
          ![0.0, 5.0, 10.0, 20.0].contains(savedRate);

          taxRate = savedRate;
          customTaxRateController.text =
          isCustomTaxRate ? savedRate.toString() : '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load tax settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveTaxSettings() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    final finalTaxName = taxName == 'Custom'
        ? customTaxNameController.text.trim()
        : taxName;

    if (finalTaxName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a tax name.')),
      );
      return;
    }

    double finalRate = taxRate;

    if (isCustomTaxRate) {
      final parsedRate =
      double.tryParse(customTaxRateController.text.trim());

      if (parsedRate == null ||
          !parsedRate.isFinite ||
          parsedRate < 0 ||
          parsedRate > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a tax rate between 0 and 100.'),
          ),
        );
        return;
      }

      finalRate = parsedRate;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'taxSettings': {
          'taxName': finalTaxName,
          'taxRate': finalRate,
        },
      }, SetOptions(merge: true));

      if (!mounted) return;


      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tax settings saved successfully.',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE8F5E9),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFFC8E6C9),
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save tax settings: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Tax Settings'),
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Default Tax Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),


              if (suggestedTaxName != null) ...[
                Text(
                  'Suggested for ${businessCountry ?? 'your country'}: '
                      '$suggestedTaxName'
                      '${suggestedTaxRate != null ? ' (${suggestedTaxRate!.toStringAsFixed(1)}%)' : ' — confirm your rate'}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      final suggestedName = suggestedTaxName!;

                      if (taxNames.contains(suggestedName)) {
                        taxName = suggestedName;
                        isCustomTaxName = false;
                      } else {
                        taxName = 'Custom';
                        isCustomTaxName = true;
                        customTaxNameController.text = suggestedName;
                      }

                      if (suggestedTaxRate != null) {
                        taxRate = suggestedTaxRate!;
                        isCustomTaxRate = false;
                        customTaxRateController.clear();
                      }
                    });


                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF2E7D32),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Suggestion applied. Save Tax Settings to keep changes.',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFFE8F5E9),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFC8E6C9),
                          ),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  child: const Text('Apply Suggestion'),
                ),
                const SizedBox(height: 8),
              ],

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: taxName,
                    isExpanded: true,
                    items: taxNames.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        taxName = value;
                        isCustomTaxName = value == 'Custom';
                      });
                    },
                  ),
                ),
              ),
              if (taxName == 'Custom') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: customTaxNameController,
                  decoration: const InputDecoration(
                    labelText: 'Custom tax name',
                    hintText: 'e.g. Local Tax',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Default Tax Rate',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: isCustomTaxRate ? -1.0 : taxRate,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 0.0,
                        child: Text('0%'),
                      ),
                      DropdownMenuItem(
                        value: 5.0,
                        child: Text('5%'),
                      ),
                      DropdownMenuItem(
                        value: 10.0,
                        child: Text('10%'),
                      ),
                      DropdownMenuItem(
                        value: 20.0,
                        child: Text('20%'),
                      ),
                      DropdownMenuItem(
                        value: -1.0,
                        child: Text('Custom rate'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        isCustomTaxRate = value == -1.0;

                        if (!isCustomTaxRate) {
                          taxRate = value;
                          customTaxRateController.clear();
                        }
                      });
                    },
                  ),
                ),
              ),
              if (isCustomTaxRate) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: customTaxRateController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Custom tax rate (%)',
                    hintText: 'Enter a rate from 0 to 100',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
              const SizedBox(height: 12),

              if (businessCountry == null || businessCountry!.isEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFFD580),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF946200),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No business country selected. Set your business '
                              'location to receive a tax suggestion. You can '
                              'continue using your current tax settings.',
                          style: TextStyle(
                            color: Color(0xFF946200),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Text(
                'These values will be used as defaults for new '
                    'invoices. You can still change the tax on an '
                    'individual invoice.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveTaxSettings,
                  child: isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Save Tax Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState
    extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController businessNameController =
  TextEditingController();
  final TextEditingController emailController =
  TextEditingController();
  final TextEditingController phoneController =
  TextEditingController();
  final TextEditingController addressController =
  TextEditingController();
  final TextEditingController websiteController =
  TextEditingController();
  final TextEditingController taxNumberController =
  TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBusinessProfile();
  }

  @override
  void dispose() {
    businessNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    websiteController.dispose();
    taxNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final profile =
      doc.data()?['businessProfile']
      as Map<String, dynamic>?;

      if (profile != null) {
        businessNameController.text =
            profile['businessName'] as String? ?? '';
        emailController.text =
            profile['email'] as String? ?? '';
        phoneController.text =
            profile['phone'] as String? ?? '';
        addressController.text =
            profile['address'] as String? ?? '';
        websiteController.text =
            profile['website'] as String? ?? '';
        taxNumberController.text =
            profile['taxNumber'] as String? ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load business profile.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveBusinessProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isSaving = false;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'businessProfile': {
          'businessName': businessNameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'website': websiteController.text.trim(),
          'taxNumber': taxNumberController.text.trim(),
        },
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save business profile.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.business_outlined,
                size: 54,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your Business Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your business information to use '
                    'on your invoices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              _buildTextField(
                label: 'Business Name *',
                controller: businessNameController,
                icon: Icons.business,
                hint: 'Enter your business name',
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your business name';
                  }
                  return null;
                },
              ),

              _buildTextField(
                label: 'Business Email',
                controller: emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isNotEmpty &&
                      !RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email)) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),

              _buildTextField(
                label: 'Phone Number',
                controller: phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              _buildTextField(
                label: 'Business Address',
                controller: addressController,
                icon: Icons.location_on_outlined,
                hint: 'Enter your business address',
                maxLines: 3,
              ),

              _buildTextField(
                label: 'Website',
                controller: websiteController,
                icon: Icons.language,
                hint: 'www.example.com',
                keyboardType: TextInputType.url,
              ),

              _buildTextField(
                label: 'VAT / Tax Number',
                controller: taxNumberController,
                icon: Icons.receipt_long_outlined,
              ),
              const SizedBox(height: 24),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.payment_outlined,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    'Payment Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Manage Stripe, PayPal and bank transfer details.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentSettingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 8),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : _saveBusinessProfile,
                  child: isSaving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Save Business Profile'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class BusinessLocationScreen extends StatefulWidget {
  const BusinessLocationScreen({super.key});

  @override
  State<BusinessLocationScreen> createState() =>
      _BusinessLocationScreenState();
}

class _BusinessLocationScreenState
    extends State<BusinessLocationScreen> {
  String? selectedCountry;
  static const String _noCountryValue = '__NO_COUNTRY__';
  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController regionController =
  TextEditingController();

  final List<String> countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czechia',
    'Democratic Republic of the Congo',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Korea',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Palestine',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Korea',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinessLocation();
  }

  @override
  void dispose() {
    regionController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final location =
      doc.data()?['businessLocation']
      as Map<String, dynamic>?;

      if (location != null && mounted) {
        final savedCountry =
        location['country'] as String?;

        setState(() {
          if (savedCountry != null &&
              countries.contains(savedCountry)) {
            selectedCountry = savedCountry;
          }

          regionController.text =
              location['region'] as String? ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load location: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveBusinessLocation() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first.'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'businessLocation': {
          'country': selectedCountry,
          'region': regionController.text.trim(),
        },
      }, SetOptions(merge: true));

      if (!mounted) return;


      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Business location saved successfully.',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE8F5E9),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFFC8E6C9),
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save location: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _showCountryPicker() async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _CountryPickerDialog(
          countries: countries,
          selectedCountry: selectedCountry,
          noCountryValue: _noCountryValue,
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() {
      selectedCountry =
      result == _noCountryValue ? null : result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Business Location'),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Country',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                child:

                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _showCountryPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedCountry ?? 'No country selected',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Region / State (optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: regionController,
                decoration: const InputDecoration(
                  hintText: 'e.g. California, Ontario',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your business location helps configure '
                    'tax settings. You can still adjust tax '
                    'names and rates for individual invoices.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : _saveBusinessLocation,
                  child: isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save Business Location',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _CountryPickerDialog extends StatefulWidget {
  final List<String> countries;
  final String? selectedCountry;
  final String noCountryValue;

  const _CountryPickerDialog({
    required this.countries,
    required this.selectedCountry,
    required this.noCountryValue,
  });

  @override
  State<_CountryPickerDialog> createState() =>
      _CountryPickerDialogState();
}

class _CountryPickerDialogState
    extends State<_CountryPickerDialog> {

  final TextEditingController searchController =
  TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCountries = widget.countries
        .where(
          (country) => country
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim()),
    )
        .toList();

    return AlertDialog(
      title: const Text('Select country'),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search countries...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCountries.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text('No country selected'),
                      leading: const Icon(
                        Icons.location_off_outlined,
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                          widget.noCountryValue,
                        );
                      },
                    );
                  }

                  final country = filteredCountries[index - 1];

                  return ListTile(
                    title: Text(country),
                    trailing:
                    widget.selectedCountry == country
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      Navigator.pop(context, country);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
