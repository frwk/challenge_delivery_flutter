import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class PinInput extends StatefulWidget {
  final String? Function(String?)? validator;
  final PinputAutovalidateMode? pinputAutovalidateMode;

  const PinInput({super.key, this.validator, this.pinputAutovalidateMode = PinputAutovalidateMode.onSubmit});

  @override
  _PinInputState createState() => _PinInputState();

  @override
  String toStringShort() => 'Pin Field';
}

class _PinInputState extends State<PinInput> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        color: const Color.fromRGBO(70, 69, 66, 1),
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 171, 64, 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
    );

    final cursor = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 21,
        height: 1,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(137, 146, 160, 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return Pinput(
        length: 4,
        controller: controller,
        focusNode: focusNode,
        defaultPinTheme: defaultPinTheme,
        separatorBuilder: (index) => const SizedBox(width: 16),
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05999999865889549),
                offset: Offset(0, 3),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          textStyle: GoogleFonts.poppins(
            fontSize: 20,
            color: const Color.fromRGBO(255, 0, 0, 1),
          ),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 0, 0, 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        showCursor: true,
        cursor: cursor,
        pinputAutovalidateMode: widget.pinputAutovalidateMode!,
        validator: widget.validator,
        errorBuilder: (context, message) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text(
                context!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color.fromRGBO(255, 0, 0, 1),
                ),
              ),
            ),
          );
        });
  }
}
