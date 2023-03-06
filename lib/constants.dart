import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<String> days(BuildContext context) {
  return [
    AppLocalizations.of(context)!.sun,
    AppLocalizations.of(context)!.mon,
    AppLocalizations.of(context)!.tue,
    AppLocalizations.of(context)!.wed,
    AppLocalizations.of(context)!.thu,
    AppLocalizations.of(context)!.fri,
    AppLocalizations.of(context)!.sat,
  ];
}

List<String> months(BuildContext context) {
  return [
    AppLocalizations.of(context)!.jan,
    AppLocalizations.of(context)!.feb,
    AppLocalizations.of(context)!.mar,
    AppLocalizations.of(context)!.apr,
    AppLocalizations.of(context)!.may,
    AppLocalizations.of(context)!.jun,
    AppLocalizations.of(context)!.jul,
    AppLocalizations.of(context)!.aug,
    AppLocalizations.of(context)!.sep,
    AppLocalizations.of(context)!.oct,
    AppLocalizations.of(context)!.nov,
    AppLocalizations.of(context)!.dec,
  ];
}
