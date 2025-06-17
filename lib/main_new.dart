import 'package:flutter/material.dart';
import 'phone_frame.dart';
import 'services/data_service.dart';
import 'screens/home_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'screens/add_pet_screen.dart';
import 'screens/add_health_record_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'models/pet.dart';
import 'utils/snackbar_utils.dart';

void main() {
  // Initialize data service with sample data
  final dataService = DataService();
  dataService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Health Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PhoneSimulator(),
    );
  }
}

class PhoneSimulator extends StatefulWidget {
  const PhoneSimulator({super.key});

  @override
  State<PhoneSimulator> createState() => _PhoneSimulatorState();
}

class _PhoneSimulatorState extends State<PhoneSimulator> {
  String _currentRoute = '/login';
  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });

    // Actually navigate to the route using the Navigator
    navigatorKey.currentState?.pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    Widget getPageForRoute(String route, Object? arguments) {
      switch (route) {
        case '/login':
          return LoginScreen(onNavigate: _navigateTo);
        case '/register':
          return RegisterScreen(onNavigate: _navigateTo);
        case '/home':
          return HomeScreen(onNavigate: _navigateTo);
        case '/pet_detail':
          final Pet pet = arguments as Pet;
          return PetDetailScreen(pet: pet);
        case '/add_pet':
          return const AddPetScreen();
        case '/add_health_record':
          final Pet pet = arguments as Pet;
          return AddHealthRecordScreen(pet: pet);
        case '/admin_dashboard':
          return const AdminDashboardScreen();
        default:
          return LoginScreen(onNavigate: _navigateTo);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: PhoneFrame(
        child: Navigator(
          key: navigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => getPageForRoute(
                settings.name ?? _currentRoute,
                settings.arguments,
              ),
            );
          },
          initialRoute: _currentRoute,
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const LoginScreen({super.key, required this.onNavigate});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.smartphone, size: 80, color: Colors.blue),
                  const SizedBox(height: 30),
                  const Text(
                    'Mobile Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Attempt login with provided credentials
                        final dataService = DataService();
                        final success = dataService.login(
                          _emailController.text,
                          _passwordController.text,
                        );

                        if (success) {
                          widget.onNavigate('/home');
                        } else {
                          // Show error message inside phone frame
                          showSnackBarInPhoneFrame(
                            message: 'Invalid email or password',
                            backgroundColor: Colors.red,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Use pushReplacementNamed for direct navigation
                      navigatorKey.currentState?.pushReplacementNamed(
                        '/register',
                      );
                      // Also update the UI state
                      widget.onNavigate('/register');
                    },
                    child: const Text(
                      'Don\'t have an account? Register here',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Admin Credentials:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Text(
                    'Email: admin@gmail.com\nPassword: admin123',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Registration Screen
class RegisterScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const RegisterScreen({super.key, required this.onNavigate});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onNavigate('/login');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.app_registration,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create an Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create a new user with the registration information
                      final dataService = DataService();
                      final success = dataService.register(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                      );

                      if (success) {
                        // Show success message inside phone frame
                        showSnackBarInPhoneFrame(
                          message: 'Registration successful!',
                          backgroundColor: Colors.green,
                        );

                        // Navigate to home screen using both methods
                        navigatorKey.currentState?.pushReplacementNamed(
                          '/home',
                        );
                        widget.onNavigate('/home');
                      } else {
                        // Show error message inside phone frame
                        showSnackBarInPhoneFrame(
                          message:
                              'Email already in use. Please use a different email.',
                          backgroundColor: Colors.red,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Use pushReplacementNamed for direct navigation
                    navigatorKey.currentState?.pushReplacementNamed('/login');
                    // Also update the UI state
                    widget.onNavigate('/login');
                  },
                  child: const Text(
                    'Already have an account? Login here',
                    style: TextStyle(color: Colors.blue),
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
