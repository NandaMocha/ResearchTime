import SwiftUI

class StartPageViewModel: ObservableObject {
    let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
}
