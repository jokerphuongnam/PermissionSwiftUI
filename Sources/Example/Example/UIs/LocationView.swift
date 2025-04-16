import SwiftUI

struct NoticationView: View {
    
    var body: some View {
        Text("We need permission to use your location")
            .requestPermission(.location(for: .location)) { authorizedPermission in
                Text("\(authorizedPermission)")
            } failure: { error in
                VStack {
                    Text("Permission fail")
                    Text(error.localizedDescription)
                }
            }
    }
}
