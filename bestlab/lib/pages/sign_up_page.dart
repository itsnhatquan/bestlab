import 'package:flutter/material.dart';
import 'package:bestlab/components/my_button.dart';
import 'package:bestlab/components/my_textfield_stateful.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'home_page.dart';
import 'login_page.dart';

//
// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();
//   double _buttonOpacity = 1.0;
//
//   void signUserUp(BuildContext context) async {
//     setState(() {
//       _buttonOpacity = 0.5;
//     });
//
//     bool success = await AuthService().signUp(usernameController.text, passwordController.text);
//
//     setState(() {
//       _buttonOpacity = 1.0;
//     });
//
//     if (success) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sign Up Failed')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.grey[300],
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 50),
//               Image.asset('lib/images/logo.png', height: 293),
//               const SizedBox(height: 50),
//               MyTextfieldStateful(
//                 controller: usernameController,
//                 hintText: 'Username',
//                 labelText: 'Username',
//                 obscureText: false,
//                 showEyeIcon: false,
//               ),
//               const SizedBox(height: 10),
//               MyTextfieldStateful(
//                 controller: passwordController,
//                 hintText: 'Password',
//                 labelText: 'Password',
//                 showEyeIcon: true,
//               ),
//               const SizedBox(height: 25),
//               AnimatedOpacity(
//                 opacity: _buttonOpacity,
//                 duration: Duration(milliseconds: 300),
//                 child: MyButton(
//                   text: 'Sign Up',
//                   onTap: () => signUserUp(context),
//                 ),
//               ),
//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  double _buttonOpacity = 1.0;

  void signUserUp(BuildContext context) async {
    setState(() {
      _buttonOpacity = 0.5;
    });

    bool success = await AuthService().signUp(usernameController.text, passwordController.text);

    setState(() {
      _buttonOpacity = 1.0;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('lib/images/logo.png', height: 293),
                const SizedBox(height: 50),
                MyTextfieldStateful(
                  controller: usernameController,
                  hintText: 'Username',
                  labelText: 'Username',
                  obscureText: false,
                  showEyeIcon: false,
                ),
                const SizedBox(height: 10),
                MyTextfieldStateful(
                  controller: passwordController,
                  hintText: 'Password',
                  labelText: 'Password',
                  showEyeIcon: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                AnimatedOpacity(
                  opacity: _buttonOpacity,
                  duration: Duration(milliseconds: 300),
                  child: MyButton(
                    text: 'Sign Up',
                    onTap: () => signUserUp(context),
                  ),
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Already a member? Sign in now'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}