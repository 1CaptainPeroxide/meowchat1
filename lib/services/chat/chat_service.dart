import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trexplore/models/message.dart';

class ChatService {

      //get instance  of firestore
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final FirebaseAuth _auth = FirebaseAuth.instance;


      //get user stream
      Stream<List<Map<String, dynamic>>> getUsersStream() {
        return _firestore.collection("Users").snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final user = doc.data();
          return user;
        }).toList();
      });
      }

      Future<void> sendMessage(String receiverID, message ) async {
        
        //get user current info
        final String currentUserID = _auth.currentUser!.uid;
        final String currentUserEmail = _auth.currentUser!.email!;
        final Timestamp timestamp = Timestamp.now();


        // create new message 
        Message newMessage = Message(
          senderID: currentUserID , 
          senderEmail: currentUserEmail, 
          receiverID: receiverID, 
          message: message, 
          timestamp: timestamp);

        //construct chat room for the two users
        List<String> ids = [currentUserID, receiverID];
        ids.sort();
        String chatRoomID = ids.join('_');

        

        //add new message to database
        await _firestore.collection("chat_rooms").doc(chatRoomID).collection("messages").add(newMessage.toMap());


      }

      //get messages
      Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
        //chat room id
        List<String> ids = [userID, otherUserID];
        ids.sort();
        String chatRoomID = ids.join('_');

        return _firestore.collection("chat_rooms").doc(chatRoomID).collection("messages").orderBy("timestamp", descending: false).snapshots();

      }

}