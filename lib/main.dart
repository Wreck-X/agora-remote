import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

const appId = '36054cecfadf41d4b691234bf5db59d7';
String channelName = 'test';
String token =
    '007eJxTYDharqi4eNG1U8L7WfnDTXe4s7zdNoXrKufJbO/TmjmnDxYpMBibGZiaJKcmpyWmpJkYppgkmVkaGhmbJKWZpiSZWqaYm01MTWsIZGS437yKgREKQXwWhpLU4hIGBgAXxh9B';
int uid = 1;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: appId,
      channelName: channelName,
      tempToken: token,
      uid: uid,
    ),
    agoraChannelData: AgoraChannelData(
      channelProfileType: ChannelProfileType.channelProfileLiveBroadcasting,
      clientRoleType: ClientRoleType.clientRoleAudience,
    ),
  );
  bool _localUserJoined = false;
  int? _remoteUid = 1;
  @override
  void initState() {
    super.initState();
    initAgora();
  }

  final engine = createAgoraRtcEngine();
  void initAgora() async {
    await [Permission.microphone, Permission.camera].request();

// Initialize RtcEngine and set the channel profile to live broadcasting
    await engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await engine.joinChannel(
      token: token,
      channelId: channelName,
      options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          audienceLatencyLevel:
              AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency),
      uid: 0,
    );

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onIntraRequestReceived: (RtcConnection connection) {},
        // Occurs when the local user joins the channel successfully
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(
            () {
              _localUserJoined = true;
            },
          );
        },
        // Occurs when a remote user join the channel
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },

        // Occurs when a remote user leaves the channel
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Enable the video module
    await engine.enableVideo();
// Enable local video preview
    await engine.startPreview();
    print("donde");

// Add an event handler
  }

  //Build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(95, 138, 138, 138),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(95, 48, 48, 48),
          title: const Text('Agora Testing',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [_remoteVideo()],
          ),
        ),
      ),
    );
  }

  // Widget to display remote video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
