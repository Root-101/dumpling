import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// The mark: source → config → destination, with the backup arrow below
class DumplingLogo extends StatelessWidget {
  final double height;

  const DumplingLogo({super.key, this.height = 21});

  static const String svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 88 62">'
      '<rect x="4" y="15" width="16" height="16" rx="4" fill="#e6b77e"/>'
      '<path d="M20 23H29M59 23H68" fill="none" stroke="#9d8fd0" stroke-width="4"/>'
      '<rect x="31.5" y="9.5" width="25" height="27" rx="6.5" fill="none" stroke="#9d8fd0" stroke-width="5"/>'
      '<rect x="68" y="15" width="16" height="16" rx="4" fill="#9d8fd0"/>'
      '<path d="M12 47.5Q44 61.5 76 48.5M67.91 45.89L76 48.5L72.02 56.01" fill="none" stroke="#6d5bb5" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dumpling',
      child: SvgPicture.string(svg, height: height, width: height * 88 / 62),
    );
  }
}
