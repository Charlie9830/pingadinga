import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pingadinga/hiccup.dart';
import 'package:pingadinga/network_item.dart';

class LatestHiccup extends StatelessWidget {
  final Hiccup hiccup;
  final Variance variance;
  const LatestHiccup({
    super.key,
    required this.hiccup,
    this.variance = Variance.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: _buildTooltipMessage(context, hiccup),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.access_time, color: Colors.orange),

          if (variance == Variance.normal) ...[
            SizedBox(width: 8),
            Text(
              _getFormattedTime(hiccup.startTimestamp),
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: Colors.orange),
            ),
          ],
        ],
      ),
    );
  }

  TextSpan _buildTooltipMessage(BuildContext context, Hiccup hiccup) {
    final boldStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return TextSpan(
      children: [
        TextSpan(
          children: [
            TextSpan(text: 'A disconnection event was detected '),
            TextSpan(
              text: _getTimeAgo(hiccup.startTimestamp),
              style: boldStyle,
            ),
            TextSpan(text: ' at '),
            TextSpan(
              text: '${_getFormattedTime(hiccup.startTimestamp)} \n',
              style: boldStyle,
            ),
          ],
        ),

        hiccup.endTimestamp == null
            ? TextSpan(
              children: [
                TextSpan(text: 'So far '),
                TextSpan(text: '${hiccup.missedPings} ', style: boldStyle),
                TextSpan(text: 'pings have been dropped.'),
              ],
            )
            : TextSpan(
              children: [
                TextSpan(text: 'The connection was restored at '),

                TextSpan(
                  text: '${_getFormattedTime(hiccup.endTimestamp!)}\n',
                  style: boldStyle,
                ),

                TextSpan(text: 'A total outage time of '),

                TextSpan(
                  text:
                      '${_getOutageTime(hiccup.endTimestamp!.difference(hiccup.startTimestamp))}.\n',
                  style: boldStyle,
                ),

                TextSpan(
                  children: [
                    TextSpan(text: 'A total of '),
                    TextSpan(
                      text: '${hiccup.missedPings} ',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(text: 'pings were lost.'),
                  ],
                ),
              ],
            ),
      ],
    );
  }

  String _getOutageTime(Duration duration) {
    if (duration.inMinutes == 0) {
      return '${duration.inSeconds} seconds';
    }

    if (duration.inHours == 0) {
      return '${duration.inMinutes} minutes';
    }

    return '${duration.inHours} hours';
  }

  String _getFormattedTime(DateTime stamp) {
    final formatter = DateFormat(DateFormat.HOUR24_MINUTE_SECOND);

    return formatter.format(stamp);
  }

  String _getTimeAgo(DateTime stamp) {
    final difference = DateTime.now().difference(stamp);

    if (difference.inSeconds <= 60) {
      return '${difference.inSeconds} seconds ago';
    }

    if (difference.inMinutes == 1) {
      return '${difference.inMinutes} minute ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}
