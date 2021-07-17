import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppbarTest extends StatefulWidget {
  @override
  _AppbarTestState createState() => _AppbarTestState();
}

class _AppbarTestState extends State<AppbarTest> {

  Future<void> getHttpTestData() async{
    String baseUrl = 'https://api.odcloud.kr/api/3041572/v1';
    String apiUrl = '/uddi:a7ac937d-7ae7-4b96-9c1a-f2e38ce24abc_201606202237?page=1&perPage=10';
    var header = {'Authorization': 'Infuser NE62cX5cSluGujxGrAbIW18znmIO+JZWDExw2AFUyl5KPExPC25FuymmmBuQOlADE9UsAz2BIRYiIe3vJJCoCQ=='};
    String completeUrl = baseUrl+apiUrl;

    final response = await http.get(completeUrl, headers: header);

    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: InkWell(
            onTap: () async {
              await getHttpTestData();
            },
            child: Container(
              child: Text('Go to update page'),
            ),
          ),
        ),
    );
  }
}
