import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

late Map<String, Map<String, String>> districtMap;

Future<void> loadDistrictMap() async {
  final raw = await rootBundle.loadString('assets/data/codes.csv');
  final rows = const CsvToListConverter().convert(raw);

  districtMap = {};

  for (final row in rows.skip(1)) {
    final areaCd = row[0].toString();
    final signguCd = row[1].toString();
    final name = row[2].toString().trim();
    districtMap[name] = {
      'areaCd': areaCd,
      'signguCd': signguCd,
    };
  }

  print('✅ 시군구 코드 ${districtMap.length}개 로드됨');
}
