import 'package:flutter/material.dart';

class PrivacyWrapper extends StatefulWidget {
  final Widget child;
  const PrivacyWrapper({required this.child, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrivacyWrapperState createState() => _PrivacyWrapperState();
}

class _PrivacyWrapperState extends State<PrivacyWrapper>
    with WidgetsBindingObserver {
  bool _inBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _inBackground = state != AppLifecycleState.resumed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_inBackground)
            Container(
              color: Colors.black,
            ),
        ],
      ),
    );
  }
}
