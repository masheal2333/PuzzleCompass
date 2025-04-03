import SwiftUI

// 帮助说明视图
struct HelpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("如何使用拼图定位功能")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    featuresSection
                    
                    Divider()
                    
                    tipsSection
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .fontWeight(.semibold)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 子视图组件
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("•")
                Text("彩色框表示碎片在完整拼图中的位置")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("点击底部的碎片可以高亮显示对应的匹配位置")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("双指捏合可以放大或缩小拼图视图")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("单指拖动可以移动拼图视图")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("点击\"重置\"按钮可以恢复原始视图")
            }
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("提示")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(alignment: .top) {
                Text("•")
                Text("拼图照片越清晰，识别结果越准确")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("光线充足的环境下拍摄效果最佳")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("避免拍摄时产生阴影或反光")
            }
        }
    }
} 