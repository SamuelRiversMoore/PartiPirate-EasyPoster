
import controlP5.*;
import processing.pdf.*;
import processing.video.*;

Movie theMov; 
ControlP5 cp5;

boolean record = false;
int c1, c2;
float n, n1;

// Adapte la mise en page à la longueur du texte
int h = 849;
int l = 600;

String typedText = "Texte";

int pdfH = 1145;
int pdfW = 797;

PFont font;

int interligne = -1;
int position = 0;

color coulFond = #ffa500;

int decV = -10;
int decH = -10;

// Variable Logos
PImage[] myImageArray = new PImage[31];
int logoW = (l/3)*2;
int logoH = (logoW/4)*3;

float pdfLogoW = (pdfW/3)*2.3;
float pdfLogoH = (pdfLogoW/4)*3;




void setup() {
  size(600, 849);
  font = createFont("TerminalGrotesque_a", 5);  
  cp5 = new ControlP5(this);

  // bouton PDF
  Bang printB = cp5.addBang( "RESET" )
    .setPosition( width-69+decV, height-66+decH )
      .setSize( 50, 47 )
        .setColorForeground(coulFond)
          .setColorActive(#ffb837)
            .setColorLabel(0)
              ;

  Bang resetB = cp5.addBang( "PRINT" )
    .setPosition( width-50+decV-70, height-66+decH )
      .setSize( 50, 47 )
        .setColorForeground(coulFond)
          .setColorActive(#ffb837)
            .setColorLabel(0)
              ;

  printB.getCaptionLabel()
    .align( CENTER, CENTER )
      ;

  resetB.getCaptionLabel()
    .align( CENTER, CENTER )
      ;

  theMov = new Movie(this, "logo.mp4");
  theMov.loop();
}




void draw() {

  background(coulFond);
  fill(0);
  rect(width-121+decV, height-67+decH, 102, 48);

  tint(coulFond);
  
  // logo
  image(theMov, 2 -(logoW/10.75), height - (2*(height/8.75)), logoW, logoH); 

  // texte
  fill(0);
  textFont(font);
  textAlign(LEFT, TOP);


  String s = typedText; 
  String[] list = split(s, '\n');

  float scalar = 0.765; // Different for each font
  float[] lineHeight = new float[list.length];

  float posXbar = 0;
  float posYbar = 0;
  float bar = 0;


  for (int i = 0 ; i < list.length ; i++ ) {
    textSize(1);
    int descLim = 0;

    for (int j = 0; j < 1200 ; j++) {
      if ( textWidth(list[i]) < l-30) {
        textSize(j);
        descLim = j;


        char lastChar = 0;
        if (s.length() <= 0) {
          lastChar = '0';
        } 
        else
        {           
          lastChar = s.charAt(s.length()-1);
        }


        float lastCharW = textWidth(lastChar);

        ///// REGLAGE BARRE /////

        float rightSp = 30;

        if (j < 150) {
          rightSp = (j-60)/3;
          posXbar = width-(bar+rightSp);
          if (rightSp < 5) {
            rightSp = 5;
          }
        }
        else if ( j < 60) {
          rightSp = 5;
          posXbar = width-(bar+rightSp);
        }

        if (j > 800) {
          bar = width-60;
          posXbar = 0;
        }

        else {
          if (j < 50) {
            bar = 19 ;
          } 
          else {
            bar = lastCharW*0.80;
          }
          posXbar = width-(bar+rightSp);
        }
      }


      if (posXbar < width-(bar+30)) {
        posXbar = width-(bar+30);
      }
    }

    float ascent = textAscent() * scalar; 
    float descent = textDescent(); 
    lineHeight[i] = ascent;
    int posY=15;
    float totalHeight = ascent+descent;
    float descBar = ascent*1.1;

    if (descLim < 60) {
      descBar = ascent + 3;
    } 
    else {
      descBar = ascent*1.1;
    }

    for (int k=0 ; k < i ; k++) {
      posY += lineHeight[k] ;
    }

    posYbar = posY+(descBar);
    if (posYbar > height-70) {
      posYbar = height-29;
    }

    text(list[i], 15, posY-descent, l+(l/6), 1200);
  }

  ////////////////////////// PDF ////////////////////////////////

  float[] pdfLineHeight = new float[list.length];

  if (record == true) {
    String date = new java.text.SimpleDateFormat("dd:MM:yy(H'h'm'm's's')").format(new java.util.Date ());  
    PGraphics pdf = createGraphics(pdfW, pdfH, PDF, "captures/print/PPPoster1-" + date + ".pdf");
    pdf.beginDraw(); 

    pdf.image(theMov, (pdfW/300) - (pdfLogoW/9), pdfH - (2*(pdfH/8)), pdfLogoW, pdfLogoH); 
    // texte
    pdf.fill(0);
    pdf.textFont(font);
    pdf.textAlign(LEFT, TOP);

    for (int pdfi = 0 ; pdfi < list.length ; pdfi++ ) {
      pdf.textSize(1);
      for (int pdfj = 0; pdfj < pdfW*2 ; pdfj++) {
        if ( pdf.textWidth(list[pdfi]) < pdfW-(pdfW/100)) {
          pdf.textSize(pdfj);
        }
      }

      // interlignage
      float pdfAscent = pdf.textAscent() * scalar; 
      float pdfDescent = pdf.textDescent(); 
      pdfLineHeight[pdfi] = pdfAscent;
      int pdfPosY= 0; //pdfW/50;

      for (int pdfk=0 ; pdfk < pdfi ; pdfk++) {
        pdfPosY += pdfLineHeight[pdfk] + interligne ; // interligne
      }
      pdf.text(list[pdfi], 0 , pdfPosY-pdfDescent, pdfW+(pdfW/6), pdfW*2);
    }

    pdf.dispose();
    pdf.endDraw();
    record = false;
  }




  ////// Curseur Clignotant
  if (frameCount/30 % 2 == 0) {
    fill(0);
    rect(posXbar, posYbar, bar, 0);
  }
}


// Called every time a new frame is available to read
void movieEvent(Movie m) { 
  m.read();
} 


//Retour à la ligne, effacer, etc.
void keyPressed() {
  if (key != CODED) {
    switch(key) {
    case BACKSPACE:
      typedText = typedText.substring(0, max(0, typedText.length()-1));
      break;
    case TAB:
      typedText += "    ";
      break;
    case ENTER:
    case RETURN:
      // comment out the following two lines to disable line-breaks
      typedText += "\n";
      break;
    case ESC:
    case DELETE:
      break;
    default:
      typedText += key;
    }
  }
}


void PRINT() {
  record = true;
}

void RESET() {
  typedText = "Texte";
}

