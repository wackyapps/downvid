import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

// shard intent recived event
class SharedIntentReceivedEvent {
  final String sharedUrlText;
  SharedIntentReceivedEvent(this.sharedUrlText);
}
