import 'package:charmev/common/models/enum.dart';
import 'package:charmev/common/providers/account_provider.dart';
import 'package:charmev/common/providers/charge_provider.dart';
import 'package:charmev/common/widgets/buttons.dart';
import 'package:charmev/common/widgets/custom_shapes.dart';
import 'package:charmev/common/widgets/dropdown.dart';
import 'package:charmev/common/widgets/loading_view.dart';
import 'package:charmev/common/widgets/status_card.dart';
import 'package:charmev/config/app.dart';
import 'package:charmev/config/env.dart';
import 'package:charmev/config/routes.dart';
import 'package:charmev/theme.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.page, Key? key}) : super(key: key);

  final int? page;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String qrcode = 'Unknown';

  CEVChargeProvider? _dumbChargeProvider;

  @override
  void initState() {
    super.initState();
    _dumbChargeProvider =
        provider.Provider.of<CEVChargeProvider>(context, listen: false);
    _dumbChargeProvider!.qrController.resume();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Material(color: Colors.white, child: _buildMain(context)));
  }

  Widget _buildMain(BuildContext context) {
    CEVChargeProvider chargeProvider = CEVChargeProvider.of(context);
    return provider.Consumer<CEVAccountProvider>(
        builder: (context, accountProvider, _) {
      return SafeArea(
          child: Stack(children: <Widget>[
        // _backgroundImage,
        Scaffold(
            backgroundColor: CEVTheme.bgColor,
            appBar: AppBar(
              title: _buildAppBarTitle(context, accountProvider),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: CEVTheme.appBarBgColor,
              iconTheme: const IconThemeData(color: CEVTheme.textFadeColor),
              actions: [
                IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      // qrController.pause();
                      accountProvider.getAccountBalance();
                      CEVApp.router.navigateTo(context, CEVRoutes.account,
                          transition: TransitionType.inFromRight);
                    })
              ],
            ),
            body: GestureDetector(
              onTap: () => {},
              child: _buildScreen(context),
            )),
        Visibility(
          visible: accountProvider.showNodeDropdown,
          child: CEVDropDown(
              items: accountProvider.nodes,
              borderColor: CEVTheme.accentColor,
              onTap: (String item) {
                accountProvider.showNodeDropdown =
                    !accountProvider.showNodeDropdown;
                accountProvider.selectedNode = item;
              }),
        ),
        Visibility(
            visible: (chargeProvider.status != LoadingStatus.idle &&
                chargeProvider.status != LoadingStatus.success),
            child: CEVLoadingView(
              status: chargeProvider.status,
              loadingContent: CEVStatusCard(
                  text:
                      "${chargeProvider.providerDid} \n\n ${Env.fetchingData}",
                  status: LoadingStatus.loading),
              errorContent: CEVStatusCard(
                  text:
                      "${chargeProvider.providerDid} ${chargeProvider.providerDid != '' ? '\n\n' : ''} ${chargeProvider.statusMessage}",
                  status: LoadingStatus.error,
                  onTap: () {
                    chargeProvider.reset();
                    _dumbChargeProvider!.qrController.resume();
                  }),
              successContent: const SizedBox(),
            )),
      ]));
    });
  }

  Widget _buildScreen(BuildContext context) {
    CEVChargeProvider chargeProvider = CEVChargeProvider.of(context);
    final qrcodeSize = MediaQuery.of(context).size.width - 32;
    return SizedBox(
        height: double.infinity,
        // padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 25.0),
        child: SingleChildScrollView(
            child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.18,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                              width: qrcodeSize, // custom wrap size
                              height: qrcodeSize,
                              child: Stack(children: <Widget>[
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: CustomPaint(
                                    painter: CurvePainter(Colors.black),
                                    child: Container(
                                      margin: const EdgeInsets.all(0.3),
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: CEVRaisedButton(
                                          text: 'Spoof DID Scanning',
                                          icon: Icons.keyboard_arrow_up,
                                          iconColor: CEVTheme.textFadeColor,
                                          textColor: CEVTheme.textFadeColor,
                                          spacing: 8,
                                          padding: const EdgeInsets.all(2),
                                          isIconRight: true,
                                          textSize: 13,
                                          clipText: true,
                                          isTextBold: true,
                                          bgColor: Colors.transparent,
                                          borderColor: Colors.transparent,
                                          elevation:
                                              MaterialStateProperty.all(0),
                                          onPressed: () async {
                                            const data =
                                                'did:peaq:5FNEds4oQeJcJTHX1gXo3NoNNGtTRqSu8KyGhn6UoJmvkYMM';
                                            chargeProvider.providerDid = data;
                                            chargeProvider
                                                .generateAndFundMultisigWallet();

                                            await chargeProvider
                                                .fetchProviderDidDocument(data);
                                            if (!mounted) return;
                                            CEVApp.router.navigateTo(context,
                                                CEVRoutes.providerDetail,
                                                transition:
                                                    TransitionType.inFromRight);
                                          }),
                                    ),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                      const SizedBox(
                        height: 24.0,
                      ),
                      // _buildImportButton(),
                    ]))));
  }

  Widget _buildAppBarTitle(
      BuildContext context, CEVAccountProvider accountProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Text(
                Env.scanProviderDID,
                style: CEVTheme.appTitleStyle,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(
              height: 20,
              width: 250,
              // color: Colors.red,
              child: CEVRaisedButton(
                  text: accountProvider.selectedNode,
                  icon: accountProvider.showNodeDropdown
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  iconColor: CEVTheme.textFadeColor,
                  textColor: CEVTheme.textFadeColor,
                  spacing: 8,
                  padding: const EdgeInsets.all(2),
                  isIconRight: true,
                  textSize: 13,
                  clipText: true,
                  isTextBold: true,
                  bgColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  elevation: MaterialStateProperty.all(0),
                  onPressed: () {
                    accountProvider.showNodeDropdown =
                        !accountProvider.showNodeDropdown;
                  }),
            )

            // _buildDropdown(context, accountProvider),
          ],
        )
      ],
    );
  }
}
