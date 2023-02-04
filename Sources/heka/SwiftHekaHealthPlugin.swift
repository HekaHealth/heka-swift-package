class HekaManager {
  let healthStore = HealthStore()

  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    healthStore.requestAuthorization { success in
      completion(success)
    }
  }

  func checkHealthKitPermissions() -> Bool {
    return healthStore.checkHealthKitPermissions()
  }

  func syncIosHealthData(apiKey: String, userUuid: String, completion: @escaping (Bool) -> Void) {
    healthStore.requestAuthorization { success in
      if success {
        // Setup observer query
        self.healthStore.setupStepsObserverQuery(apiKey: apiKey, userUuid: userUuid)
        completion(true)
      } else {
        completion(false)
      }
    }
  }
}
