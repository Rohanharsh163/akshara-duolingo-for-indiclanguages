class GuestSession {
  static bool isGuest = false;

  static void start() {
    isGuest = true;
  }

  static void end() {
    isGuest = false;
  }
}
