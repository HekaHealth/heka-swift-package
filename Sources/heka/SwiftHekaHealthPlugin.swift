class HekaManager {
  func requestAuthorization() -> Bool {
    let healthStore = HealthStore()
    healthStore.requestAuthorization {
      success in
      if success {
        return true
      } else {
        return false
      }
    }
  }

  func checkHealthKitPermissions() -> bool {
    let healthStore = HealthStore()
    return healthStore.checkHealthKitPermissions()
  }

  func syncIosHealthData(apiKey: String, userUuid: String) -> bool {
    let healthStore = HealthStore()
    healthStore.requestAuthorization {
      success in
      if success {
        // Setup observer query
        healthStore.setupStepsObserverQuery(apiKey: apiKey, userUuid: userUuid)
        return true
      } else {
        return false
      }
    }
  }
}
