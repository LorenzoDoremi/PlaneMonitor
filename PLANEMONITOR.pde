import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;  
UnfoldingMap map;

PFont mono;
String JSONwebsite; // link alla REST API
JSONArray states; // Tutti i vettori ottenuti. 
JSONObject response; // oggetto ottenuto dalla query REST
boolean ready = true; // avviso di termine chiamata 
double lat = 47.8229; //posizionamento telecamera
double longit = 10.5226; //posizionamento telecamera
boolean maplock = false; // threadlock per la concorrenza
boolean restart = false; // utilizzo per ricontare i millisecondi tra le chiamate
boolean crash = false; // errore del server. 
StateHash hash; // hash table con tutti i marker presenti nella mappa.
int time = 0; // memoria del tempo passato tra le chiamate
Altimetry altimetry; // classe altimetria che gestisce la sua chiamata REST
int padding; // spazio tra i widget
Widget dataWidget; 
Widget altimetryWidget;

int colorshaded = #585983;
int colorstrong = #BDDFFF;
int colorwidget = #32334D;
int colorbackground = #322C42;

void setup() {

  size(1600, 900, P2D);
  mono = createFont("Roboto.ttf", 32);
  textFont(mono);
  frameRate(40);
  textSize(18);
  // Inizializzo il mio oggetto map
  map = new UnfoldingMap(this, padding, padding, (width - padding*2), (height*1/2 - padding*2 ));
  map.zoomAndPanTo(8, new Location(lat-1, longit-4));
  MapUtils.createDefaultEventDispatcher(this, map);
  map.setTweening(true);

  // Inizializzo la hashtable
  hash = new StateHash(map);
  // inizializzo i widget posizionandoli
  padding = 20;
  dataWidget = new Widget(20, height/2, width/3, height/2, padding);
  altimetryWidget = new Widget(width/3, height/2, width*2/3, height/2, padding);
  altimetry = new Altimetry(altimetryWidget);
  //  JSONwebsite = "https://opensky-network.org/api/states/all?lamin=36.315125&lomin=-9.228516&lamax=58.539595&lomax=24.345703";
  JSONwebsite = "https://opensky-network.org/api/states/all";
}
void draw() {


  if (!maplock) {
    background(colorbackground);
    maplock = true; 
    try {
      map.draw();
    }
    catch (Exception e) {
      println("");
    }
    maplock = false;
  }
  // -------------------------------------------------------
  // OTTENGO NUOVI DATI AL CLICK OPPURE OGNI 5 SECONDI SE PRONTO
  if ((millis() - time > 5000 || hash.justClicked)  && ready) {
    ready = false;
    thread("requestData");
    restart = true;
  }
  // OTTENGO NUOVE ALTIMETRIE SE E' TUTTO PRONTO 
  if ((millis() - time > 5000 || hash.justClicked)  && hash.markerSelected) {
    if (hash.justClicked)
    {
      hash.justClicked = false;
    }

    thread("requestAltimetry");
    restart = true;
  }


  // inizio ciclo di attesa
  if (restart) {
    time = millis();
    restart = false;
  }
  // -------------------------------------------------------
  // DISEGNO IL RADAR DELL'ANIMAZIONE

  if (hash.markerSelected) {
    hash.radar.radarDraw();
  }
  // -------------------------------------------------------
  // DISEGNO IL LABEL DELL'AEREO SELEZIONATO
  if (!maplock) {
    maplock = true;
    try {


      if (hash.markerSelected) {
        hash.hitMarker.drawLabel(hash.map);
      }
    }
    catch (Exception e) {
      println("access denied LABEL : hash is updating");
    }
    maplock = false;
  }
  // -------------------------------------------------------
  // DISEGNO I WIDGET
  drawWidgets();
  drawInfo(hash.hitMarker);
  // -------------------------------------------------------
  // DISEGNO L'ALTIMETRIA NEL GRAFICO
  if (altimetry.altimetryReady && hash.markerSelected) {
    try {
      // 9000 sono i metri di altitudine massimi di visualizzazione  
      altimetry.drawAltimetry(20, hash.hitMarker.info.getFloat(7), 9000);
    }
    catch (Exception e) {
       
    }
  }

  // "tutorial" nel caso di non selezione 
  if (!hash.markerSelected && !crash) {

    pushStyle();
    textAlign(CENTER);
    fill(colorshaded);
    textSize(32);
    text("Click on a plane to see info!", altimetryWidget.x + altimetryWidget.Wwidth/2, altimetryWidget.y + altimetryWidget.Wheight/2);
    textSize(14); 

    text("(cant see any? don't worry, just loading...)", altimetryWidget.x  + altimetryWidget.Wwidth/2, altimetryWidget.y + altimetryWidget.Wheight/2  + 30);
    popStyle();
  } else if (crash) {
    textAlign(CENTER);
    fill(colorshaded);
    textSize(32);
    text("Sorry, but unfortunately the server doesn't respond :( try restarting!", altimetryWidget.x + altimetryWidget.Wwidth/2, altimetryWidget.y + altimetryWidget.Wheight/2);
  }
}

/* FINE DRAW ------------------------------------------------------------------------ */









// thread che richiede dati su tutti gli aerei presenti in volo 
void requestData() {
  print("new request");

  try {
    response = loadJSONObject(JSONwebsite);
    states = response.getJSONArray("states");
    thread("updateData");
  }
  catch(Exception e) {
    crash = true;
  }
}


/* ------------------------------------------------------------------------ */
// thread che aggiorna gli stati di tutti gli aerei
void updateData() {

  while (maplock) {
    println("waiting");
  }
  if (!maplock) { 
    maplock = true;
    println("updating...");
    hash.update(states);
    maplock = false;
    ready = true;
  }
}



// thread che richiede l'altimetria dell'aereo scelto
void requestAltimetry() {
  altimetry.altimetry(hash.hitMarker);
}




/* ------------------------------------------------------------------------ */
// event listener per il mouse sulla mappa
public void mouseClicked() {

  hash.select();
}


// Semplicemente disegno tutti i widget
void drawWidgets() {
  // DISEGNO nascondo parte dei label e radar fuori mappa con un quadrato. "superfluo".
  fill(colorbackground);
  noStroke();
  rect(0, height/2-padding, width, height/2 + padding);
  // -------------------------------------------------------
  dataWidget.drawA(colorwidget);
  altimetryWidget.drawA(colorwidget);
}




// METODO PER DISEGNARE I TESTI DI SX DOVE NECESSARIO
void drawInfo(LabeledMarker marker) {
  if (hash.markerSelected) {


    pushStyle();
    textSize(14);
    fill( colorshaded);
    text("Plane callsign", dataWidget.x + padding, dataWidget.y + (padding/2) + 50);
    text("origin", dataWidget.x + padding, dataWidget.y + 120);
    text("coordinates", dataWidget.x + padding, dataWidget.y + 190);
    text("speed", dataWidget.x + padding, dataWidget.y + 260);


    textSize(32);
    fill(colorstrong);
    text(marker.name, dataWidget.x + padding, dataWidget.y + 100);


    textSize(24);
    text(marker.info.getString(2), dataWidget.x + padding, dataWidget.y + 150);
    text(marker.info.getFloat(5)+" "+hash.hitMarker.info.getFloat(6), dataWidget.x + padding, dataWidget.y + 220);
    text((int)(3.6*marker.info.getFloat(9))+" KM/H", padding*2, height/2 + (padding/2) + 290);

    popStyle();
  }
}
