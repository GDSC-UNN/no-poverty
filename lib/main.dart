import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig["apiKey"],
      authDomain: firebaseConfig["authDomain"],
      projectId: firebaseConfig["projectId"],
      appId: firebaseConfig["appId"],
      messagingSenderId: firebaseConfig['messagingSenderId'],
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Connect',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Connect', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _signUp(context),
                          child: Text('Sign Up', style: TextStyle(fontSize: 18)),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _signIn(context),
                          child: Text('Sign In', style: TextStyle(fontSize: 18)),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear any previous error message
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('Sign up successful');
      // Navigate to WelcomeScreen after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      print('Sign-up error: $e');
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear any previous error message
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('Sign in successful');
      // Navigate to WelcomeScreen after successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      print('Sign-in error: $e');
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'weak-password':
          return 'The password must be 6 characters long or more.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        default:
          return 'An error occurred, please try again later.';
      }
    } else {
      return 'An error occurred, please try again later.';
    }
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user?.displayName ?? user?.email}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionButton(
              title: 'Emergency Assistance Information',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyAssistanceInfoScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            SectionButton(
              title: 'Financial Tips',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FinancialTipsScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            SectionButton(
              title: 'Job Search',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JobSearchScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SectionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const SectionButton({Key? key, required this.title, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }
}

// Emergency Assistance Information Screen
class EmergencyAssistanceInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Assistance Information'),
      ),
      body: EmergencyAssistanceInfo(),
    );
  }
}

class EmergencyAssistanceInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local Hotlines:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Emergency: 911'),
            Text('Mental Health Support: 1-800-273-TALK'),
            SizedBox(height: 10),
            Text(
              'Shelters:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Address: 123 Main St'),
            Text('Eligibility: Open to all'),
            SizedBox(height: 10),
            Text(
              'Food Banks:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Location: 456 Elm St'),
            Text('Eligibility: Proof of income required'),
          ],
        ),
      ),
    );
  }
}

// Financial Tips Screen
class FinancialTipsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Tips'),
      ),
      body: FinancialTips(),
    );
  }
}

class FinancialTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budgeting Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('1. Keep track of your expenses'),
            Text('2. Create a monthly budget'),
            Text('3. Set aside savings for emergencies'),
            SizedBox(height: 10),
            Text(
              'Saving Money Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('1. Cut down on unnecessary expenses'),
            Text('2. Cook meals at home instead of dining out'),
            Text('3. Look for discounts and coupons when shopping'),
          ],
        ),
      ),
    );
  }
}

// Job Search Screen
class JobSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Search'),
      ),
      body: JobSearchSection(),
    );
  }
}

class JobSearchSection extends StatefulWidget {
  @override
  _JobSearchSectionState createState() => _JobSearchSectionState();
}

class _JobSearchSectionState extends State<JobSearchSection> {
  final TextEditingController _jobTitleController = TextEditingController();
  List<dynamic> _jobs = [];
  bool _isLoading = false;

  Future<void> _fetchJobs(String jobTitle) async {
    setState(() {
      _isLoading = true;
      _jobs = [];
    });

    try {
      final response = await http.get(Uri.parse('https://jobs.github.com/positions.json?description=$jobTitle'));
      if (response.statusCode == 200) {
        setState(() {
          _jobs = json.decode(response.body);
        });
      } else {
        print('Failed to fetch jobs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching jobs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _jobTitleController,
          decoration: InputDecoration(
            hintText: 'Enter job title',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _fetchJobs(_jobTitleController.text);
          },
          child: Text('Search Jobs'),
        ),
        SizedBox(height: 10),
        _isLoading
            ? CircularProgressIndicator()
            : _jobs.isEmpty
                ? Text('No jobs found')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _jobs.map<Widget>((job) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Title: ${job['title']}'),
                          Text('Description: ${job['description']}'),
                          Text('How to apply: ${job['how_to_apply']}'),
                          Divider(),
                        ],
                      );
                    }).toList(),
                  ),
      ],
    );
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    super.dispose();
  }
}