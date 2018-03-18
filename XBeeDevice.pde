interface XBeeDevice {
   float getRSSI();
   XBeeDevice updateRSSI();
   String get64BitAddress();
   String get16BitAddress();
}