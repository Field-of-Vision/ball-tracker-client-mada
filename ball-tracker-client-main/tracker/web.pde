import websockets.*;
import java.net.URL;
import java.net.HttpURLConnection;
import java.io.IOException;
import java.util.concurrent.ConcurrentLinkedQueue;


ConcurrentLinkedQueue<String> requests = new ConcurrentLinkedQueue<String>();

WebsocketClient wsc;
String url;

void webConnect(String uri) {
  if (wsc != null) {
    println("Already connected to <" + url + ">. Disconnect first.");
    return;
  }

  url = uri;
  wsc = new WebsocketClient(this, uri);
  print("uri: ");
  println(uri);
  println(this);
}

void webDisconnect() {
  if (wsc == null) {
    println("Not connected to anything...");
    return;
  }

  // wait for remaining requests before destroying the socket...
  for(;;) {
    String head = requests.poll();
    
    if(head == null) {
      break;
    }

    delay(250);
  }

  wsc.dispose();
  wsc = null;
}

// thread will periodically poll for new requests from the concurrent Q
void webThread() {
  for(;;) {
    String head = requests.poll();
    
    if(head == null) {
      delay(100);
      continue;
    }
    
    wsc.sendMessage(head); 
  }
}

void webSendJson(String json) {
    // add json to request queue to ensure request order
    requests.add(json);
}

// Code for checking internet connection 
void handleConnectionLost() {
  // Handle connection loss here
  System.out.println("Internet connection lost.");
  connectionLost = true;  // global var in game.pde 
}

boolean isInternetConnected() {
  try {
    URL url = new URL("http://www.google.com");
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
    connection.setConnectTimeout(1000); // Set the timeout to a reasonable value
    connection.connect();
    return connection.getResponseCode() == 200;
  } catch (IOException e) {
    return false;
  }
}

void checkInternetConnectionThread() {
  boolean wasConnected = true;
  while (true) {
    boolean isConnected = isInternetConnected();
    if (wasConnected && !isConnected) {
      // Connection lost
      handleConnectionLost();
    } else if (!wasConnected && isConnected) {
      // Connection restored
      connectionLost = false;
    }
    wasConnected = isConnected;
    delay(5000); // Check every 5 seconds
  }
}

void webSetup() {
  thread("webThread");
  thread("checkInternetConnectionThread");
}
