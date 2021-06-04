import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final _store = FirebaseFirestore.instance;
User loggedInUser; // to check on current user


class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;
  final textFieldController = TextEditingController();

  String text;

  void getUser() {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        // to store user info in current file
        print(loggedInUser);
      }
    } catch (e) {
      print(e);
    }
  }
//  void getMessages()async{
//    try {
//     final messages = await _store.collection('messages').get();
//     for(var userMessage in messages.docs){
//       print(userMessage.data());
//     }
//    }
//    catch(e){
//      print(e);
//    }
//  }

//  void getMessageStreams() async {
//    await for (var snapshot in _store.collection('messages').snapshots()) {
//      for (var messages in snapshot.docs) {
//        print(messages.data());
//      }
//    }
//  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
//                getMessageStreams();
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageBuilder(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textFieldController,
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        text = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      // message and the sender
                      textFieldController.clear();
                      try {
                        _store.collection('messages').add({
                          'sender': loggedInUser.email,
                          'text': text,
                        });
                      } catch (e) {
                        print(e);
                      }

                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //snapshots gives us a stream we need a widget that handle the stream and give list of text widget which will update every time user sends the messages we wil do this by a stream builder
// stream builder will take the snapshot and give back a widget
    return   StreamBuilder<QuerySnapshot>(
      //stream is of Query snapshots
      stream: _store
          .collection('messages')
          .snapshots(), // this is a stream of query snapshot (in this it will contain stream of chat messages

      builder: //for the builder we need to provide the logic what the stream builder should actually do
          (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } // if the snapshot has no data
        //the snapshot has the asynchronous access of the data
        final messages = snapshot.data.docs.reversed;

//the snapshot is asnyc,now it has data which is query snapshot which in turn has list of documents from database
        //messages is now a list of with text and sender.
        //We need a list of text widget to display the sender and the message.
        List<Widget> messageWidgets = [];
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final messageWidget = MessageBubble(
            messageSender: messageSender,
            messageText: messageText,
            isMe: loggedInUser.email==messageSender,
          );

          messageWidgets.add(messageWidget);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            // to be able to scroll
            padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.messageText, this.messageSender,this.isMe});

  final String messageText;
  final String messageSender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(messageSender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
              elevation: 5.0,
              borderRadius: isMe?BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)):BorderRadius.only(bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0),topRight: Radius.circular(30.0)),

               color: isMe?Colors.lightBlueAccent:Colors.white,

              child: Padding(
                padding:  EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
                child: Text(messageText,
                  style: TextStyle(
                      fontSize: 15.0,
                      color: isMe?Colors.white:Colors.black54,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
