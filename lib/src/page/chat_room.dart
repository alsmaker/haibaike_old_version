import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hibaike/src/component/date_time_formatter.dart';
import 'package:hibaike/src/controller/bottom_index_controller.dart';
import 'package:hibaike/src/controller/sign_controller.dart';
import 'package:hibaike/src/model/bike.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  int _limit = 20;
  bool isLoading = false;
  final ScrollController listScrollController = ScrollController();
  SignController signCtrl = Get.find();
  String currentUserId;
  final dateTimeFormatter = DateTimeFormatter();
  BottomIndexController indexCtrl = Get.find();

  @override
  void initState() {
    currentUserId = signCtrl.currentUser.value.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '채팅', style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('chats')
                    .where('userPair', arrayContains: currentUserId)
                    .limit(_limit).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        //valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  } else {
                    return ListView.separated(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) => buildItem(context, snapshot.data.docs[index]),
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: snapshot.data.docs.length,
                      controller: listScrollController,
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              //child: isLoading ? const Loading() : Container(),
              child: isLoading ? const CircularProgressIndicator() : Container(),
            )
          ],
        ),
        onWillPop: () {
          BottomIndexController.to.changePageIndex(0);
          print('on will pop tabbed');
          Get.offAllNamed('/');
        },
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: indexCtrl.currentIndex.value,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            indexCtrl.changePageIndex(index);
            switch(index) {
              case 0:
                Get.toNamed('/');
                break;
              case 1:
                Get.toNamed('/nearby');
                break;
              case 2:
                if(signCtrl.isSignIn.value == true)
                  Get.toNamed('/chatRoom');
                else
                  Get.toNamed('/signUp');
                break;
              case 3:
                Get.toNamed('/tips');
                break;
              case 4:
                if(signCtrl.isSignIn.value == true)
                  Get.toNamed('/myPage');
                else
                  Get.toNamed('/signUp');
            //Get.toNamed('/signUp/saveProfile');
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '홈'),
            BottomNavigationBarItem(
                icon: Icon(Icons.place_outlined),
                activeIcon: Icon(Icons.place),
                label: '주변'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_outlined),
                activeIcon: Icon(Icons.chat),
                label: '채팅'),
            BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                activeIcon: Icon(Icons.help),
                label: '거래팁'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                activeIcon: Icon(Icons.account_circle),
                label: signCtrl.isSignIn.value ? 'my' : '로그인'),
          ],
        ),
      ),
    );
  }

  Widget bikeThumbnailWidget(String bikeId) {
    double thumbnailSize = 60;
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('bikes').doc(bikeId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          //return CircularProgressIndicator();
          return Container(
            width: 60,
            height: 60,
            padding: EdgeInsets.only(left: 20, right: 10, bottom: 10, top: 10),
            margin: EdgeInsets.only(left: 10),
          );
        else {
          if (snapshot.data.data() == null) {
            return Container(
              child: Text(
                '거래종료',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          } else {
            BikeData bikeData = BikeData.fromJson(snapshot.data.data());
            return Container(
              padding: EdgeInsets.only(left: 10, right: 0, top: 0, bottom: 0),
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                    width: thumbnailSize,
                    height: thumbnailSize,
                    padding: EdgeInsets.all(10.0),
                  ),
                  imageUrl: bikeData.imageList[0],
                  width: thumbnailSize,
                  height: thumbnailSize,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
            );
          }
        }
      },
    );
  }

  Widget unreadCounterWidget(DocumentSnapshot document, String peerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: document.reference
          .collection(document.id)
          .where('state', isEqualTo: 'unread')
          .where('idFrom', isEqualTo: peerId)
          .snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          return Container(
            width: 20,
            height: 20,
          );
        else {
          var length = snapshot.data.docs.length;
          if(length > 0)
            return Container(
              width: 20,
              height: 20,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  length.toString(),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                width: 20,
                height: 20,
              ),
            );

          else
            return Container(
              width: 20,
              height: 20,
            );
        }
      },
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    var userPairFromDB = document.data()['userPair'];
    List<String> userPair = new List<String>.from(userPairFromDB);
    String peerId;
    if (userPair[0] == signCtrl.currentUser.value.uid)
      peerId = userPair[1];
    else if (userPair[1] == signCtrl.currentUser.value.uid)
      peerId = userPair[0];

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(peerId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            print(snapshot.data['nick_name']);
            return Container(
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    Material(
                      child: ((snapshot.data['profile_image_url'] != null) &&
                              (snapshot.data['profile_image_url'].length != 0))
                          ? CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.0,
                                  //valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                                width: 60.0,
                                height: 60.0,
                                padding: EdgeInsets.all(0.0),
                              ),
                              imageUrl: snapshot.data['profile_image_url'],
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 60.0,
                              //color: greyColor,
                              color: Colors.grey,
                            ),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    Flexible(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Container(
                                  child: Text(
                                    snapshot.data['nick_name'],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                                ),
                                Container(
                                  child: Text(
                                    '${dateTimeFormatter.chatRoomDateTime(
                                        document.data()['lastChatTime']) ?? 'Not available'}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 8.0),
                                ),
                              ],
                            ),
                            Container(
                              child: document.data()['lastMessageType'] == 0
                                  ? Text(
                                      '${document.data()['lastMessage'] ?? 'Not available'}',
                                      style: TextStyle(color: Colors.black45),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Row(
                                      children: [
                                        Icon(Icons.image, color: Colors.black45, size: 19,),
                                        SizedBox(width: 3,),
                                        Text('이미지', style: TextStyle(color: Colors.black45, fontSize: 16)),
                                      ],
                                    ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 13.0),
                      ),
                    ),
                    unreadCounterWidget(document, peerId),
                    bikeThumbnailWidget(document.data()['bikeId']),
            ],
          ),
          onTap: () {
            var userPairFromDB = document.data()['userPair'];
            List<String> userPair = new List<String>.from(userPairFromDB);
            String peerId;
            if (userPair[0] == signCtrl.currentUser.value.uid)
              peerId = userPair[1];
            else if (userPair[1] == signCtrl.currentUser.value.uid)
              peerId = userPair[0];

            List<String> argumentList = [document.data()['bikeId'], peerId];
            Get.toNamed('/chat', arguments: argumentList);
          },
        ),
        margin: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0, top: 5.0),
      );
    }
        });
  }
}