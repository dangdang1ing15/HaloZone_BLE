import SwiftUI

struct NearbyHaloButtonView: View {
    @State private var showHalos = false
    @Binding var isHaloEnabled: Bool
    @State private var navigateToEdit = false
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack {
            if isHaloEnabled {
                // 헤일로존 활성화 상태일 때: 상태 메시지 형태
                Button {
                    navigateToEdit = true
                } label: {
                    VStack(spacing: 4) {
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(Color(.gray).opacity(0.5))
                            .padding(.bottom, 5)
                        
                        Text("내 상태 메시지")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("상태메시지 작성시각 : 16:52")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(height: 75)
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
                    .preferredColorScheme(.dark)
                    .cornerRadius(20)
                    .padding()
                }
                
                NavigationLink(destination: EditProfile(), isActive: $navigateToEdit) {
                    EmptyView()
                }
                
            } else {
                // 기본 상태일 때: 내 주변 천사들
                VStack{
                    VStack {
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(Color(red: 0.40, green: 0.40, blue: 0.40, opacity: 0.5))
                            .padding(.bottom, 5)
                        
                        Text("내 주변 천사들")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("10미터 이내 3명")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(height: 75)
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
                    .preferredColorScheme(.dark)
                    .cornerRadius(20)
                    .padding()
                    .onTapGesture {
                        showHalos.toggle()
                    }
                    }
                .sheet(isPresented: $showHalos) {
                    ZStack {
                        NearbyHaloSheetView()
                    }
                    .presentationDetents([.fraction(9/10)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(30)
                    .presentationBackground(.thinMaterial)
                    .preferredColorScheme(.dark)
                    .safeAreaPadding()
                }
                }
        }
    }
}
