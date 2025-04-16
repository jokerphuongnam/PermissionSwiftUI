import SwiftUI
import PermissionSwiftUI

struct ContentView: View {
    @State private var isShowNotificationPermission = false
    @State private var paths: [Route] = []
    
    var body: some View {
        NavigationStack(path: $paths) {
            List {
                Button {
                    isShowNotificationPermission.toggle()
                } label: {
                    Text("Notification")
                }
                .overlay {
                    if isShowNotificationPermission {
                        Color.clear.requestPermission(.notification(options: [.alert])) { result in
                            print(result)
                            isShowNotificationPermission.toggle()
                        }
                    }
                }
                
                Button {
                    paths.append(.location)
                } label: {
                    Text("Location")
                }
            }
            .listStyle(.plain)
            .navigationTitle("Request notification")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .location:
                    NoticationView()
                }
            }
        }
    }
}
