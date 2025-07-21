import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppDialog extends StatelessWidget {
  final PackageInfo packageInfo;
  const AboutAppDialog({super.key, required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.75,
      child: AlertDialog(
        title: Text(
          'Pinga Dinga',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontFamily: 'ZenDots'),
        ),

        content: Row(
          children: [
            Flexible(
              flex: 1,
              child: Image.asset(
                './assets/app_logo.png',
                fit: BoxFit.scaleDown,
              ),
            ),

            VerticalDivider(),

            Flexible(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Version: ${packageInfo.version}'),
                    Text('Build Number: ${packageInfo.buildNumber}'),
                    Text('Created By: Charlie Hall'),
                    SizedBox(height: 12),
                    SelectableText(
                      'https://github.com/charlie9830/pingadinga/releases',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),

                    Divider(height: 48),

                    Text("""
Copyright 2025 Charlie Hall
                
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
                
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
                
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                
                
                """),
                  ],
                ),
              ),
            ),
          ],
        ),

        actions: [
          TextButton(
            child: Text('Licenses'),
            onPressed: () => showLicensePage(context: context),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}
