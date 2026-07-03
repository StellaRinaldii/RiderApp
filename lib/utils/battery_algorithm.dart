import "dart:math";

class Battery {
  // istances
  int batteryLevel;
  int maxLevel = 100;
  int minLevel = 5;

  // constructors
  Battery({this.batteryLevel = 100});

  // methods
  void batterygain(int efficiency, double sleeptime) {
    // efficiency must be a %
    // skeeptime is in h
    double sleepHours = sleeptime/60;
    double gain = (efficiency*sleepHours/8);

    // check for the maximum level of battery
    if (batteryLevel>maxLevel) {
      batteryLevel = maxLevel;
    } else {
      batteryLevel = batteryLevel + gain.toInt();
    }
    
  }

  void batteryloss(int age, int hrex, int hrrest, int timeExercise) {
    // timeExercise is given as input in minutes
    // compute maximum heart rate
    num hrmax = 220 - age;

    // compute the TRIMP/min
    double ratio = (hrex - hrrest)/(hrmax - hrrest);
    double trimpMin = ratio*0.64*exp(1.92 * ratio);

    // compute the loss of bactery
    double loss = (15 * trimpMin)/2.2*timeExercise;

    // check for the minimum level 
    if (batteryLevel < minLevel){
      batteryLevel = minLevel;
    } else {
      batteryLevel = batteryLevel - loss.toInt();
    }
    
  }

  int lossEstimation(int age, int hrex, int hrrest, int timeExercise) {
        num hrmax = 220 - age;

    // compute the TRIMP/min
    double ratio = (hrex - hrrest)/(hrmax - hrrest);
    double trimpMin = ratio*0.64*exp(1.92 * ratio);

    // compute the loss of bactery
    double loss = (15 * trimpMin)/2.2*timeExercise;
    return loss.toInt();

  }

}


