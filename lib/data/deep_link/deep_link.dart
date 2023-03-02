enum DeepLinkType { event, chat, settings, none }

class DeepLink {
  late DeepLinkType type;
  late List<String> args;

  DeepLink({
    required String type,
    required this.args,
  }) {
    switch (type) {
      case "event":
        this.type = DeepLinkType.event;
        break;
      case "chat":
        this.type = DeepLinkType.chat;
        break;
      case "settings":
        this.type = DeepLinkType.settings;
        break;
      default:
        this.type = DeepLinkType.none;
        break;
    }
  }

  @override
  String toString() {
    var map = {
      "type": type.name,
      "args": args,
    };
    return map.toString();
  }
}
