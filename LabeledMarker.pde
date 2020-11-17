/**
 * Una classe estesa dei marker al fine di potenziare il loro utilizzo e aspetto
 */
public class LabeledMarker extends SimplePointMarker {

  PImage p; //immagine dell'aereo 
  protected String name; // nome dell'aereo (presente anche in info, ma comodo)
  protected float size = 15; //caratteristiche primitive marker
  protected int space = 6;  //caratteristiche primitive marker
  float x, y;
  JSONArray info; // tutte le informazioni su un aereo

  /**
   * Costruttori originali
   */
  public LabeledMarker(Location location) {
    this(location, null, null, 0);
  }
  public LabeledMarker(Marker marker) {
    this(marker.getLocation(), null, null, 0);
  }

  public LabeledMarker(Location location, String name, JSONArray info, PImage p) {
    this(location, name, null, 0);
    this.info = info;
    this.p = p;
  }



  public LabeledMarker(Location location, String name, PFont font, float size) {
    this.location = location;
    this.name = name;
    this.size = size;
  }


  /**
   * Overwrite del metodo draw dei marker
   */
  public void draw(PGraphics pg, float x, float y) {

    // BOUNDING BOX PER IL RENDER (OTTIMIZZAZIONE)
    if (x>0 && x < width && y > 0 && y < height/2) {

      pg.pushStyle();
      pg.beginDraw();
      pg.imageMode(CENTER);
      pg.translate(x, y);
      pg.rotate(radians(info.getFloat(10)));
      pg.image(p, 0, 0, 28, 28);  
      pg.endDraw();
      pg.popStyle();
    }
  }
  // DISEGNA I LABEL NELLA MAPPA
  void drawLabel(UnfoldingMap map) {
    pushStyle();
    fill(0, 161, 255);
    rect(this.getScreenPosition(map).x+20, this.getScreenPosition(map).y-20, 80, 20);
    fill(255);
    text(this.getName(), this.getScreenPosition(map).x+20, this.getScreenPosition(map).y - 5 );
    popStyle();
  }

  public String getName() {
    return name;
  }
}
