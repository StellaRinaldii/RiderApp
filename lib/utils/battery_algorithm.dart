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

  int lossEstimation(int age, String fitnessLevel, int timeExercise, String sex) {
    /* resting HR obtained form the table of paper: "Resting Pulse Rate Reference Data for Children, 
    Adolescents, and Adults: United States, 1999–2008", It is then reduced based on the fitness level
    of 2 or 5 bpm. Exercise heart rate is settled automatically based on the fitness level of the subject:
    if the subject is highly trained, HR ex = 110, if it's trained = 140, if its not trained = 160.*/
    
    num hrmax = 220 - age;
    num hrrest = 75; // baseline value
    num hrex = 160; //fitness level = beginner

    if (sex == "Male") {

      if (age <=19){
        hrrest = 72;
      } else if (age > 19 && age <= 39){
        hrrest = 71;
      } else if (age > 39 && age <= 59){
        hrrest = 71;
      } else if (age > 59 && age <= 79){
        hrrest = 70;
      } else {
        hrrest = 71;
      }

    } else if (sex == "Female") {

      if (age <=19){
        hrrest = 79;
      } else if (age > 19 && age <= 39){
        hrrest = 76;
      } else if (age > 39 && age <= 59){
        hrrest = 73;
      } else if (age > 59 && age <= 79){
        hrrest = 73;
      } else {
        hrrest = 73;
      }

    } else {

      if (age <=19){
        hrrest = 75;
      } else if (age > 19 && age <= 39){
        hrrest = 73;
      } else if (age > 39 && age <= 59){
        hrrest = 72;
      } else if (age > 59 && age <= 79){
        hrrest = 72;
      } else {
        hrrest = 72;
      }

    }

    // reduction of RHR and HR ex based on the subject's fitness:
    if (fitnessLevel == "Intermediate") {
      hrrest = hrrest - 2.5; 
      hrex = 140;
    } else if (fitnessLevel == "Advanced") {
      hrrest = hrrest - 5;
      hrex = 110;
    }

    
    // compute the TRIMP/min
    double ratio = (hrex - hrrest)/(hrmax - hrrest);
    double trimpMin = ratio*0.64*exp(1.92 * ratio);

    // compute the loss of bactery
    double loss = (15 * trimpMin)/2.2*timeExercise;
    return loss.toInt();

  }

  int lossEstimationLinear(String fitnessLevel,  int timeExercise ){
    int fitnesslevel = 2;
    if (fitnessLevel == "Intermediate"){
      fitnesslevel = 1;
    } else if (fitnessLevel == "Advanced"){
      fitnesslevel = 0;
    }

    // coefficients of the linear model
    double a0 = 5;
    double a1 = 0.25;
    // nel caso si volesse si può anche aggiungere un dislivello o altre info
    //double a2 = ;
    
    double loss = a0 * fitnesslevel + a1* timeExercise;
    return loss.toInt();

  }


}


