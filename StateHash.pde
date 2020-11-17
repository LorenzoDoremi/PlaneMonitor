/** questa classe gestisce la hashtable, e tutta la serie di 
 oggetti necessari alla visualizzazione e gestione degli aerei 
 
 **/

public class StateHash {
  PImage p = loadImage("plane.png"); // carica immagine aerei
  PImage psel = loadImage("planeSel.png"); // carica immagine aereo selezionato
  HashMap states; // hash-table con tutti i marker 
  boolean markerSelected = false; // controlla se ho selezionato un marker
  boolean justClicked = false; // controlla se ho appena premuto (per riavviare le call)
  LabeledMarker lastMarker = new LabeledMarker(new Location(0, 0)); // utilizzato per cancellare la selezione precedente
  LabeledMarker hitMarker; // marker selezionato 
  Radar radar = new Radar(); // utilizzato per l'effetto radar
  UnfoldingMap map; // mappa a cui è collegata la classe

  public StateHash(UnfoldingMap map) {
    this.map = map;
    states = new HashMap(5000);
  }

  // questo metodo fa l'update in tempo lineare, grazie ad hash, di tutti i valori 
  void update(JSONArray allStates) {
   
    for (int i = 0; i < allStates.size(); i++) {
         try {
      JSONArray informations = allStates.getJSONArray(i); //informazioni di ogni aereo i  
      String flightName = informations.getString(1); // chiave della hash
    
        //se già esiste aggiorno
        if (states.get(flightName) != null) {
          getMarker(flightName).setLocation(new Location(informations.getFloat(6), informations.getFloat(5)));
          getMarker(flightName).info = informations; // nuovi dati JSON
        } else {
          // altrimenti creo nuovo record
          LabeledMarker x = new LabeledMarker(new Location(informations.getFloat(6), informations.getFloat(5)), flightName, informations, p ); 
          states.put(x.name, x);
          map.addMarker(x);
        }
      }
     
   catch(Exception e) {
       
       println("");
    }
  }
     println("updated successfully!");
   
  }

  // questo metodo mi permette di castare il tipo e ottenere il marker su cui fare update.
  LabeledMarker getMarker(String name) {
    return  (LabeledMarker)states.get(name);
  }


  // questa funzione seleziona un marker (un velivolo) 
  void select() {

    try {  
      hitMarker = (LabeledMarker)map.getFirstHitMarker(mouseX, mouseY);

      if (hitMarker != null) {

        justClicked = true;
        lastMarker.setSelected(false);
        lastMarker.p = p;
        hitMarker.setSelected(true);
        this.markerSelected = true;
        hitMarker.p = psel;
        lastMarker = hitMarker;
      } else {
        
        lastMarker.p = p;
        this.markerSelected = false;
      }
    }
    catch(Exception e) {
      println("not a number somewhere");
    }
  }
  /** ---------------------------------------- **/
  private class Radar {


    int radius = 30;
    float opacity = 255;
    color radarColor = color(0, 161, 231, opacity);
    public Radar() {
    }



    void radarDraw() {
      radarColor = color(200, 200, 255, opacity);  
      ScreenPosition position = hitMarker.getScreenPosition(map);
      pushStyle();
      noStroke();
      fill(radarColor);
      ellipse(position.x, position.y, radius, radius);
      popStyle();
      opacity-=2;
      radius+=2;
      if (opacity <= 0) {
        opacity = 255;
        radius = 30;
      }
    }
  }
}
