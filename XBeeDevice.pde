interface XBeeDevice {
   float getDistance();
   XBeeDevice updateDistance();
   XBeeAddress64 get64BitAddress();
   XBeeAddress16 get16BitAddress();
}