import 'dart:ui';
import 'package:flutter/material.dart';
import '../oki/import.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State {

  final image = const AssetImage(Assets.icLauncher);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 21, 31, 1),
      body: Stack(
        children: [
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                image: DecorationImage(image: image),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                image: image,
                width: 200,
                height: 200,
              ),
            ),
          ),

          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 400),
              child: Text(Ressources.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}