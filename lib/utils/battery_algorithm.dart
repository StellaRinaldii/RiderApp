import "dart:math";

class Battery {
  // instances
  int batteryLevel;
  int maxLevel = 100;
  int minLevel = 5;

  // constructors
  Battery({this.batteryLevel = 100});

  // Estimates the resting heart rate from age/sex, then adjusts it slightly
  // based on fitness level (fitter subjects tend to have a lower RHR).
  // Baseline values are taken from the paper: "Resting Pulse Rate Reference
  // Data for Children, Adolescents, and Adults: United States, 1999-2008".
  int estimateRestingHeartRate(int age, String sex, String fitnessLevel) {
    num hrrest = 75; // baseline value

    if (sex == "Male") {
      if (age <= 19) {
        hrrest = 72;
      } else if (age <= 39) {
        hrrest = 71;
      } else if (age <= 59) {
        hrrest = 71;
      } else if (age <= 79) {
        hrrest = 70;
      } else {
        hrrest = 71;
      }
    } else if (sex == "Female") {
      if (age <= 19) {
        hrrest = 79;
      } else if (age <= 39) {
        hrrest = 76;
      } else if (age <= 59) {
        hrrest = 73;
      } else if (age <= 79) {
        hrrest = 73;
      } else {
        hrrest = 73;
      }
    } else { 
      if (age <= 19) {
        hrrest = 75;
      } else if (age <= 39) {
        hrrest = 73;
      } else if (age <= 59) {
        hrrest = 72;
      } else if (age <= 79) {
        hrrest = 72;
      } else {
        hrrest = 72;
      }
    }

    // reduction of RHR based on the subject's fitness level
    if (fitnessLevel == "Intermediate") {
      hrrest = hrrest - 2.5;
    } else if (fitnessLevel == "Advanced") {
      hrrest = hrrest - 5;
    }

    return hrrest.round();
  }

  // Exercise heart rate is estimated automatically based on the fitness
  // level of the subject: Beginner ~185 bpm, Intermediate ~165 bpm,
  // Advanced ~145 bpm.
  int estimateExerciseHeartRate(String fitnessLevel) {
    if (fitnessLevel == "Intermediate") {
      return 165;
    } else if (fitnessLevel == "Advanced") {
      return 145;
    }
    return 185; // beginner (default)
  }

  // Estimates the battery reduction of a delivery BEFORE it is completed,
  // based only on the subject's profile (age, fitness level, sex), since
  // no real heart rate data is available yet at this stage.
  int lossEstimation(int age, String fitnessLevel, int timeExercise, String sex) {
    num hrmax = 220 - age;
    int hrrest = estimateRestingHeartRate(age, sex, fitnessLevel);
    int hrex = estimateExerciseHeartRate(fitnessLevel);

    // compute the TRIMP/min
    double ratio = (hrex - hrrest) / (hrmax - hrrest);
    double trimpMin = ratio * 0.64 * exp(1.92 * ratio);

    // compute the loss of battery
    double loss = (15 * trimpMin) / 2.2 * timeExercise/60;
    return loss.round().clamp(1, 100).toInt();
  }

  // Simplified linear alternative to lossEstimation.

  /*int lossEstimationLinear(String fitnessLevel, int timeExercise, int age, String sex,) {
  int fitnessLevelValue = 2;

  if (fitnessLevel == "Intermediate") {
    fitnessLevelValue = 1;
  } else if (fitnessLevel == "Advanced") {
    fitnessLevelValue = 0;
  }

  int sexValue = 0;
  if (sex == "Female") {
    sexValue = 1;
  } else if (sex == "Male") {
    sexValue = 0;
  } else {
    sexValue = 0;
  }

  // coefficients of the linear model
  double a0 = 10;     // effect of fitness level
  double a1 = 0.25;  // effect of exercise duration
  double a2 = 0.08;  // effect of age
  double a3 = 2;     // small correction for sex

  double loss = a0 * fitnessLevelValue + a1 * timeExercise + a2 * age + a3 * sexValue;
  return loss.round().clamp(1, 100).toInt();
}*/

  // Computes the REAL battery reduction AFTER a delivery is completed,
  // using the real average exercise heart rate of the activity and the
  // resting heart rate of that specific day.
  int computeRealBatteryLoss(int age, int hrex, int hrrest, int timeExercise) {
    num hrmax = 220 - age;

    // compute the TRIMP/min
    double ratio = (hrex - hrrest) / (hrmax - hrrest);
    double trimpMin = ratio * 0.64 * exp(1.92 * ratio);

    // compute the loss of battery
    double loss = (15 * trimpMin) / 2.2 * timeExercise/60;

    return loss.round().clamp(1, 100).toInt();
  }

  int computeSleepGain(int efficiency, double sleeptime) {
    double sleepHours = sleeptime / 60;
    double gain = efficiency * sleepHours / 8;
    return gain.round();
}


  // Applies an already-computed battery loss to the current level.
  void batteryloss(int loss) {
    // first update the battery level, then clamp it
    batteryLevel = batteryLevel - loss;
    if (batteryLevel < minLevel) {
      batteryLevel = minLevel;
    }
  }
}