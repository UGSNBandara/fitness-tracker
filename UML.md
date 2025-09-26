classDiagram
direction LR

class User {
  +UUID userId
  +String name
  ```mermaid
  classDiagram
  direction LR

  class User {
    +UUID userId
    +String name
    +String email
    +UserLevel level
    +double height
    +double weight
    +Date dob
    +String gender
    +createAccount()
    +updateProfile()
  }

  class AuthService {
    +signIn(email,pw)
    +signUp()
    +signOut()
  }

  class FoodItem {
    +UUID foodId
    +String name
    +String brand
    +String servingSize
    +String barcode
  }

  class Nutrient {
    +double calories
    +double carbs
    +double protein
    +double fat
    +double fiber
    +double sugar
    +double sodium
  }

  class MealLog {
    +UUID logId
    +DateTime dateTime
    +double portion
    +MealSource source
    +totalCalories() double
  }

  class MealEntry {
    +double qty
  }

  class FoodDatabase {
    +searchByName(q)
    +lookupBarcode(code)
  }

  class FoodRecognitionModel {
    +detectFood(image) List<FoodItemProb>
  }

  class NutritionEstimator {
    +estimatePortion(image) double
  }

  class ExercisePlan {
    +UUID planId
    +UserLevel level
    +String name
    +String desc
  }

  class Workout {
    +UUID workoutId
    +Date date
    +WorkoutStatus status
  }

  class Exercise {
    +UUID exerciseId
    +String name
    +String muscleGroup
  }

  class WorkoutExercise {
    +int sets
    +int reps
    +int restSec
  }

  class ExerciseLog {
    +DateTime start
    +DateTime end
    +int repsDone
    +int rpe
  }

  class ExerciseCountingModel {
    +countReps(stream) int
  }

  class ProgressAnalyzer {
    +computeAdherence(user) double
    +updateLevel(user) UserLevel
  }

  class Goal {
    +UUID goalId
    +GoalType type
    +double target
    +Period period
  }

  class NotificationService {
    +scheduleReminder(user, type)
    +sendPush(msg)
  }

  class SyncService {
    +syncToCloud(entity)
    +offlineCache()
  }

  class UserLevel {
    <<enum>>
    BEGINNER
    INTERMEDIATE
    ADVANCED
  }
  class MealSource {
    <<enum>>
    MANUAL
    CAMERA
    BARCODE
  }
  class WorkoutStatus {
    <<enum>>
    PLANNED
    IN_PROGRESS
    DONE
  }
  class GoalType {
    <<enum>>
    WEIGHT
    CALORIES
    PROTEIN
    STEPS
    WORKOUTS_PER_WEEK
  }

  AuthService ..> User : authenticates
  User "1" --> "*" MealLog
  User "1" --> "*" ExerciseLog
  User "1" --> "*" Goal
  User "1" --> "1" ExercisePlan : selects

  MealLog "1" -- "" MealEntry
  MealEntry "*" --> "1" FoodItem
  FoodItem "1" --> "1" Nutrient
  FoodDatabase ..> FoodItem : provides

  FoodRecognitionModel ..> MealLog : suggests entries
  NutritionEstimator ..> MealLog : estimates portion

  ExercisePlan "1" --> "*" Workout : template
  Workout "1" --> "*" WorkoutExercise
  WorkoutExercise "*" --> "1" Exercise

  ExerciseLog "*" --> "1" Exercise
  ExerciseCountingModel ..> ExerciseLog : counts reps

  ProgressAnalyzer ..> User : updates level
  NotificationService ..> User : reminds
  SyncService ..> User
  SyncService ..> MealLog
  SyncService ..> ExerciseLog

  MealSource ..> MealLog : uses
  WorkoutStatus ..> Workout : uses
  GoalType ..> Goal : uses
  ```
ExercisePlan "1" --> "*" Workout : template
Workout "1" --> "*" WorkoutExercise
WorkoutExercise "*" --> "1" Exercise

ExerciseLog "*" --> "1" Exercise
ExerciseCountingModel ..> ExerciseLog : counts reps

ProgressAnalyzer ..> User : updates level
NotificationService ..> User : reminds
SyncService ..> User
SyncService ..> MealLog
SyncService ..> ExerciseLog

MealSource ..> MealLog : uses
WorkoutStatus ..> Workout : uses
GoalType ..> Goal : uses