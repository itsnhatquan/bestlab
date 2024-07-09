
import 'package:flutter/material.dart';
import 'package:bestlab/components/my_button.dart';
import 'package:bestlab/components/my_textfield.dart';
import 'package:bestlab/components/square_tile.dart';
import 'package:bestlab/components/my_textfield_stateful.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // logo
             Image.asset('lib/images/logo.png',height:293),


              // welcome back, you've been missed!


              // username textfield
              MyTextfieldStateful(
                controller: usernameController,
                hintText: 'Username',
                labelText: 'Username',
                obscureText: false,
                showEyeIcon: false,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextfieldStateful(
                controller: passwordController,
                hintText: 'Password',
                labelText: 'Password',
                showEyeIcon: true,
              ),

              const SizedBox(height: 10),

              // forgot password?
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

              // sign in button
              MyButton(
                text: 'Sign In',
                onTap: signUserIn,
              ),

              const SizedBox(height: 50),

              // or continue with

              const SizedBox(height: 50),

              // google + apple sign in buttons


              const SizedBox(height: 50),

              // not a member? register now

            ],
          ),
        ),
      ),
    );
  }
}