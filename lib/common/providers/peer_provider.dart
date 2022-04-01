import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ffi';
import 'dart:async';

import 'package:charmev/common/models/detail.dart';
import 'package:charmev/common/utils/pref_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:charmev/common/models/enum.dart';

import 'package:charmev/common/services/fr_bridge/bridge_generated.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:charmev/config/env.dart';
import 'package:peaq_network_ev_charging_message_format/did_document_format.pb.dart'
    as doc;
import 'package:peaq_network_ev_charging_message_format/p2p_message_format.pb.dart'
    as msg;

const base = 'peaq_codec_api';
final path = Platform.isWindows
    ? '$base.dll'
    : Platform.isMacOS
        ? 'lib$base.dylib'
        : 'lib$base.so';
late final dylib =
    Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(path);

late final api = PeaqCodecApiImpl(dylib);

void runPeriodically(void Function() callback) =>
    Timer.periodic(const Duration(milliseconds: 3000), (timer) => callback());

class CEVPeerProvider with ChangeNotifier {
  CEVPeerProvider({
    required this.cevSharedPref,
  });

  final CEVSharedPref cevSharedPref;

  late CEVApplicationProvider appProvider;

  static CEVPeerProvider of(BuildContext context) {
    return provider.Provider.of<CEVPeerProvider>(context);
  }

  LoadingStatus _status = LoadingStatus.idle;
  String _error = '';
  String _statusMessage = '';
  bool _isLoggedIn = false;
  bool _showNodeDropdown = false;
  List<Detail> _details = [];

  String _identityChallengeData = '';
  String _p2pURL = '';
  bool _isPeerDidDocVerified = false;
  bool _isPeerAuthenticated = false;
  bool _isPeerConnected = false;
  bool _isPeerSubscribed = false;
  doc.Document _providerDidDoc = doc.Document();

  bool get isPeerDidDocVerified => _isPeerDidDocVerified;
  bool get isPeerAuthenticated => _isPeerAuthenticated;
  bool get isPeerConnected => _isPeerConnected;
  bool get isPeerSubscribed => _isPeerSubscribed;

  Future<void> initLog() async {
    api.initLogger();
  }

  Future<void> connectP2P() async {
    // validate p2p URL
    var splitURL = _p2pURL.trim().split("/");

    if (splitURL.length != 7) {
      appProvider.chargeProvider
          .setStatus(LoadingStatus.error, message: "Invalid P2P URL found");
    }

    api.connectP2P(url: _p2pURL);
    runPeriodically(getEvent);
  }

  Future<void> getEvent() async {
    print("getEvent hitts");

    var data = await api.getEvent();

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    print("getEvent EVENT decodedRes $decodedRes");

    if (!decodedRes["error"]) {
      // decode event data
      List<int> docRawData = List<int>.from(decodedRes["data"]);
      String docCharCode = String.fromCharCodes(docRawData);
      var docOutputAsUint8List = Uint8List.fromList(docCharCode.codeUnits);

      var ev = msg.Event();
      ev.mergeFromBuffer(docOutputAsUint8List);
      print("getEvent EVENT ev $ev");

      switch (ev.eventId) {
        case msg.EventType.PEER_CONNECTED:
          {
            _isPeerConnected = true;
            break;
          }
        case msg.EventType.PEER_CONNECTION_FAILED:
          {
            _isPeerConnected = false;
            appProvider.chargeProvider.setStatus(LoadingStatus.error,
                message:
                    "Unable to Connect to Provider Peer. Please check the p2p URL on DID document is correct.");
            break;
          }
        case msg.EventType.PEER_SUBSCRIBED:
          {
            _isPeerSubscribed = true;
            // Authenticate peer is it's connected and subscribed
            if (_isPeerConnected) {
              appProvider.chargeProvider.setStatus(LoadingStatus.loading,
                  message: Env.authenticatingProvider);
              // send identity challenge to peer for verification
              _sendIdentityChallengeEvent();
            }
            break;
          }
        case msg.EventType.IDENTITY_RESPONSE:
          {
            _authenticatePeer(ev.identityResponseData);
            break;
          }
        default:
          {}
      }
    }
  }

  verifyPeerDidDocument() async {
    print("verifyPeerDidDocument hitts");

    var sig = _providerDidDoc.signature.writeToBuffer();
    var providerPK = _providerDidDoc.id.split(":")[2];

    var data =
        await api.verifyPeerDidDocument(providerPk: providerPK, signature: sig);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    if (!decodedRes["error"]) {
      _isPeerDidDocVerified = true;
      notifyListeners();
    }
  }

  _verifyPeerIdentity(
      String providerPK, String plainData, doc.Signature signature) async {
    print("verifyPeerIdentity hitts");

    var sig = signature.writeToBuffer();

    var data = await api.verifyPeerIdentity(
        providerPk: providerPK, plainData: plainData, signature: sig);

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);
    print("verifyPeerIdentity decodedRes:: $decodedRes");

    if (!decodedRes["error"]) {
      _isPeerAuthenticated = true;
      notifyListeners();
    }
  }

  _authenticatePeer(msg.IdentityResponseData data) async {
    for (var i = 0; i < _providerDidDoc.verificationMethods.length; i++) {
      var vm = _providerDidDoc.verificationMethods[i];

      var signature = doc.Signature(
          type: vm.type, issuer: vm.controller, hash: data.signature);

      await _verifyPeerIdentity(vm.id, _identityChallengeData, signature);
    }

    if (_isPeerAuthenticated) {
      await appProvider.chargeProvider.generateAndFundMultisigWallet();
      // await appProvider.accountProvider
      //     .simulateServiceRequestedAndDeliveredEvents();
    } else {
      appProvider.chargeProvider.setStatus(LoadingStatus.error,
          message: "Unable to Authenticate Prover Peer...");
    }
  }

  Future<void> _sendIdentityChallengeEvent() async {
    print("sendIdentityChallengeEvent hitts");
    var data = await api.sendIdentityChallengeEvent();

    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);

    // decode did document data
    List<int> docRawData = List<int>.from(decodedRes["data"]);
    String docCharCode = String.fromCharCodes(docRawData);

    _identityChallengeData = docCharCode;
    print("RANDOM DATA:: $_identityChallengeData");

    return;
  }

  Future<doc.Document> fetchDidDocument(String publicKey) async {
    var data = await api.fetchDidDocument(
        wsUrl: Env.peaqTestnet,
        publicKey: publicKey,
        storageName: Env.didDocAttributeName);

    String s = String.fromCharCodes(data);
    var utf8Res = utf8.decode(data);
    var decodedRes = json.decode(utf8Res);
    var didDoc = doc.Document();

    if (!decodedRes["error"]) {
      // decode did document data
      List<int> docRawData = List<int>.from(decodedRes["data"]);
      String docCharCode = String.fromCharCodes(docRawData);
      var docOutputAsUint8List = Uint8List.fromList(docCharCode.codeUnits);

      didDoc.mergeFromBuffer(docOutputAsUint8List);

      _providerDidDoc = didDoc;
      _setP2PURL(didDoc.services);
      notifyListeners();
    }
    return didDoc;
  }

  _setP2PURL(List<doc.Service> services) {
    for (var i = 0; i < services.length; i++) {
      var service = services[i];

      if (service.type == doc.ServiceType.p2p) {
        _p2pURL = service.stringData;
        break;
      }
    }
  }
}