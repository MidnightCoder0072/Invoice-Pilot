import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

String get currencySymbol {
  switch (selectedCurrencyCode) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
    default:
      return '£';
  }
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

          return const WelcomeScreen();
        },
      ),
    );
  }
}

// ============================================================
// WELCOME / AUTH
// ============================================================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2864E8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'InvoicePilot',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Simple invoicing for\nsmall businesses and freelancers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 68),
                _PrimaryButton(
                  text: 'Get Started',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2864E8),
                    ),
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

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Welcome Back',
      subtitle: 'Sign in to continue to InvoicePilot',
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
          obscureText: true,
          decoration: _inputDecoration('Enter your password'),
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
              'Forgot Password?',
              style: TextStyle(color: Color(0xFF2864E8)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _PrimaryButton(
          text: 'Sign In',
          onPressed: _login,
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
              "Don't have an account? Register",
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
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final fullName = fullNameController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return;
    }

    if (password != confirmPassword) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 35),
                ...children,
              ],
            ),
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

  double _calculateDashboardRevenue() {
    double total = 0;

    for (final invoice in dashboardInvoices) {
      total += invoice.total;
    }

    return total;
  }

  double _calculateDashboardOutstanding() {
    double total = 0;

    for (final invoice in dashboardInvoices) {
      if (invoice.status != 'Paid') {
        total += invoice.total;
      }
    }

    return total;
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
                            value:
                            '$currencySymbol${_calculateDashboardRevenue().toStringAsFixed(2)}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Outstanding',
                            value:
                            '$currencySymbol${_calculateDashboardOutstanding().toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    _PrimaryButton(
                      text: '+ New Invoices',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const CreateInvoiceScreen(),
                          ),
                        );

                        if (mounted) {
                          _loadDashboardInvoices();
                        }
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
                          '$currencySymbol${invoice.total.toStringAsFixed(2)}',
                          status: invoice.status,
                          statusColor: invoice.status == 'Paid'
                              ? const Color(0xFF12B76A)
                              : invoice.status == 'Overdue'
                              ? const Color(0xFFD92D20)
                              : const Color(0xFF2864E8),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    InvoiceDetailsScreen(
                                      invoiceId: invoice.id,
                                      invoice: invoice,
                                      invoiceNumber: invoice.invoiceNumber,
                                      clientName: invoice.client,
                                      status: invoice.status,
                                      amount:
                                      '$currencySymbol${invoice.total.toStringAsFixed(2)}',
                                      vat: invoice.vat,
                                      items:
                                      invoice.items
                                          .map((item) => item.toMap())
                                          .toList(),
                                      issueDate: invoice.issueDate,
                                      dueDate: invoice.dueDate,
                                    ),
                              ),
                            );

                            if (mounted) {
                              _loadDashboardInvoices();
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
                            '$currencySymbol${invoice.total.toStringAsFixed(2)}',
                            status: invoice.status,
                            statusColor:
                            invoice.status == 'Paid'
                                ? const Color(0xFF12B76A)
                                : invoice.status == 'Overdue'
                                ? const Color(0xFFD92D20)
                                : const Color(0xFF2864E8),
                            onTap: () async {
                              final changed = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InvoiceDetailsScreen(
                                        invoiceId: invoice.id,
                                        invoice: invoice,
                                        invoiceNumber: number,
                                        clientName:
                                        invoice.client,
                                        status: invoice.status,
                                        amount:
                                        '$currencySymbol${invoice.total.toStringAsFixed(2)}',
                                        items:
                                        invoice.items.map((item) => item.toMap()).toList(),
                                        issueDate:
                                        invoice.issueDate,
                                        dueDate:
                                        invoice.dueDate,
                                      ),
                                ),
                              );
                              if (changed == true) {
                                setState(() {});
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
  final String clientName;
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
    required this.clientName,
    required this.status,
    required this.amount,
    this.vat,
    this.items,
    this.issueDate = '24/07/2026',
    this.dueDate = '07/08/2026',
  });

  Future<bool?> _showDeleteConfirmation(
      BuildContext context,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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

    if (invoiceId == null) {
      return false;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('invoices')
        .doc(invoiceId)
        .delete();

    invoices.removeWhere(
          (invoice) => invoice.id == invoiceId,
    );

    return true;
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
    final displayVat = vat ?? (displaySubtotal * 0.20);
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
                      Navigator.pop(context, true);
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
                              '$currencySymbol${(displayItems[i]['amount'] as num).toStringAsFixed(2)}',
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
                  '$currencySymbol${displaySubtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 14),
                _totalRow(
                  'VAT (20%)',
                  '$currencySymbol${displayVat.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _totalRow(
                  'Total',
                  '$currencySymbol${displayTotal.toStringAsFixed(2)}',
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
                    if (changed == true && context.mounted) {
                      Navigator.pop(context, true);
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
                        Navigator.pop(context, true);
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
                      final pdfData =
                      await InvoicePdfService.generateInvoicePdf(
                        invoiceNumber: invoiceNumber,
                        clientName: clientName,
                        issueDate: issueDate,
                        dueDate: dueDate,
                        status: status,
                        subtotal: displaySubtotal,
                        vat: displayVat,
                        total: displayTotal,
                        items: displayItems
                            .map<Map<String, dynamic>>(
                              (item) => Map<String, dynamic>.from(item),
                        )
                            .toList(),
                        currencySymbol: currencySymbol,
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
                      final pdfData =
                    await InvoicePdfService.generateInvoicePdf(
                       invoiceNumber: invoiceNumber,
                       clientName: clientName,
                       issueDate: issueDate,
                       dueDate: dueDate,
                       status: status,
                       subtotal: displaySubtotal,
                       vat: displayVat,
                       total: displayTotal,
                       items: displayItems
                       .map((item) => Map<String, dynamic>.from(item))
                       .toList(),
                       currencySymbol: currencySymbol,
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
                      final deleted =
                      await _showDeleteConfirmation(context);

                      if (deleted == true && context.mounted) {
                        Navigator.pop(context, true);
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
  String? selectedClient;
  double vatRate = 20.0;
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

  @override
  void initState() {
    super.initState();

    _loadClients();

    final invoice = widget.invoice;

    if (invoice != null) {
      selectedClient = invoice.client;
      issueDate = invoice.issueDate;
      dueDate = invoice.dueDate;
      vatRate = invoice.vatRate;

      itemDescriptions.addAll(
        invoice.items.map((item) => item.description),
      );

      itemAmounts.addAll(
        invoice.items.map((item) => item.amount),
      );
    } else {
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

      itemDescriptions.add('Logo design');
      itemAmounts.add(250.00);
    }
  }

  double get subtotal =>
      itemAmounts.fold(0, (total, amount) => total + amount);

  double get vat => subtotal * (vatRate / 100);

  double get total => subtotal + vat;

  Future<void> _pickDate(bool issue) async {
    final parts = (issue ? issueDate : dueDate).split('/');

    final initial = DateTime(
      int.parse(parts[2]),
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) {
      return;
    }

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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    if (selectedClient == null || selectedClient!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client.'),
        ),
      );
      return;
    }

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

    if (due.isBefore(issue)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Due date cannot be before the issue date.'),
        ),
      );
      return;
    }

    if (itemDescriptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one invoice item.'),
        ),
      );
      return;
    }

    for (int i = 0; i < itemDescriptions.length; i++) {
      if (itemDescriptions[i].trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a description for every item.'),
          ),
        );
        return;
      }

      if (itemAmounts[i] <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Every item must have an amount greater than zero.'),
          ),
        );
        return;
      }
    }

    setState(() {
      isSaving = true;
    });

    final items = List.generate(
      itemDescriptions.length,
          (index) => InvoiceItem(
        description: itemDescriptions[index],
        amount: itemAmounts[index],
      ),
    );

    try {
      // EDITING AN EXISTING INVOICE
      if (widget.invoice != null) {
        final oldInvoice = widget.invoice!;

        final updatedInvoice = Invoice(
          id: oldInvoice.id,
          invoiceNumber: oldInvoice.invoiceNumber,
          client: selectedClient ?? oldInvoice.client,
          issueDate: issueDate,
          dueDate: dueDate,
          subtotal: subtotal,
          vat: vat,
          vatRate: vatRate,
          total: total,
          status: oldInvoice.status,
          items: items,
        );

        if (oldInvoice.id == null) {
          setState(() {
            isSaving = false;
          });

          return;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('invoices')
            .doc(oldInvoice.id)
            .update(updatedInvoice.toMap());

        for (int i = 0; i < invoices.length; i++) {
          if (invoices[i].id == oldInvoice.id) {
            invoices[i] = updatedInvoice;
            break;
          }
        }

        if (!mounted) return;

        Navigator.pop(context, true);
        return;
      }

      // CREATING A NEW INVOICE
      final number = await _generateInvoiceNumber();

      final invoice = Invoice(
        invoiceNumber: number,
        client: selectedClient ?? 'No client',
        issueDate: issueDate,
        dueDate: dueDate,
        subtotal: subtotal,
        vat: vat,
        vatRate: vatRate,
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
        client: invoice.client,
        issueDate: invoice.issueDate,
        dueDate: invoice.dueDate,
        subtotal: invoice.subtotal,
        vat: invoice.vat,
        vatRate: invoice.vatRate,
        total: invoice.total,
        status: invoice.status,
        items: invoice.items,
      );

      invoices.add(savedInvoice);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

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
      return 'NEW-1';
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

          if (invoiceNumber.startsWith('NEW-')) {
            final numberText =
            invoiceNumber.replaceFirst('NEW-', '');

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

    return 'NEW-$nextNumber';
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
                _PageHeader(title: 'Create Invoice'),
                const SizedBox(height: 25),
                const _FormLabel('Client'),
                const SizedBox(height: 7),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                  ),
                  decoration: _boxDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedClient,
                      isExpanded: true,
                      hint: const Text(
                        'Select Client',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                      items: clients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client.name,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClient = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                const _FormLabel('Issue Date'),
                const SizedBox(height: 7),
                _InvoiceInput(
                  text: issueDate,
                  onTap: () => _pickDate(true),
                ),
                const SizedBox(height: 13),
                const _FormLabel('Due Date'),
                const SizedBox(height: 7),
                _InvoiceInput(
                  text: dueDate,
                  onTap: () => _pickDate(false),
                ),
                const _FormLabel('VAT Rate'),
                const SizedBox(height: 7),

                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  decoration: _boxDecoration(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: vatRate,
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
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          vatRate = value;
                        });
                      },
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
                                  itemDescriptions[index] =
                                      value;
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
                          initialText:
                          '$currencySymbol${itemAmounts[index].toStringAsFixed(2)}',
                          height: 37,
                          onChanged: (value) {
                            final parsed =
                            double.tryParse(
                              value
                                  .replaceAll(currencySymbol, '')
                                  .trim(),
                            );

                            if (parsed != null) {
                              setState(() {
                                itemAmounts[index] =
                                    parsed;
                              });
                            }
                          },
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
                      itemDescriptions.add('New item');
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
                  '$currencySymbol${subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 14),
                _totalRow(
                  'Vat (20%)',
                  '$currencySymbol${vat.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 7),
                const Divider(),
                const SizedBox(height: 7),
                _totalRow(
                  'Total',
                  '$currencySymbol${total.toStringAsFixed(2)}',
                  large: true,
                ),
                const SizedBox(height: 13),
                _PrimaryButton(
                  text: isSaving ? 'Saving...' : 'Save Invoice',
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
  Future<void> _loadClientsFromFirestore() async {
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

    if (!mounted) return;

    setState(() {
      clients
        ..clear()
        ..addAll(loadedClients);
    });
  }

  Future<void> _openAddClient() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddClientScreen(),
      ),
    );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadClientsFromFirestore();
  }

  Future<void> _openClientDetails(Client client) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientDetailsScreen(
          client: client,
        ),
      ),
    );

    if (changed == true) {
      setState(() {});
    }
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
                          builder: (_) =>
                          const DashboardScreen(),
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

                  if (clients.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 50,
                        horizontal: 20,
                      ),
                      decoration: _boxDecoration(),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 55,
                            color: Color(0xFF98A2B3),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'No clients yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first client to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final client in clients)
                      GestureDetector(
                        onTap: () {
                          _openClientDetails(client);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client.name,
                                      style: const TextStyle(
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),

                                    if (client.email.isNotEmpty)
                                      Text(
                                        client.email,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color:
                                          Color(0xFF667085),
                                        ),
                                      ),

                                    if (client.phone.isNotEmpty)
                                      Text(
                                        client.phone,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color:
                                          Color(0xFF667085),
                                        ),
                                      ),

                                    if (client.address.isNotEmpty)
                                      Text(
                                        client.address,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color:
                                          Color(0xFF667085),
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
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      const _BottomNavigation(
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
      return;
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

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a client name.'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to add a client.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final client = Client(
        name: name,
      );

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('clients')
          .add(client.toMap());

      clients.add(
        Client(
          id: docRef.id,
          name: name,
        ),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong while saving the client.',
          ),
        ),
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
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration(
                    'Enter client name',
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

  double _calculateRevenue() {
    double total = 0;

    for (final invoice in invoices) {
      total += invoice.total;
    }

    return total;
  }

  double _calculateOutstanding() {
    double total = 0;

    for (final invoice in invoices) {
      if (invoice.status != 'Paid') {
        total += invoice.total;
      }
    }

    return total;
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
                value: '$currencySymbol${_calculateRevenue().toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Outstanding',
                value: '$currencySymbol${_calculateOutstanding().toStringAsFixed(2)}',
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
                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
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
          ],
        ),
      ),
      bottomNavigationBar:
      const _BottomNavigation(selectedIndex: 4),
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

  final List<Map<String, String>> currencies = [
    {
      'code': 'GBP',
      'name': 'British Pound (£)',
    },
    {
      'code': 'USD',
      'name': 'US Dollar (\$)',
    },
    {
      'code': 'EUR',
      'name': 'Euro (€)',
    },
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

          ...currencies.map((currency) {
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
                title: Text(currency['name']!),
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
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE1E5EA),
        ),
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF808080),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2864E8),
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

class _InvoiceInput extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _InvoiceInput({
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
        ),
        alignment: Alignment.centerLeft,
        decoration: _boxDecoration(),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF344054),
          ),
        ),
      ),
    );
  }
}

class _EditableInvoiceInput
    extends StatefulWidget {
  final String initialText;
  final double height;
  final ValueChanged<String>? onChanged;

  const _EditableInvoiceInput({
    required this.initialText,
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
        decoration: _inputDecoration(''),
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

