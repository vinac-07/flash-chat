import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:flash_chat/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  //Mixin are a way of reusing a class's code in multiple hierarchies
  AnimationController controller;
  Animation animationColor; //for different animation other than linear
  Animation animationSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = AnimationController(
      //it will provide a ticker number that usually goes from 0 to 1
      duration: Duration(seconds: 1), // in 60 seconds we might get 60 ticker
      vsync:
          this, //f the ticker provider usually it is same class for that we need to provide the Ticker provider
//        upperBound: 100,// instead of ticking to 1 we can change it tick it to 100
    );

//    animation = CurvedAnimation(
//        parent: controller,        //require animation controller to which we are adding curved animation
//        curve: Curves.decelerate,   //what kind of curve we want
//    );
// it cannot have a custom upper bound it will tick to 1

    animationColor = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(
        controller); //from one color to another there are different tweens in flutter

    animationSize =
        CurvedAnimation(parent: controller, curve: Curves.decelerate);

    controller.forward(); // this is to move animation forward
//  controller.reverse(from : 1.0) ; this is to move animation backwards

//    animation.addStatusListener((status) { // to play with status of listener
//      if(status== AnimationStatus.completed){
//        controller.reverse(from: 1.0);
//      }else if (status == AnimationStatus.dismissed){
//        controller.forward();
//      }
//    });
    controller.addListener(() {
      //to see what the controller is doing
      setState(() {});
//      print(controller.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.red.withOpacity(controller.value),//opacity take value from 0.0 to 1.0
      backgroundColor: animationColor.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height:
                        animationSize.value * 100, //to add custom upperbound
                  ),
                ),
                SizedBox(
                  child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText('Flash chat'),
                        ],
                      )),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              colour: Colors.lightBlueAccent,
              title: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              colour: Colors.blueAccent,
              title: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
