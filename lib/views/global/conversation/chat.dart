import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String otherUserId;

  const ChatPage({super.key, required this.userId, required this.otherUserId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String? _currentDateHeader;

  @override
  bool get wantKeepAlive => true;
  final TextEditingController _messageController = TextEditingController();
  String? _chatId;
  DocumentSnapshot? _otherUser;
  final ImagePicker _picker = ImagePicker();
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  String? _audioFilePath;

  String? _currentlyPlayingMessageId;
  double _audioProgress = 0.0;
  Duration _audioDuration = Duration.zero;

  List<DocumentSnapshot> messages = [];
  List<GlobalKey> messageKeys = [];

  @override
  void initState() {
    super.initState();
    _checkOrCreateChat();
    _fetchOtherUserDetails();
    _initializeRecorder();
    _initializePlayer();
    _scrollController.addListener(_onScroll);
    // Add a listener to the text controller
    _messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    setState(() {}); // Rebuilds the widget to show the send button when text is entered
    _updateTypingStatus(_messageController.text.isNotEmpty);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      // Calcule la position du premier message visible
      double scrollOffset = _scrollController.offset;

      double itemHeight = 80; // Hauteur approximative de chaque message (à ajuster selon votre layout)

      int firstVisibleIndex = (scrollOffset / itemHeight).floor();
      if (firstVisibleIndex >= 0 && firstVisibleIndex < messages.length) {
        setState(() {
          _currentDateHeader = _formatDateForHeader(messages[firstVisibleIndex]['timestamp'].toDate());
        });
      }
    }
  }

  // Formate la date pour l'en-tête (Aujourd'hui, Hier, etc.)
  String _formatDateForHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (DateFormat.yMd().format(date) == DateFormat.yMd().format(now)) {
      return "Aujourd'hui";
    } else if (DateFormat.yMd().format(date) == DateFormat.yMd().format(yesterday)) {
      return "Hier";
    } else {
      return DateFormat('d MMMM').format(date); // Par exemple, "4 août"
    }
  }

  void _updateTypingStatus(bool isTyping) {
    if (_chatId != null) {
      configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').doc(_chatId).update({
        'is_typing': isTyping, // Mettre à jour le statut de l'utilisateur actuel
      });
    }
  }

  void _checkOrCreateChat() async {
    QuerySnapshot querySnapshot = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').where('participants', arrayContains: widget.userId).get();

    DocumentSnapshot? existingChat;

    for (var doc in querySnapshot.docs) {
      List participants = doc['participants'];
      if (participants.contains(widget.otherUserId)) {
        existingChat = doc;
        break;
      }
    }

    if (existingChat != null) {
      setState(() {
        _chatId = existingChat!.id;
      });
    } else {
      DocumentReference newChat = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').add({
        'participants': [widget.userId, widget.otherUserId],
        'created_at': FieldValue.serverTimestamp(),
        'is_typing': false,
        'is_recording': false,
      });

      setState(() {
        _chatId = newChat.id;
      });
    }
  }

  void _fetchOtherUserDetails() async {
    DocumentSnapshot userDoc = await configuration.getCollectionPath('users').doc(widget.otherUserId).get();

    setState(() {
      _otherUser = userDoc;
    });
  }

  void _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder!.openRecorder();

    if (Platform.isIOS) {
      // Important: Set the audio session category and options for iOS
      await _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
    }
  }

  void _initializePlayer() async {
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
  }

  void _sendMessage({String? text, String? imageUrl, String? audioUrl, String? fileUrl}) async {
    if ((text != null && text.isNotEmpty) || imageUrl != null || audioUrl != null) {
      final messageData = {'text': text ?? '', 'file_url': fileUrl ?? '', 'image_url': imageUrl ?? '', 'audio_url': audioUrl ?? '', 'sender': widget.userId, 'timestamp': FieldValue.serverTimestamp(), 'status': 'sent'};

      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').doc(_chatId).collection('messages').add(messageData);

      // Send notification to the recipient (otherUserId)
      await _sendNotificationToRecipient(recipientId: widget.otherUserId, message: text ?? 'You have received a new message.');

      _messageController.clear();
    }
  }

  Future<void> _sendNotificationToRecipient({required String recipientId, required String message}) async {
    // Here we call the notification controller to send a notification
    await context.read<NotificationController>().addUserNotification(
      userId: recipientId, // The user receiving the message
      title: 'Nouveau message',
      body: message,
      type: 'chat',
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance.ref().child('chats/$_chatId/images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _sendMessage(imageUrl: downloadUrl);
    }
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    _audioFilePath = '${tempDir.path}/flutter_sound.aac';

    await _recorder!.startRecorder(toFile: _audioFilePath);

    setState(() {
      _isRecording = true;
    });

    if (_chatId != null) {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').doc(_chatId).update({'isRecording': true});
    }
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (_chatId != null) {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').doc(_chatId).update({'isRecording': false});
    }

    if (_audioFilePath != null) {
      final storageRef = FirebaseStorage.instance.ref().child('chats/$_chatId/audios/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(File(_audioFilePath!));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _sendMessage(audioUrl: downloadUrl);
    }
  }

  void _markMessagesAsSeen(List<DocumentSnapshot> messages) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var message in messages) {
      if (message['sender'] != widget.userId && message['status'] == 'sent') {
        DocumentReference messageRef = message.reference;
        batch.update(messageRef, {'status': 'seen'});
      }
    }

    await batch.commit();
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    return dateTime.hour == now.hour && dateTime.minute == now.minute ? 'Maintenant' : DateFormat('HH:mm').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _recorder!.closeRecorder();
    _recorder = null;
    _player!.closePlayer();
    _player = null;
    super.dispose();
  }

  void playAudio(String url, String messageId) async {
    if (_currentlyPlayingMessageId == messageId) {
      // Stop the currently playing audio
      await _player!.stopPlayer();
      setState(() {
        _currentlyPlayingMessageId = null;
        _audioProgress = 0.0;
        _audioDuration = Duration.zero;
      });
    } else {
      // Stop any other audio that might be playing
      if (_currentlyPlayingMessageId != null) {
        await _player!.stopPlayer();
      }

      // Start playing new audio
      await _player!.startPlayer(
        fromURI: url,
        whenFinished: () {
          setState(() {
            _currentlyPlayingMessageId = null;
            _audioProgress = 0.0;
            _audioDuration = Duration.zero;
          });
        },
      );

      // Start monitoring progress
      _startMonitoringAudioProgress();

      setState(() {
        _currentlyPlayingMessageId = messageId;
      });
    }
  }

  void _startMonitoringAudioProgress() {
    // Stop any existing timer
    _audioProgressTimer?.cancel();

    // Create a new timer to update the progress
    _audioProgressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      var progressData = await _player!.getProgress();

      setState(() {
        _audioProgress = progressData['progress']!.inMilliseconds / progressData['duration']!.inMilliseconds;
        _audioDuration = progressData['duration']!;
      });

      if (_audioProgress >= 1.0) {
        _stopMonitoringAudioProgress();
      }
    });
  }

  void _stopMonitoringAudioProgress() {
    _audioProgressTimer?.cancel();
    _audioProgressTimer = null;
  }

  Timer? _audioProgressTimer;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        title:
            _otherUser == null
                ? const Text('Conversation', style: TextStyle(color: kBlack, fontSize: 20, fontWeight: FontWeight.w500))
                : Row(
                  children: [
                    CircleAvatar(radius: 16, backgroundImage: _otherUser!['image_url'] == "" ? null : CachedNetworkImageProvider(_otherUser!['image_url']), backgroundColor: kLightGrey, child: _otherUser!['image_url'] == "" ? const Icon(Icons.person, color: kWhite, size: 16) : null),
                    const SizedBox(width: 10),
                    Text(_otherUser!['name'], style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
        centerTitle: true,
        leadingWidth: 75,
        leading: Padding(padding: const EdgeInsets.only(left: 16.0), child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack)]))),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      body:
          _chatId == null
              ? const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)) // Show a loader while checking/creating chat
              : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').doc(_chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
                            }

                            messages = snapshot.data!.docs;
                            String? lastMessageDate;
                            _markMessagesAsSeen(messages);

                            return ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                if (messageKeys.length <= index) {
                                  messageKeys.add(GlobalKey());
                                }
                                var message = messages[index];
                                var timestamp = _formatTimestamp(message['timestamp']); // Format the timestamp

                                var messageDate = _formatDateForHeader(message['timestamp'].toDate());

                                if (lastMessageDate == null || lastMessageDate != messageDate) {
                                  lastMessageDate = messageDate;
                                }
                                return Column(
                                  crossAxisAlignment: message['sender'] == widget.userId ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only()),
                                      title: Align(
                                        alignment: message['sender'] == widget.userId ? Alignment.centerRight : Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(16),
                                              topRight: const Radius.circular(16),
                                              bottomLeft: message['sender'] == widget.userId ? const Radius.circular(16) : Radius.zero,
                                              bottomRight: message['sender'] == widget.userId ? Radius.zero : const Radius.circular(16),
                                            ),
                                            color: message['sender'] == widget.userId ? Colors.green[300] : kWhite,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              _buildMessageContent(message),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                                child:
                                                    message['sender'] == widget.userId
                                                        ? RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: '$timestamp - ', // Common part before the status
                                                                style: TextStyle(fontSize: 10, color: message['sender'] == widget.userId ? kWhite.withValues(alpha: 0.4) : kBlack.withValues(alpha: 0.4)), // Style for the timestamp and common text
                                                              ),
                                                              TextSpan(
                                                                text: message['status'] == 'sent' ? 'Envoyé' : 'Vu', // Status part
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: message['status'] == 'sent' ? Colors.white.withValues(alpha: 0.4) : kPrimary, // "Vu" is in kPrimary, "Envoyé" in black54
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                        : RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: '$timestamp ', // Common part before the status
                                                                style: TextStyle(fontSize: 10, color: message['sender'] == widget.userId ? kWhite.withValues(alpha: 0.4) : kBlack.withValues(alpha: 0.4)), // Style for the timestamp and common text
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        if (_currentDateHeader != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: MediaQuery.of(context).size.width * 0.35),
                              padding: const EdgeInsets.all(8),
                              width: 100,
                              decoration: const BoxDecoration(color: kWhite, borderRadius: BorderRadius.all(Radius.circular(999))),
                              child: Center(child: Text(_currentDateHeader!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kGrey))),
                            ),
                          ),
                      ],
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: configuration.getCollectionPath('events').doc(Event.instance.id).collection('chats').doc(_chatId).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Object? chatData = snapshot.data!.data();

                        bool isOtherUserTyping = (chatData as Map<String, dynamic>)['is_typing'] == true;
                        bool isOtherUserRecording = chatData['is_recording'] == true;

                        if (!isOtherUserTyping && !isOtherUserRecording) {
                          return const SizedBox.shrink(); // No need to show anything if neither is true
                        }

                        return FadeTransition(
                          opacity: const AlwaysStoppedAnimation(1.0), // Ensure smooth transition for visibility
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              decoration: BoxDecoration(color: Colors.blueGrey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  if (isOtherUserTyping)
                                    Row(children: [const Icon(Icons.edit, color: Colors.blueAccent, size: 18), const SizedBox(width: 8), Text("${_otherUser!['name']} est en train d'écrire...", style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400))]),
                                  if (isOtherUserRecording)
                                    Row(
                                      children: [
                                        const Icon(Icons.mic, color: Colors.redAccent, size: 18),
                                        const SizedBox(width: 8),
                                        Text("${_otherUser!['name']} enregistre un audio...", overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return Container(); // Return an empty container if there's no data
                    },
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 6.0, bottom: Platform.isIOS ? 26.0 : 6.0, right: 10.0, left: 10.0),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: kBlack.withValues(alpha: 0.1))), color: kWhite),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // "+" Button with options for photos, camera, documents
                        GestureDetector(onTap: () => _showAttachmentOptions(context), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: Icon(Icons.add, color: kBlack))),
                        const SizedBox(width: 8),

                        // Text Input Field
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                            decoration: BoxDecoration(color: kLightGrey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    textInputAction: TextInputAction.send,
                                    controller: _messageController,
                                    maxLines: 1,
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.zero, border: InputBorder.none, isDense: true, hintStyle: TextStyle(color: kGrey, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Conditionally display send button or camera and mic buttons
                        _messageController.text.isNotEmpty
                            ? GestureDetector(
                              onTap: () => _sendMessage(text: _messageController.text),
                              child: const Icon(Icons.send, color: kPrimary), // Send button
                            )
                            : Row(
                              children: [
                                // Camera Button
                                GestureDetector(onTap: _pickImageFromCamera, child: const Icon(Icons.camera_alt_outlined, color: kBlack)),
                                const SizedBox(width: 8),
                                // Microphone Button
                                GestureDetector(onTap: _isRecording ? _stopRecording : _startRecording, child: Icon(_isRecording ? Icons.mic : Icons.mic_none_outlined, color: _isRecording ? Colors.red : kBlack)),
                              ],
                            ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildMessageContent(DocumentSnapshot message) {
    if (message['image_url'] != null && message['image_url'].isNotEmpty) {
      // Image message
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImage(imageUrl: message['image_url'], tag: message.id)));
        },
        child: Hero(
          tag: message.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: message['image_url'],
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(), // Placeholder while loading
              errorWidget: (context, url, error) => const Icon(Icons.error), // Widget displayed on error
              cacheKey: message.id,
            ),
          ),
        ),
      );
    } else if (message['audio_url'] != null && message['audio_url'].isNotEmpty) {
      // Audio message
      return Padding(padding: const EdgeInsets.all(8.0), child: _buildAudioMessage(message));
    } else if (message['file_url'] != null && message['file_url'].isNotEmpty) {
      // File message
      return GestureDetector(
        onTap: () => _downloadFile(message['file_url'], 'document_${DateTime.now().millisecondsSinceEpoch}.pdf'),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(color: message['sender'] == widget.userId ? Colors.green[500] : kLightGrey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file, size: 24, color: kWhite),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message['text'], // Placeholder for document name
                  style: TextStyle(color: message['sender'] == widget.userId ? kWhite : kBlack, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.download_rounded, color: message['sender'] == widget.userId ? kWhite : kPrimary),
            ],
          ),
        ),
      );
    } else {
      // Text message
      return Padding(padding: const EdgeInsets.all(4.0), child: Text(message['text'], style: TextStyle(color: message['sender'] == widget.userId ? kWhite : kBlack, fontSize: 14)));
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(); // Function to pick image from gallery
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera(); // Function to pick image from camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Documents'),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument(); // Function to pick document
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance.ref().child('chats/$_chatId/images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _sendMessage(imageUrl: downloadUrl);
    }
  }

  Future<void> _pickDocument() async {
    final pickedFile = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx']);
    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance.ref().child('chats/$_chatId/documents/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(File(pickedFile.files.single.path!));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _sendMessage(text: pickedFile.files.single.name, fileUrl: downloadUrl);
    }
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      final dir = await getExternalStorageDirectory();
      String filePath = '${dir!.path}/$fileName';

      Dio dio = Dio();
      await dio.download(url, filePath);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File downloaded to $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
    }
  }

  Widget _buildAudioMessage(DocumentSnapshot message) {
    return GestureDetector(
      onTap: () => playAudio(message['audio_url'], message.id),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_currentlyPlayingMessageId == message.id ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 24, color: message['sender'] == widget.userId ? kWhite : Colors.green[200]),
          const SizedBox(width: 8),
          SizedBox(
            width: 160,
            child: Stack(
              children: [
                Container(height: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12))),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFakeWaveform(message['sender'] == widget.userId ? kWhite : kBlack, _currentlyPlayingMessageId == message.id ? _audioProgress : 0.0),
                      Text(_currentlyPlayingMessageId == message.id ? _formatDuration(_audioDuration) : '00:00', style: TextStyle(color: message['sender'] == widget.userId ? kWhite : kBlack, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeWaveform(Color color, double progress) {
    // This simulates a waveform. You can customize the number of bars and colors.
    int totalBars = 29;
    int activeBars = (totalBars * progress).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(totalBars, (index) {
        return Container(width: 2, height: index % 2 == 0 ? 8 : 16 + index % 3 * 4, margin: const EdgeInsets.symmetric(horizontal: 1.0), decoration: BoxDecoration(color: index < activeBars ? kPrimary : color, borderRadius: BorderRadius.circular(2)));
      }),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String tag; // Hero tag for smooth transition

  const FullScreenImage({super.key, required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop())),
      body: InteractiveViewer(
        minScale: 0.5, // Minimum zoom level
        maxScale: 3.0, // Maximum zoom level
        child: Center(child: Hero(tag: tag, child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain))),
      ),
    );
  }
}
