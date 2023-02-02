class HekaManager {
  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    let healthStore = HealthStore()
    healthStore.requestAuthorization { success in
      completion(success)
    }
  }

  func checkHealthKitPermissions() -> Bool {
    let healthStore = HealthStore()
    return healthStore.checkHealthKitPermissions()
  }

  func syncIosHealthData(apiKey: String, userUuid: String, completion: @escaping (Bool) -> Void) {
    let healthStore = HealthStore()
    healthStore.requestAuthorization { success in
      if success {
        // Setup observer query
        healthStore.setupStepsObserverQuery(apiKey: apiKey, userUuid: userUuid)
        completion(true)
      } else {
        completion(false)
      }
    }
  }
}
