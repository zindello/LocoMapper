
String mapImage = "/Users/zindello/Downloads/newtrack.jpg";
float mapTopLeftLat = -37.632428;
float mapTopLeftLong = 144.80205;
float mapBottomRightLat = -37.637027;
float mapBottomRightLong = 144.805853;
int serialPort = 0;

//#### Required for Program ####
//#### Do not edit anything ####
//####   Below this line    ####

import processing.serial.*;

String serialData;
Serial port; // The serial port object

PImage map;

float mapWidthScale = 0;
float mapHeightScale = 0;
float screenHeight;
float screenWidth;
float mapWidth;
float mapHeight;
int newMapWidth = 0;
int newMapHeight = 0;
float gpsXPos = 0;
float gpsYPos = 0;


float locoPosition[][] = new float[50][3];
String locoNames[] = new String[50];


//boolean sketchFullScreen() {
//  return true;
//}

void setup () {
  size(displayWidth, displayHeight);
  frame.setResizable(true);

  screenHeight = height;
  screenWidth = width;

  map = loadImage(mapImage);
  mapHeight = map.height;
  mapWidth = map.width;
  if ( map.width > screenWidth ) {
    mapWidthScale = ceil(mapWidth/screenWidth);
  }
  if ( mapHeight > screenHeight ) {
    mapHeightScale = ceil(mapHeight/screenHeight);
  }
  
  if ( mapWidthScale != 0 || mapHeightScale != 0 ) {
    if ( mapWidthScale >= mapHeightScale ) {
      newMapWidth = round(mapWidth / mapWidthScale);
      map.resize(newMapWidth,0);
    } else {
      newMapHeight = round(mapHeight/ mapHeightScale);
      map.resize(0,newMapHeight);
    }
  }
  
  println(Serial.list());
  
  //port = new Serial(this, Serial.list()[serialPort], 9600);
  
  update_loco_position( 2, "Jonesy", 144.804192, -37.632923, 8.9);
  //noLoop();
}

void draw() {
  frame.setSize(map.width, map.height);
  draw_positions(map);
  delay(1000);
}

void draw_positions ( PImage mapImage ) {
  image(map, 0, 0);

  int i = 0;
  while ( i < 49 ) {
    if ( locoPosition[i][0] != 0 ) {
      String locoInfo = i + " - " + locoNames[i] + "\n" + locoPosition[i][2] + " km/h";
      fill(209);
      rect(locoPosition[i][0], locoPosition[i][1], 100, 40);
      fill(0);
      textSize(12);
      text(locoInfo, locoPosition[i][0], locoPosition[i][1] + 3, 100, 40);
      if (locoPosition[i][2] > 10) {
        fill(255,0,0);
      } else {
        fill(0,0,255);
      }
      ellipse(locoPosition[i][0], locoPosition[i][1], 5, 5);
    }
    i++;
  }
 
}

void update_loco_position( int locoNumber, String locoName, float locoXGPS, float locoYGPS, float locoSpeed) {

  locoPosition[locoNumber][0] = map(locoXGPS, mapTopLeftLong, mapBottomRightLong, 0, map.width);
  locoPosition[locoNumber][1] = map(locoYGPS, mapTopLeftLat, mapBottomRightLat, 0, map.height);
  locoPosition[locoNumber][2] = locoSpeed;
  locoNames[locoNumber] = locoName;
}

void processSerialData() {
  // Message Format: 1,Jonesy,-37.632923,144.804192,10,33b3b337
  // <Identifier>,<Name>,<Latitude>,<Longditude>,<Speed>,<MD5 Hash trimmed to 8 chars>
  String[] serialMessage = split(serialData, ',');
  serialData = "";
  byte[] serialMessageHash = messageDigest(serialMessage[0] + "," + serialMessage[1] + "," + serialMessage[2] + "," + serialMessage[3] + "," + serialMessage[4] + ",","MD5");
  String serialMessageHashString = new String(serialMessageHash).substring(0,8);
  if ( serialMessageHashString == serialMessage[5]) {
    //Message Valid
    update_loco_position( int(serialMessage[0]), serialMessage[1], float(serialMessage[3]), float(serialMessage[2]), float(serialMessage[4]));
  }
}

void serialEvent(Serial port) {
  while (port.available() > 0) {
    serialData = serialData + port.readString();   
  }
  processSerialData();
}

byte[] messageDigest(String message, String algorithm) {
  try {
  java.security.MessageDigest md = java.security.MessageDigest.getInstance(algorithm);
  md.update(message.getBytes());
  return md.digest();
  } catch(java.security.NoSuchAlgorithmException e) {
    println(e.getMessage());
    return null;
  }
} 

