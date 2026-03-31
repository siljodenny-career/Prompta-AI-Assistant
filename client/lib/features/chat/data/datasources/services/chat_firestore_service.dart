import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:client/features/chat/data/datasources/models/message_model.dart';
import 'package:client/features/chat/domain/entities/message.dart';

class ChatThread {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatThread({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatThread.fromDocument(String id, Map<String, dynamic> doc) {
    return ChatThread(
      id: id,
      userId: doc['userId'] ?? '',
      title: doc['title'] ?? 'New Chat',
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (doc['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDocument() => {
        'userId': userId,
        'title': title,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}

class ChatFirestoreService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _threadsCol => _firestore.collection('chat_threads');

  CollectionReference _messagesCol(String threadId) =>
      _threadsCol.doc(threadId).collection('messages');

  /// Create a new chat thread — title starts empty, set after AI summarizes
  Future<ChatThread> createThread(String userId) async {
    final now = DateTime.now();
    final thread = ChatThread(
      id: '',
      userId: userId,
      // ✅ Empty string — will be replaced by AI summary immediately after
      title: '',
      createdAt: now,
      updatedAt: now,
    );
    final doc = await _threadsCol.add(thread.toDocument());
    return ChatThread(
      id: doc.id,
      userId: userId,
      title: thread.title,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get all threads for a user, ordered by most recent
  Stream<List<ChatThread>> getThreads(String userId) {
    return _threadsCol
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final threads = snap.docs
          .map((doc) => ChatThread.fromDocument(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      // Sort client-side to avoid needing a Firestore composite index
      threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return threads;
    });
  }

  /// Update thread title (called by _generateTitle in ChatBloc)
  Future<void> updateThreadTitle(String threadId, String title) async {
    await _threadsCol.doc(threadId).update({
      'title': title,
      'updatedAt': Timestamp.now(),
    });
  }

  /// ✅ Fallback title generator — used if AI call fails
  /// Truncates the raw user message to a clean short title
  String generateTitle(String firstMessage) {
    final cleaned = firstMessage.trim();
    if (cleaned.length <= 40) return cleaned;
    final truncated = cleaned.substring(0, 40);
    final lastSpace = truncated.lastIndexOf(' ');
    return lastSpace != -1
        ? '${truncated.substring(0, lastSpace)}…'
        : '$truncated…';
  }

  /// Delete a thread and all its messages
  Future<void> deleteThread(String threadId) async {
    final messages = await _messagesCol(threadId).get();
    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_threadsCol.doc(threadId));
    await batch.commit();
  }

  /// Add a message to a thread
  Future<void> addMessage(String threadId, Message message) async {
    await _messagesCol(threadId).add({
      'text': message.text,
      'isUser': message.isUser,
      'timestamp': Timestamp.now(),
    });
    await _threadsCol.doc(threadId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  /// Get all messages for a thread, ordered chronologically
  Future<List<Message>> getMessages(String threadId) async {
    final snap = await _messagesCol(threadId)
        .orderBy('timestamp', descending: false)
        .get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MessageModel(
        text: data['text'] ?? '',
        isUser: data['isUser'] ?? false,
      );
    }).toList();
  }

  /// Remove the last AI message (for regeneration)
  Future<void> removeLastAiMessage(String threadId) async {
    final snap = await _messagesCol(threadId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data() as Map<String, dynamic>;
      if (data['isUser'] == false) {
        await snap.docs.first.reference.delete();
      }
    }
  }
}