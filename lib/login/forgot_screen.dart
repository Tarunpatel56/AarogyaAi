import 'package:flutter/material.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
           SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height * 0.25,
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    child: Image.asset("assets/logo3.png"),
                  ),
                ),
              ),
                 SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
        
              Text(
                "Forgot Password",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              Text("Enter your email to reset you password",style: TextStyle(fontSize: 18),),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
                Card(elevation: 8,
                  child: TextFormField(decoration: InputDecoration(border: OutlineInputBorder(),hintText: "Email"),)),
                 SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.06,
                      width: MediaQuery.sizeOf(context).width * 0.8,
        
                      child: ElevatedButton(
                        onPressed: () {
                         
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent.shade700,
                        ),
                        child: Text(
                          "Reset Password",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                       SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
              InkWell(
                onTap: () {
               
                },
                child: RichText(
                  text: TextSpan(
                    text: "Remember it? Login",
                    style: TextStyle(
                      color: Colors.blueAccent.shade700,
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
        
        ],),
      ),
    );
  }
}