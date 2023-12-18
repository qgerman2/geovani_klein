#include <SoftwareWire.h>
#define sensor_direc 0x28

SoftwareWire myWire(2, 3);
SoftwareWire myWire2(4, 5);

#include <SoftwareSerial.h>
const byte rxPin = 7;
const byte txPin = 6;
SoftwareSerial SerialAPixHawk(rxPin, txPin);

float offset;
const int veleta_AOA = A1;
const int alimentacion = A0;
const int veleta_SSA = A2;


float deltapres_fwd, deltapres_45;
float pfwdnocarga, p45nocarga, pfwdnocargapsi, p45nocargapsi;
float pfwdcorr_pas, p45corr_pas;
int lectura1 = 0;
int lectura45 = 0;
int valor = 63;
int Pmax, Pmin, cuenta;
float l45, lfwd;
float pfwd_p45; //relacion entre pfwd y p45
float relacion, lfwd_corr, l45_corr;


void setup() {
    Serial.begin(9600);
    myWire.begin();
    myWire2.begin();
    SerialAPixHawk.begin(115200);

    pfwdnocarga = 8190; //corroborar bn estos valores
    p45nocarga = 8230; //corroborar bn estos valores
    cuenta = 16383;
    Pmax = 1; //psi
    Pmin = -1; //psi
    pfwdnocargapsi = ((pfwdnocarga - (0.1 * cuenta)) * ((Pmax - Pmin) / (0.8 * cuenta)) + Pmin);
    p45nocargapsi = ((p45nocarga - (0.1 * cuenta)) * ((Pmax - Pmin) / (0.8 * cuenta)) + Pmin);

}

void loop() {
    //conexion con el sensor fwd
    myWire.beginTransmission(sensor_direc);
    myWire.write(0);
    myWire.endTransmission();
    myWire.requestFrom(sensor_direc, 2);
    if (2 <= myWire.available()) {
        lectura1 = myWire.read();
        lectura1 = lectura1 & valor;
        lectura1 = lectura1 << 8;
        lectura1 |= myWire.read();
    }
    //conexion con el sensor p45
    myWire2.beginTransmission(sensor_direc);
    myWire2.write(0);
    myWire2.endTransmission();
    myWire2.requestFrom(sensor_direc, 2);
    if (2 <= myWire2.available()) {
        lectura45 = myWire2.read();
        lectura45 = lectura45 & valor;
        lectura45 = lectura45 << 8;
        lectura45 |= myWire2.read();

    }
    //lecturas de la presion en bytes como float 
    l45 = lectura45;
    lfwd = lectura1;
    lfwd_corr = lfwd - pfwdnocarga;
    l45_corr = l45 - p45nocarga;
    deltapres_fwd = ((lfwd - (0.1 * cuenta)) * ((Pmax - Pmin) / (0.8 * cuenta)) + Pmin) - pfwdnocargapsi;   //presion en psi TIPO A  corregida
    deltapres_45 = ((l45 - (0.1 * cuenta)) * ((Pmax - Pmin) / (0.8 * cuenta)) + Pmin) - p45nocargapsi;    //presion en psi TIPO A  corregida
    pfwdcorr_pas = deltapres_fwd * 6894.75; //persion en fwd en pascales
    p45corr_pas = deltapres_45 * 6894.75;  //presion en 45 en pascales

    pfwd_p45 = pfwdcorr_pas / p45corr_pas;  //relacion entre presion fwd y 45
    relacion = lfwd_corr / l45_corr;


    //LECTURAS DE LAS VELETAS
    int lectura_veleta_AOA = analogRead(veleta_AOA);
    int lectura_alimentacion = analogRead(alimentacion);
    int lectura_veleta_SSA = analogRead(veleta_SSA);
    offset = 0.06;
    float voltage_AOA = offset + lectura_veleta_AOA * (5.0 / 1023.0);
    float alimentacion = offset + lectura_alimentacion * (5.0 / 1023.0);
    float voltage_SSA = offset + lectura_veleta_SSA * (5.0 / 1023.0);


    struct valores {
        float a;
        float b;
        float c;
        float d;
        float e;
        float f;
    };
    valores v = {
      pfwdcorr_pas,
      p45corr_pas,
      pfwd_p45,
      alimentacion,
      voltage_AOA,
      voltage_SSA
    };
    uint8_t size = sizeof(v);
    SerialAPixHawk.print("init");
    SerialAPixHawk.write(size);
    SerialAPixHawk.write(reinterpret_cast<uint8_t *>(&v), size);

    delay(10);

}