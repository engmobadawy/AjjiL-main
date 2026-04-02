import SwiftUI

struct SlideToStartButton: View {
 
    private let themeColor = Color(.brandGreen)
    private let handleSize: CGFloat = 64
    private let padding: CGFloat = 8
    private let height: CGFloat = 80

    // MARK: - State
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    @State private var didComplete = false

    // MARK: - Action
    let onSwipeSuccess: () -> Void



    var body: some View {
        GeometryReader { proxy in
            let trackWidth = proxy.size.width
            let maxSlideDistance = max(0, trackWidth - handleSize - (padding * 2))

            ZStack(alignment: .leading) {
                TrackView(
                    themeColor: themeColor,
                    isDragging: isDragging,
                    height: height
                )

                if !didComplete {
                    Text("Start Experience")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .opacity(fadeOpacity(maxDistance: maxSlideDistance))
                        .animation(.easeOut(duration: 0.25), value: offset)
                }

                HandleView(size: handleSize)
                    .offset(x: offset)
                    .padding(.leading, padding)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDragChange(value, limit: maxSlideDistance)
                            }
                            .onEnded { value in
                                handleDragEnd(value, limit: maxSlideDistance)
                            }
                    )
            }
            .frame(height: height)
        }
        .frame(height: height)
        .padding()
        .sensoryFeedback(.success, trigger: didComplete)
        .sensoryFeedback(.impact(weight: .light), trigger: isDragging)
    }

    // MARK: - Logic

    private func handleDragChange(_ value: DragGesture.Value, limit: CGFloat) {
        guard !didComplete else { return }
        isDragging = true

        let newOffset = value.translation.width
        offset = min(max(newOffset, 0), limit)
    }

    private func handleDragEnd(_ value: DragGesture.Value, limit: CGFloat) {
        guard !didComplete else { return }
        isDragging = false

        if offset > limit * 0.9 {
            completeAction(limit: limit)
        } else {
            resetHandle()
        }
    }

    private func completeAction(limit: CGFloat) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            offset = limit
            didComplete = true
        }

        // Swift Concurrency best practice
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            onSwipeSuccess()
        }
    }

    private func resetHandle() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            offset = 0
        }
    }

    private func fadeOpacity(maxDistance: CGFloat) -> Double {
        guard maxDistance > 0 else { return 1 }
        let progress = offset / maxDistance
        return max(0, 1.0 - (progress * 2.0))
    }
}



private struct TrackView: View {
    let themeColor: Color
    let isDragging: Bool
    let height: CGFloat

    var body: some View {
        Capsule()
            .fill(themeColor)
            .frame(height: height)
            .scaleEffect(isDragging ? 0.98 : 1.0)
            .animation(.spring(duration: 0.2), value: isDragging)
    }
}

private struct HandleView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

            ChevronIndicator()
        }
        .frame(width: size, height: size)
    }
}

private struct ChevronIndicator: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: -4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black.opacity(0.75))
                    .opacity(animate ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 1.0)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SlideToStartButton {
            print("Swiped ")
        }
    }
}

