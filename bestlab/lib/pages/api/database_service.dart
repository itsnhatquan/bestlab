import 'package:mongo_dart/mongo_dart.dart';

class DatabaseService {
  final String _mongoUri = 'mongodb+srv://nguyenducdai:0Obkv5QtElG92eNp@bestlab-prod-1.foxbvln.mongodb.net/Authentication?retryWrites=true&w=majority&appName=BESTLAB-PROD-1';
  final String _collectionName = 'devices';
  
  Db? _db;
  DbCollection? _collection;

  Future<void> connect() async {
    _db = await Db.create(_mongoUri);
    await _db!.open();
    _collection = _db!.collection(_collectionName);
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    return await _collection!.find().toList();
  }

  Future<void> close() async {
    await _db!.close();
  }
}

