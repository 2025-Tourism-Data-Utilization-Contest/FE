import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SeasonMarkers {
  static Future<Set<Marker>> loadSpringMarkers(BuildContext context) async {
    final icon = await BitmapDescriptor.asset(
      createLocalImageConfiguration(context),
      'assets/images/spring_d.png',
    );

    return {
      Marker(
        markerId: MarkerId('spring1'),
        position: LatLng(34.94, 127.71),
        icon: icon,
        infoWindow: InfoWindow(title: '순천만 습지'),
      ),
      // 추가 마커도 동일하게
    };
  }



  static final Set<Marker> springMarkers = {
    Marker(
      markerId: MarkerId('spring1'),
      position: LatLng(34.94, 127.71),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      infoWindow: InfoWindow(title: '순천만 습지'),
    ),
    Marker(
      markerId: MarkerId('spring2'),
      position: LatLng(37.5665, 126.9780),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      infoWindow: InfoWindow(title: '여의도 윤중로 벚꽃길'),
    ),
    Marker(
      markerId: MarkerId('spring3'),
      position: LatLng(35.8714, 128.6014),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      infoWindow: InfoWindow(title: '진해 군항제'),
    ),
    Marker(
      markerId: MarkerId('spring4'),
      position: LatLng(37.5400, 127.0763),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      infoWindow: InfoWindow(title: '서울 대공원 벚꽃길'),
    ),
    Marker(
      markerId: MarkerId('spring5'),
      position: LatLng(35.1595, 126.8526),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      infoWindow: InfoWindow(title: '광양 매화마을'),
    ),
  };

  static final Set<Marker> summerMarkers = {
    Marker(
      markerId: MarkerId('summer1'),
      position: LatLng(35.1796, 129.0756), // 부산 해운대
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: '부산 해운대 해수욕장'),
    ),
    Marker(
      markerId: MarkerId('summer2'),
      position: LatLng(38.2079, 128.5912), // 강원도 속초 설악산
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: '설악산 국립공원'),
    ),
    Marker(
      markerId: MarkerId('summer3'),
      position: LatLng(36.8151, 127.1147), // 전북 무주
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: '무주 덕유산 리조트'),
    ),
    Marker(
      markerId: MarkerId('summer4'),
      position: LatLng(34.8004, 126.3908), // 전남 여수
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: '여수 오동도'),
    ),
    Marker(
      markerId: MarkerId('summer5'),
      position: LatLng(37.7460, 128.8936), // 강원 양양 낙산해변
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: '양양 낙산 해수욕장'),
    ),
  };

  static final Set<Marker> fallMarkers = {
    Marker(
      markerId: MarkerId('fall1'),
      position: LatLng(37.7709, 127.0427), // 서울 북한산 국립공원
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: '북한산 국립공원 단풍'),
    ),
    Marker(
      markerId: MarkerId('fall2'),
      position: LatLng(37.5796, 128.1500), // 강원도 설악산
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: '설악산 단풍'),
    ),
    Marker(
      markerId: MarkerId('fall3'),
      position: LatLng(35.8396, 128.7532), // 경북 안동 하회마을
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: '안동 하회마을 단풍'),
    ),
    Marker(
      markerId: MarkerId('fall4'),
      position: LatLng(36.2683, 127.7052), // 전북 무주 덕유산
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: '덕유산 국립공원 단풍'),
    ),
    Marker(
      markerId: MarkerId('fall5'),
      position: LatLng(37.3216, 127.2093), // 경기 가평 유명산
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: '유명산 단풍'),
    ),
  };

  static final Set<Marker> winterMarkers = {
    Marker(
      markerId: MarkerId('winter1'),
      position: LatLng(37.7903, 128.4064), // 강원도 평창 휘닉스 평창
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: '휘닉스 평창 스키장'),
    ),
    Marker(
      markerId: MarkerId('winter2'),
      position: LatLng(37.8243, 128.1553), // 강원도 강릉 정동진 눈 축제 지역
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: '정동진 눈 축제'),
    ),
    Marker(
      markerId: MarkerId('winter3'),
      position: LatLng(37.3616, 127.0571), // 경기 가평 아침고요수목원 (겨울정원)
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: '아침고요수목원 겨울정원'),
    ),
    Marker(
      markerId: MarkerId('winter4'),
      position: LatLng(37.5585, 126.9790), // 서울 덕수궁 설경 (도심 겨울 풍경)
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: '덕수궁 겨울 설경'),
    ),
    Marker(
      markerId: MarkerId('winter5'),
      position: LatLng(38.1486, 128.5410), // 강원도 강릉 경포대 눈꽃축제
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: '경포대 눈꽃축제'),
    ),
  };
}
