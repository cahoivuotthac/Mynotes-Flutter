import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:freecodecamp/services/crud/crud_exceptions.dart';
import 'package:path/path.dart'
    show join; //join: to join the path of the database file
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const idColumn = 'id'; //text inside '' is the name of row in db browser
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const dbName = 'notes.db';
const noteTable = 'notes';
const userTable = 'users';
const createUserTable =
    '''CREATE TABLE IF NOT EXISTS"users" ( //make sure that usertable does not exist
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      )''';
const createNoteTable = '''CREATE TABLE "notes" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "notes"("id")
      );
      ''';

class NotesService {
  Database? _db; //create a private variable to store the database

  //! SINGLETON
  static final NotesService _share = NotesService._sharedInstance();
  NotesService._sharedInstance(); //_sharedInstance is just a function name
  factory NotesService() => _share;

  //get the database (read only)
  Database _getDatabaseOrThrow() {
    //is marked as private to indicate that it should not be accessed or called from outside the class
    //this is private function
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseIsNotOpenException {
      //empty
    }
  }

  //to fetch user from database
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      //opposite to createUser function
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    //to make sure that the email does not exist in the database
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    //insert the user into the database
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      //If the deleteCount variable is not equal to 1, it means that either no rows were deleted
      throw CouldNotDeleteUserException();
    }
  }

  List<DatabaseNote> _notes =
      []; //to store the notes in memory, cannot read from the outside

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    // the purpose of this function is to make 100% sure that the user exists in the database
    try {
      await _ensureDbIsOpen();
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException {
      //if the user does not exist, then create a new one
      final createWithEmail = await createUser(email: email);
      return createWithEmail;
    } catch (e) {
      //to catch any other exception
      rethrow; //to allow you to put a breakpoint to debug your app later if you want
    }
  }

  Future<void> _cacheNotes() async {
    //to cache all notes from the database into memory
    final allNotes =
        await getAllNotes(); // to retrieve all notes from the database
    _notes = allNotes.toList();
    _noteStreamController.add(_notes);
  }

  final _noteStreamController =
      StreamController< // notes can be read from the outside through this
          List<
              DatabaseNote>>.broadcast(); //broadcast: to allow multiple listeners

  Stream<List<DatabaseNote>> get allNotes => _noteStreamController
      .stream; // returns the stream of notes managed by the _noteStreamController
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(
        id: note.id); //to make sure that the note exists in the database

    final updatesCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updateNotes = await getNote(id: note.id);
      _notes.removeWhere((note) =>
          note.id ==
          updateNotes
              .id); //to remove the note (in cache) with the same id with the updated one (in databse) => in order to add the updated one to the cache
      _notes.add(updateNotes);
      _noteStreamController.add(_notes);
      return updateNotes;
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    //id here is of the note not the user
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNoteFindNoteException();
    } else {
      //return DatabaseNote.fromRow(notes.first); this code doesn't make sure that the notes in cache are updated
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) =>
          note.id == id); //to remove this old note which have this id in cache
      _notes.add(note); //then add the new update of this note to the cache
      _noteStreamController.add(_notes);
      return note;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      //why we need to do like this?
      //because DatabaseUser is just a class, so you can create another db and then fake the email (which you know this exsits in the real database)
      //so you need to make sure that the email is actually in the database
      throw CouldNotFindUserException();
    }

    const text = '';
    //create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: 1,
    );

    _notes.add(note);
    _noteStreamController
        .add(_notes); //tp refeclt the values inside _notes to the outside world
    return note;
  }

  //deleta note
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _noteStreamController.add(_notes);
    }
  }

  //delete all notes
  Future<int> deleteAllNotes({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _noteStreamController.add(_notes);
    return numberOfDeletions;
  }

  //open the database
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create the user table
      await db.execute(createUserTable);

      //create the note table
      await db.execute(createNoteTable);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  //close the database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(
      //named constructor
      Map<String, Object?> map)
      : id = map[idColumn] as int, //idColumn is the key
        email = map[emailColumn] as String;

  @override
  String toString() =>
      'Person, ID = $id, email = $email'; //to print the user that is easier to read

  @override
  bool operator ==(covariant DatabaseUser other) =>
      id == other.id; //to check if two users have the same id in database

  @override
  int get hashCode =>
      id.hashCode; // to quickly determine if two objects are equal
}

class DatabaseNote {
  final int id, userId;
  final String text;
  final int isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(
      //named constructor
      Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? 1 : 0;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
