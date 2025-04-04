import SwiftUI

/// Onboarding view displayed the first time the app is launched
struct OnboardingView: View {
    @Binding var isShowingOnboarding: Bool
    
    // Current page
    @State private var currentPage = 0
    
    // Onboarding pages
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Puzzle Compass",
            description: "Helping you find where puzzle pieces belong in the complete puzzle",
            imageName: "puzzle.fill"
        ),
        OnboardingPage(
            title: "Step 1: Capture Puzzle",
            description: "First take a photo or select an image of the complete puzzle",
            imageName: "camera.fill"
        ),
        OnboardingPage(
            title: "Step 2: Capture Pieces",
            description: "Take photos or select images of puzzle pieces you want to locate",
            imageName: "photo.on.rectangle"
        ),
        OnboardingPage(
            title: "Step 3: View Results",
            description: "The app will analyze and show you where the pieces fit in the puzzle",
            imageName: "magnifyingglass"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.background
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Navigation buttons
                HStack {
                    // Skip button
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            isShowingOnboarding = false
                        }
                        .foregroundColor(.primary)
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Next/Done button
                    Button(currentPage < pages.count - 1 ? "Next" : "Get Started") {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            isShowingOnboarding = false
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.primary)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}

/// Individual onboarding page
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: page.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(.primary)
                .padding(.top, 50)
            
            // Title
            Text(page.title)
                .font(.largeTitle)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Description
            Text(page.description)
                .font(.mediumText)
                .foregroundColor(.primary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

/// Onboarding page data
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
} 