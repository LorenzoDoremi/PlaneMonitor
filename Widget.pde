/**
 * Una classe semplice per la gestione degli spazi di visualizzazione
 */
class Widget {
  int 
    x, 
    y, 
    Wwidth, 
    Wheight;

  public Widget(int x, int y, int Wwidth, int Wheight, int padding) {
    this.x = x;
    this.y = y + (padding/2);
    this.Wwidth = Wwidth - 2*padding;
    this.Wheight = Wheight - 2*padding;
  }
  public Widget() {
  }

  void drawA(int color1) {
    // DISEGNO I WIDGET 
    pushStyle();
    noStroke();
    fill(color1);
    rect(x, y, Wwidth, Wheight, 8); // primo sx
    popStyle();
  }
}
