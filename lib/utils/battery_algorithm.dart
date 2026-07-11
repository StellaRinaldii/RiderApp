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
  // level of the subject: Beginner ~160 bpm, Intermediate ~140 bpm,
  // Advanced ~110 bpm.
  int estimateExerciseHeartRate(String fitnessLevel) {
    if (fitnessLevel == "Intermediate") {
      return 160;
    } else if (fitnessLevel == "Advanced") {
      return 130;
    }
    return 180; // beginner (default)
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
  int lossEstimationLinear(String fitnessLevel, int timeExercise) {
    int fitnessLevelValue = 2;
    if (fitnessLevel == "Intermediate") {
      fitnessLevelValue = 1;
    } else if (fitnessLevel == "Advanced") {
      fitnessLevelValue = 0;
    }

    // coefficients of the linear model
    double a0 = 5;
    double a1 = 0.25;
    // nel caso si volesse si può anche aggiungere un dislivello o altre info
    //double a2 = ;

    double loss = a0 * fitnessLevelValue + a1 * timeExercise;
    return loss.round().clamp(1, 100).toInt();
  }

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

  // Applies a battery gain (e.g. from sleep recovery) to the current level.
  void batterygain(int efficiency, double sleeptime) {
    // efficiency must be a %
    // sleeptime is in minutes
    double sleepHours = sleeptime / 60;
    double gain = (efficiency * sleepHours / 8);

    // first update the battery level, then clamp it
    batteryLevel = batteryLevel + gain.toInt();
    if (batteryLevel > maxLevel) {
      batteryLevel = maxLevel;
    }
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