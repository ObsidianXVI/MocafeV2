library mocafe;

import 'dart:async';
import 'dart:io';

bool cafeIsOpen = false;
final List<CoffeeMachine> coffeeMachines =
    List.generate(5, (i) => CoffeeMachine("cm-$i"));
int waitingCustomers = 0;
final HttpClient httpClient = HttpClient();

void main(List<String> args) {
  cafeIsOpen = true;
  waitingCustomers = int.parse(args.first);
  final Timer timer =
      Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
    Logger.refreshScreen();
    if (cafeIsOpen) {
      if (waitingCustomers > 0) {
        fetchMenu();
        serveCustomers();
      } else {
        cafeIsOpen = false;
        exit(0);
      }
    } else {
      t.cancel();
    }
  });
}

void serveCustomers() {
  final Iterable<CoffeeMachine> availMachines = getAvailableMachines();
  if (availMachines.isNotEmpty) {
    for (CoffeeMachine cm in availMachines) {
      if (waitingCustomers > 0) {
        cm.serve();
        waitingCustomers -= 1;
      } else {
        throw waitingCustomers;
      }
    }
  }
}

Future<void> fetchMenu() async {
  final HttpClientResponse response = await (await httpClient.getUrl(
    Uri.https(
      "json.org",
      '/path',
      {},
    ),
  ))
      .close();
}

class CoffeeMachine {
  final String id;
  bool isAvailable;

  CoffeeMachine(this.id) : isAvailable = true;

  void serve() {
    isAvailable = false;
    Future.delayed(const Duration(seconds: 4), () => isAvailable = true);
  }
}

Iterable<CoffeeMachine> getAvailableMachines() =>
    coffeeMachines.where((CoffeeMachine cm) => cm.isAvailable);

class Logger {
  static void refreshScreen() {
    print("\x1B[2J\x1B[0;0H");
    print("Customers: $waitingCustomers");
    print("Idle: ${getAvailableMachines().length}");
    print(
        "Processing: ${coffeeMachines.where((cm) => !cm.isAvailable).map((e) => e.id).join(', ')}");
  }
}
