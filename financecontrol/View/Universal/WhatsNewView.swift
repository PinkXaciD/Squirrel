//
//  WhatsNewView.swift
//  Squirrel
//
//  Created by PinkXaciD on 2025/01/11.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.openURL)
    private var openURL
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    
    @ScaledMetric
    private var imageSize: CGFloat = 50
    @ScaledMetric
    private var buttonSize: CGFloat = 50
    
    @State
    private var showConfirmationDialog: Bool = false
    
    var showSmallHeader: Bool {
        UIApplication.shared.keyWindow?.safeAreaInsets.bottom == 0 // Check if device has a home button
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if showSmallHeader || dynamicTypeSize > .xLarge {
                    Spacer()
                    
                    smallHeader
                } else {
                    largeHeader
                }
                
                Spacer()
                
                getRow(imageName: "list.bullet", title: "Place Suggestions", subtitle: "Squirrel will now show a list of suggestions while you entering place")
                
                Spacer()
                
                Button("Full Changelog on GitHub") {
                    showConfirmationDialog.toggle()
                }
                .confirmationDialog(URL.githubChangelog.absoluteString, isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                    Button("Open in Browser") {
                        openURL(URL.githubChangelog)
                    }
                    
                    Button("Copy to Clipboard") {
                        UIPasteboard.general.url = URL.githubChangelog
                    }
                } message: {
                    Text("Full Changelog")
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(.orange)
        .accentColor(.orange)
    }
    
    private var smallHeader: some View {
        HStack {
            if #available(iOS 26.0, *) {
                Image(.onboarding)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 15))
                
            } else {
                Image(.onboarding)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 1)
                            .foregroundColor(.primary)
                            .opacity(0.3)
                    }
            }
            
            Text("What's new in \(Text("Squirrel \(Bundle.main.releaseVersionNumber ?? "")").foregroundColor(.orange))")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.leading)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var largeHeader: some View {
        VStack {
            if #available(iOS 26.0, *) {
                ViewThatFits {
                    Image(.onboarding)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 30))
                    
                    Image(.onboarding)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .aspectRatio(contentMode: .fit)
                        .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 30))
                }
                
            } else if #available(iOS 16.0, *) {
                ViewThatFits {
                    Image(.onboarding)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.primary)
                                .opacity(0.3)
                        }
                    
                    Image(.onboarding)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.primary)
                                .opacity(0.3)
                        }
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                Image(.onboarding)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(lineWidth: 1)
                            .foregroundColor(.primary)
                            .opacity(0.3)
                    }
                    .aspectRatio(contentMode: .fit)
            }
            
            Text("What's new in \(Text("Squirrel \(Bundle.main.releaseVersionNumber ?? "")").foregroundColor(.orange))")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    private func getNavLinkRow<Content>(
        imageName: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey?,
        destination: Content
    ) -> some View where Content: View {
        let label = getRow(imageName: imageName, title: title, subtitle: subtitle)
        
        NavigationLink {
            destination
        } label: {
            HStack {
                label
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.secondary)
            }
            .background(.background)
        }
        .buttonStyle(CustomButtonStyle())
    }
    
    @ViewBuilder
    private func getRow(
        imageName: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey?
    ) -> some View {
        HStack(spacing: 15) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(.tint)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                if let subtitle {
                    Text(subtitle)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
//        .minimumScaleFactor(0.8)
    }
    
    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
        }
    }
}

//fileprivate struct NewIconRow: View {
//    @ScaledMetric
//    private var imageSize: CGFloat = 50
//    @State
//    private var imageResource: ImageResource = .appIcon
//    
//    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(imageResource)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: imageSize, height: imageSize)
//                .foregroundStyle(.tint)
//                .shadow(color: .black.opacity(0.2), radius: 2.5, y: 1)
//                .animation(.default, value: imageResource)
//            
//            VStack(alignment: .leading) {
//                Text("Refreshed Icons")
//                    .font(.title3.bold())
//                    .foregroundColor(.primary)
//                    .multilineTextAlignment(.leading)
//                
//                Text("Updated icons with Liquid Glass")
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .onReceive(timer) { _ in
//            switch imageResource {
//            case .appIcon:
//                imageResource = .appIconFirstFlight
//            case .appIconFirstFlight:
//                imageResource = .appIconNA
//            default:
//                imageResource = .appIcon
//            }
//        }
//    }
//}

#Preview {
    NavigationView {
        Rectangle()
            .sheet(isPresented: .constant(true)) {
                WhatsNewView()
                    .tint(.orange)
            }
    }
}
