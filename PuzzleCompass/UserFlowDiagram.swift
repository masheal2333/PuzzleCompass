import SwiftUI

struct UserFlowDiagram: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("用户流程图")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("主要流程")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.down")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    
                    FlowStep(title: "启动应用", description: "用户打开应用，看到主屏幕")
                    
                    FlowBranch(leftTitle: "选择拍摄完整拼图", rightTitle: "选择拍摄拼图碎片")
                    
                    HStack(alignment: .top, spacing: 30) {
                        // 左侧分支
                        VStack(spacing: 8) {
                            FlowStep(title: "拍摄/选择完整拼图", description: "用户拍摄或从相册选择已完成的拼图照片")
                            
                            Image(systemName: "arrow.down")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                            
                            FlowStep(title: "跳转到拍摄碎片", description: "提示用户继续拍摄碎片")
                        }
                        .frame(maxWidth: .infinity)
                        
                        // 右侧分支
                        VStack(spacing: 8) {
                            FlowStep(title: "拍摄/选择碎片", description: "用户可以添加一个或多个拼图碎片")
                            
                            Image(systemName: "arrow.down")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                            
                            FlowStep(title: "跳转到完整拼图", description: "如果用户还未上传完整拼图照片")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Image(systemName: "arrow.down")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    
                    FlowStep(title: "开始定位", description: "应用分析拼图和碎片，计算匹配位置")
                    
                    Image(systemName: "arrow.down")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    
                    FlowStep(title: "显示结果", description: "在完整拼图上标记出碎片的位置并可交互")
                    
                    Image(systemName: "arrow.down")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    
                    FlowStep(title: "查看详情/保存/分享", description: "用户可以缩放查看、保存结果或分享")
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(15)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct FlowStep: View {
    var title: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct FlowBranch: View {
    var leftTitle: String
    var rightTitle: String
    
    var body: some View {
        HStack(spacing: 30) {
            VStack {
                Image(systemName: "arrow.down.left")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text(leftTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            
            VStack {
                Image(systemName: "arrow.down.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text(rightTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    UserFlowDiagram()
} 