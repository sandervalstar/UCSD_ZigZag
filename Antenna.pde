interface Antenna {
  void setPanId(int panId);
  List<? extends XBeeResponse> sendNodeDiscovery();
  float getRemoteRSSI(XBeeAddress64 remoteAddress64);
}