import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

class VGRatioList extends StatelessWidget {
  final List<Map<String, dynamic>> ratios;

  const VGRatioList({super.key, required this.ratios});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ratios.map((r) {
        final pass = r['pass'] == true;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(child: Text(r['name'].toString(), style: primaryTextStyle(size: 13))),
              Text('${r['measured']} / ${r['ideal']}', style: secondaryTextStyle(size: 12)),
              8.width,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pass ? const Color(0xFFE8F5E9) : bmPrimaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pass ? VGCopy.resultPass : VGCopy.resultNote,
                  style: boldTextStyle(color: pass ? const Color(0xFF2E7D32) : bmSpecialColor, size: 10),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
