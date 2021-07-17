import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullPhoto extends StatefulWidget {
  final String currentUrl;
  final String groupChatId;

  FullPhoto({Key key, @required this.currentUrl, @required this.groupChatId}) : super(key: key);

  @override
  State createState() => FullPhotoState(currentUrl: currentUrl, groupChatId: groupChatId);
}

class FullPhotoState extends State<FullPhoto> {
  final String currentUrl;
  final groupChatId;

  FullPhotoState({Key key, @required this.currentUrl, @required this.groupChatId});

  int firstPage = 2;
  PageController _pageController;
  List<String> imageUrlList=[];

  @override
  void initState() {
    //_pageController = PageController(initialPage: firstPage);
    //fetchImageList();
    super.initState();
  }

  Future<List<String>> fetchImageList() async {
    List<String> _imageUrlList=[];
    var snap = await FirebaseFirestore.instance
        .collection('chats')
        .doc(groupChatId)
        .collection(groupChatId)
        .where('type', isEqualTo: 1)
        .get();

    for(var i = 0 ; i < snap.docs.length ; i++){
      _imageUrlList.add(snap.docs[i].data()['content']);
    }

    imageUrlList = List.from(_imageUrlList.reversed);

    _pageController = PageController(initialPage: imageUrlList.indexOf(currentUrl));

    return imageUrlList;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchImageList(),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if(!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(),
            //Text("loading", style: TextStyle(color: Colors.white),)//
          );
        else {
          return Container(
          child: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(snapshot.data[index]),
                initialScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 1.5,
                // heroAttributes:
                //     PhotoViewHeroAttributes(tag: galleryItems[index].id),
              );
            },
            itemCount: snapshot.data.length,

            loadingBuilder: (context, event) => Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                ),
              ),
            ),
            // backgroundDecoration: widget.backgroundDecoration,
             pageController: _pageController,
            // onPageChanged: onPageChanged,
          ),
        );}
      }
    );
  }
}