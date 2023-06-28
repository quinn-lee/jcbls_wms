import 'package:flutter/material.dart';
import 'package:jcbls_app/util/color.dart';

class LoginButton extends StatelessWidget {
  final String title;
  final bool enable;
  final VoidCallback? onPressed;
  final double widthFactor;

  const LoginButton(this.title, this.widthFactor,
      {Key? key, this.enable = true, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        height: 45,
        onPressed: enable ? onPressed : null,
        disabledColor: primary[50],
        color: primary,
        child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
