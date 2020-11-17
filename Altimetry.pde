/**
 * Una classe a parte che gestisce le chiamate all'API dell'altimetria
 */
public class Altimetry {


  float maxDistance = 0.1; // distanza a cui guardare
  float increment = 0.01; // dipendente dalla velocità del velivolo
  float distance; // controllo se la distanza è sempre corretta
  JSONArray dataset; //altimetrie di ogni punto davanti al velivolo
  boolean altimetryReady = false; //controllo che i dati siano disponibili
  int max; //valor massimo dell'altimetria in caso di utilizzo Collision Detection
  Widget widget; // widget nel quale inserire l'altimetria

  public Altimetry(Widget widget) {
    this.widget = widget;
  }


  // Richiesta del file JSON al server
  void altimetry(LabeledMarker marker) {
    // creo le coordinate per un punto in direzione corretta a distanza =  maxDistance
    String query = setCoords(marker.info.getFloat(6), marker.info.getFloat(5), marker.info.getFloat(10));
    JSONObject response = loadJSONObject(query);
    JSONArray values = response.getJSONArray("data");
    dataset =  values.getJSONObject(0).getJSONArray("profile"); 
    altimetryReady = true; //i dati sono stati inseriti
  
  }






  // algoritmo per creare le coordinate corrette dei due punti dell'altimetric path
  // latitude2 e longitude2 sono le coordinate del punto a cui guardo
  String setCoords(float lat, float longit, float angle) {
    angle = angle+90; // riceve coordinate partendo dal nord invece che da est
    lat = (lat+(increment*sin(radians(angle)))) ;
    longit = (longit+(increment*cos(radians(angle))));
    double latitude2 = (lat+maxDistance*(sin(radians(angle))))+(increment*(sin(radians(angle))));
    double longitude2 = (longit+maxDistance*cos(radians(angle))+(increment*cos(radians(angle))));
    distance = dist((float)lat, (float)longit, (float)latitude2, (float)longitude2);

    return "https://api.airmap.com/elevation/v1/ele/path?points="+lat+",+"+longit+","+latitude2+","+longitude2+"";
  }

  // disegno il grafico altimetrico tramite Shape e sfruttando il widget disposto
  void drawAltimetry(int padding, float altitude, int maxM) {

    pushMatrix();
    fill(#8CD5FE, 80);
    stroke(246, 46, 46);
    noStroke();
    beginShape();
    vertex(widget.x, widget.y + widget.Wheight);
    for (int i = 0; i <  dataset.size(); i+=2) {
      try {  

        vertex(widget.x + i*(widget.Wwidth)/(dataset.size()), 
          (widget.y+widget.Wheight)-(int)((dataset.getDouble(i)*((float)(widget.Wheight )/maxM))));
      } 

      catch(Exception e) {
        pushStyle();
        textAlign(CENTER);
        text("Corrupted data! this plane is sending incorrect information", widget.x + widget.Wwidth/2, widget.y + widget.Wheight/2);
        popStyle();
    }
    }
    try {
    // creo gli ultimi punti per chiudere la forma 
    vertex(widget.x + widget.Wwidth, height-(int)((dataset.getDouble(dataset.size()-1)*((float)(height/2 -  (padding*3/2) )/maxM))  ) - padding );
    vertex(widget.x + widget.Wwidth, widget.y + widget.Wheight);
   
    }
    catch (Exception e) {
     println("corrupted data");
     
       
   }
    endShape(CLOSE);
    popMatrix();
    // DISEGNO I WIDGET 
    pushStyle();
    noStroke();


    // disegno le linee del grafico altimetrico
    for (int j = 0; j < maxM/1000; j++) {
      fill(255);
      stroke(180, 212, 244, 20);
      strokeWeight(1);
      line(
        widget.x, 
        widget.y + j*(widget.Wheight/(maxM/1000)), 
        widget.x+ widget.Wwidth, 
        widget.y + j*(widget.Wheight/9));
      fill(180, 212, 244, 90);
      text((maxM-1000)-(j*1000)+"", widget.x+widget.Wwidth - padding*4, 
        height/2 + (padding/2) + (j+1)*(widget.Wheight/(maxM/1000)) - 10);
    }

    text("plane altitude: "+(int)altitude+"m", widget.x + widget.x/2, widget.y + padding+10);

    // DISEGNO L'AEREO ROSSO
    if (altitude < maxM) {
      try {
        fill(255, 0, 0);
        rect(altimetryWidget.x + padding, 
          height - padding - 
          (altitude*(float)(altimetryWidget.y -  (padding*3/2) )/maxM ), 40, 10);
      }
      catch (Exception e) {
        println("not a number in the dataset");
      }
    }
  }
}
