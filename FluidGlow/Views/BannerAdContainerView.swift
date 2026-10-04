import SwiftUI

public struct BannerAdContainerView: View {
    @StateObject private var proManager = ProFeatureManager.shared
    
    public init() {}
    
    public var body: some View {
        if !proManager.isVIP {
            HStack {
                Spacer()
                Text("AdMob Adaptive Banner • 320x50")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
            }
            .frame(height: 50)
            .background(Color.black.opacity(0.8))
        }
    }
}
