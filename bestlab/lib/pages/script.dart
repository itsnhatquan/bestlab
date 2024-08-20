import 'package:mongo_dart/mongo_dart.dart' as mongo;

// void main() async {
//   var db = await mongo.Db.create('mongodb+srv://nguyenducdai:0Obkv5QtElG92eNp@bestlab-prod-1.foxbvln.mongodb.net/?retryWrites=true&w=majority&appName=BESTLAB-PROD-1');
//   await db.open();
//   print('Connected to the database');
//   var collection = db.collection('userAuth');
//   var user = await collection.findOne({'username': 'tester'});
//   print(user);
//   await db.close();
// }
void main() async {
  const mongoUrl = 'mongodb+srv://nguyenducdai:0Obkv5QtElG92eNp@bestlab-prod-1.foxbvln.mongodb.net/Authentication?retryWrites=true&w=majority&appName=BESTLAB-PROD-1';
  const dbName = 'Authentication';

  try {
    // Connect to the MongoDB database
    var db = await mongo.Db.create(mongoUrl);
    await db.open();
    print('Connected to the database');

    // Access the 'userAuth' collection
    var collection = db.collection('userAuth');

    // Retrieve all documents from the 'userAuth' collection
    var users = await collection.find().toList();

    // Print each document
    if (users.isEmpty) {
      print('No documents found in the collection userAuth.');
    } else {
      print('Documents in collection userAuth:');
      for (var user in users) {
        print(user);
      }
    }

    // Close the database connection
    await db.close();
  } catch (e) {
    print('Error: $e');
  }
}