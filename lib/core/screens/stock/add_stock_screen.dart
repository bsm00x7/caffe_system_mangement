import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/widgets/title_style.dart';

class AddStockScreen extends StatelessWidget {
  const AddStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: TitleStyleWidget(
            title: 'Add',
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
