import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class LoginController extends GetxController {
  final Rxn<SessionStatus> sessionGlobal = Rxn<SessionStatus>(null);
  final RxString uriGlobal = RxString('');

  WalletConnect connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
          name: 'Cupcake ETH',
          description: 'A cupcake marketplace',
          url: 'https://walletconnect.org',
          icons: [
            'https://github.com/TomasWard1/cupcake_eth/blob/a1630b18bcd04d876bf6cf5208a5efadd88e3f99/assets/cupcake.png'
          ]));

  loginUsingMetamask() async {
    if (!connector.connected) {
      try {
        var session = await connector.createSession(onDisplayUri: (uri) async {
          uriGlobal.value = uri;
          await launchUrlString(uri, mode: LaunchMode.externalApplication);
        });

        print(session.accounts[0]);
        print(session.chainId);

        sessionGlobal.value = session;
      } catch (exp) {
        print(exp);
      }
    }
  }
}
