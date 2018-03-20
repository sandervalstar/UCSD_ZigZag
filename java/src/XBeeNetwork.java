import java.util.List;

interface XBeeNetwork {
   int getPanId();
   List<XBeeDevice> getAllDevicesInNetwork(); 
}