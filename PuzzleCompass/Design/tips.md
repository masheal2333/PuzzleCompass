# PuzzleCompass项目规范

## ⚠️ 重要提示 [CURSOR PRIORITY]
```
🔴 本应用面向美国市场，所有UI界面文本必须使用英文
🔴 开发过程中所有按钮、标签、提示、错误信息等用户可见文本必须是英文
🔴 本文档可以使用中文进行说明，但实际开发代码中的所有字符串必须翻译成英文
```

## 界面文本英文翻译参照表 [CURSOR REFERENCE]

### 主界面文本
| 中文                | 英文                             |
|--------------------|----------------------------------|
| 拼图定位            | Puzzle Compass                   |
| 拍摄完整拼图        | Capture Complete Puzzle          |
| 从相册选择          | Select from Album                |
| 拍摄完整拼图和碎片进行匹配 | Capture puzzle and pieces for matching |
| 从相册选择拼图和碎片进行匹配 | Select puzzle and pieces from album |

### 相机界面文本
| 中文                | 英文                             |
|--------------------|----------------------------------|
| 现在请拍摄碎片      | Now Capture Pieces               |
| 请确保碎片放在中央，光线充足 | Place pieces in center with good lighting |
| 确认               | Confirm                          |
| 重拍               | Retake                           |
| 无法识别拼图，请重试 | Puzzle recognition failed, please try again |

### 相册界面文本
| 中文                | 英文                             |
|--------------------|----------------------------------|
| 选择拼图            | Select Puzzle                    |
| 选择碎片            | Select Pieces                    |
| 请选择一张完整拼图照片 | Please select a complete puzzle photo |
| 请选择一张或多张拼图碎片照片 | Please select one or more puzzle pieces |
| 取消               | Cancel                           |
| 确认               | Confirm                          |
| 无法识别拼图，请选择其他图片 | Puzzle recognition failed, please select another image |

### 结果界面文本
| 中文                | 英文                             |
|--------------------|----------------------------------|
| 拼图结果            | Puzzle Result                    |
| 拍摄更多碎片        | Capture More Pieces              |
| 完成               | Done                             |
| 无法匹配碎片，请重试 | Piece matching failed, please try again |

## 项目基本信息
- **项目名称**: 拼图定位 (PuzzleCompass)
- **平台**: iOS (SwiftUI)
- **目标**: 帮助用户确定拼图碎片在完整拼图中的位置

## 核心功能要求
- 拍摄/上传完整拼图作为参考
- 拍摄/上传一个或多个拼图碎片
- 分析并标记碎片在完整拼图中的位置
- 多碎片时区分显示各个碎片位置
- 提供缩放和高亮查看功能
- 从照片自动扣取完整拼图

## 技术规范
- 开发框架: SwiftUI
- 设计规范: iOS原生风格
- 支持深色/浅色模式
- 屏幕适配: 支持各种iPhone屏幕尺寸
- 图像处理: Vision框架、CoreML

## UI设计规范
- **风格**: 现代简约风格
- **颜色**: 
  - 主色: #4A90E2
  - 强调色: #50E3C2
  - 背景色: #F7F7F7
  - 文本色: #333333
- **字体**:
  - 标题字体: SF Pro Display Bold (17pt)
  - 正文字体: SF Pro Text Regular (14pt)
  - 辅助字体: SF Pro Text Regular (12pt)
- **间距**:
  - 标准边距: 16pt
  - 元素间距: 8pt

## 用户流程
### 1. **拍摄流程**
1. 用户从主屏幕点击"拍摄完整拼图"按钮
2. 进入相机界面，看到相机预览和拍摄按钮
3. 用户拍摄完整拼图照片
4. 系统自动识别并扣取照片中的拼图（矩形区域）
5. 显示确认界面，用户确认后保存
6. 自动切换到拍摄碎片模式，显示提示"现在请拍摄碎片"
7. 用户拍摄碎片照片
8. 用户确认碎片照片
9. 系统自动分析碎片在完整拼图中的位置
10. 跳转到结果界面，高亮显示匹配位置

### 2. **相册流程**
1. 用户从主屏幕点击"从相册选择"按钮
2. 打开系统相册选择器
3. 用户选择一张完整拼图照片
4. 系统自动识别并扣取照片中的拼图
5. 显示确认界面，用户确认后继续
6. 自动提示用户选择碎片照片
7. 用户从相册选择一张或多张碎片照片
8. 用户确认碎片照片
9. 系统自动分析碎片在完整拼图中的位置
10. 跳转到结果界面，高亮显示匹配位置

### 3. **结果操作流程**
1. 结果界面显示完整拼图，并高亮显示匹配到的碎片位置
2. 如果有多个碎片，使用不同颜色或编号标记区分
3. 用户可以通过捏合手势缩放查看匹配细节
4. 界面底部有"拍摄更多碎片"按钮
5. 用户点击"拍摄更多碎片"按钮
6. 系统跳转到相机界面（保持当前拼图）
7. 用户拍摄新的碎片
8. 系统分析新碎片并返回结果界面
9. 结果界面实时更新，显示所有碎片的匹配位置
10. 界面右上角有"完成"按钮，点击返回主屏幕

## 设计细节

### 主屏幕设计
- 两个主要按钮：突出显示的"拍摄完整拼图"和"从相册选择"
- 操作按钮使用大尺寸卡片式设计，配有图标
- 布局居中，间距合理

### 相机界面设计
- 相机预览占据大部分屏幕空间（全屏显示）
- 底部控制栏：中央大型拍摄按钮、左侧闪光灯控制、右侧切换相册
- 拍摄完整拼图后，界面顶部显示"现在拍摄碎片"提示条
- 拍摄时显示取景辅助线，帮助用户对齐

### 结果界面设计 
- 上半部分显示完整拼图，占据70%屏幕空间
- 在完整拼图上用荧光色高亮显示碎片匹配位置
- 底部区域（30%屏幕）显示已分析的碎片缩略图
- 多碎片时，每个碎片有不同颜色边框标记
- 底部按钮："拍摄更多碎片"（主色调）
- 右上角："完成"按钮（普通文字按钮）

### 错误处理设计
- 识别失败时显示简短提示："无法识别拼图碎片，请重试"
- 提供视觉引导，如"请确保碎片放在中央，光线充足"
- 错误提示使用轻量级toast样式，3秒后自动消失

# Cursor开发指南

## 文件结构
```
PuzzleCompass/
├── App/
│   ├── PuzzleCompassApp.swift
│   └── AppState.swift
├── Views/
│   ├── Main/
│   │   ├── MainView.swift
│   │   └── MainViewModel.swift
│   ├── Camera/
│   │   ├── CameraView.swift
│   │   ├── PhotoPickerView.swift
│   │   ├── GuidanceView.swift
│   │   ├── ConfirmationView.swift  # 新增：拍摄确认视图
│   │   └── CameraOverlayView.swift # 新增：相机辅助叠加层
│   ├── Result/
│   │   ├── ResultView.swift
│   │   ├── HighlightView.swift
│   │   ├── MultiPieceView.swift
│   │   ├── ZoomableImageView.swift
│   │   └── PieceThumbnailView.swift # 新增：碎片缩略图视图
│   └── Shared/
│       ├── ToastView.swift          # 新增：轻量级提示视图
│       └── LoadingView.swift        # 新增：加载指示器视图
├── Models/
│   ├── Puzzle.swift
│   ├── PuzzlePiece.swift
│   └── AnalysisResult.swift
├── Services/
│   ├── ImageStorage.swift
│   ├── PuzzleExtractor.swift
│   ├── VisionService.swift
│   ├── PuzzleMatcher.swift
│   ├── MultiPieceMatcher.swift
│   ├── ResultGenerator.swift
│   └── ErrorHandler.swift
├── Utils/
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Theme.swift
│   └── ImageProcessor.swift
└── Resources/
```

## 核心数据模型

### 数据模型概述
```swift
// 核心数据模型结构
struct Puzzle: Identifiable, Codable {
    var id: UUID
    var image: Data
    var createdAt: Date
    var imageSize: CGSize
}

struct PuzzlePiece: Identifiable, Codable {
    var id: UUID
    var image: Data
    var createdAt: Date
    var puzzleId: UUID?
}

struct AnalysisResult: Identifiable, Codable {
    var id: UUID
    var puzzle: Puzzle
    var pieces: [PuzzlePiece]
    var matches: [Match]
    var createdAt: Date
    
    struct Match: Codable {
        var pieceId: UUID
        var location: CGRect
        var confidence: Float
    }
}
```

### 应用状态管理概述
```swift
// AppState核心功能
class AppState: ObservableObject {
    // 核心枚举与状态
    enum AppScreen { case main, camera(mode: CameraMode), result }
    enum CameraMode { case puzzle, piece }
    enum CameraSource { case camera, photoLibrary }
    
    // 状态变量
    @Published var currentScreen: AppScreen = .main
    @Published var currentPuzzle: Puzzle?
    @Published var currentPieces: [PuzzlePiece] = []
    @Published var cameraSource: CameraSource = .camera
    @Published var analysisInProgress: Bool = false
    
    // 导航方法
    func navigateToCamera(mode: CameraMode, source: CameraSource = .camera) { /* 实现导航 */ }
    func navigateToResult() { /* 实现导航 */ }
    func navigateToMain() { /* 实现导航 */ }
    
    // 数据处理方法
    func savePuzzle(_ puzzle: Puzzle) { /* 保存拼图 */ }
    func addPiece(_ piece: PuzzlePiece) { /* 添加碎片 */ }
    func analyzeCurrentPieces() -> Bool { /* 分析当前碎片 */ }
}
```

## 顺序开发任务清单

### 阶段1: 项目初始化 [当前阶段]
- [ ] **Task 1.1: 创建项目基础**
  - 文件: 新建SwiftUI项目
  - 创建基本目录结构
  - 完成后执行: Task 1.2

- [ ] **Task 1.2: 实现颜色系统**
  - 文件: Utils/Colors.swift
  - 实现设计规范中定义的颜色常量
  - 完成后执行: Task 1.3

- [ ] **Task 1.3: 实现字体系统**
  - 文件: Utils/Typography.swift
  - 实现设计规范中定义的字体常量
  - 完成后执行: Task 1.4

- [ ] **Task 1.4: 创建数据模型**
  - 文件: Models/Puzzle.swift, Models/PuzzlePiece.swift, Models/AnalysisResult.swift
  - 实现上述数据模型概述中的结构体
  - 完成后执行: Task 1.5

- [ ] **Task 1.5: 实现应用状态管理**
  - 文件: App/AppState.swift
  - 实现AppScreen枚举(main, camera, result)
  - 实现CameraMode枚举(puzzle, piece)
  - 实现CameraSource枚举(camera, photoLibrary)
  - 实现状态变量和导航方法
  - 完成后执行: Task 1.6

- [ ] **Task 1.6: 创建应用入口**
  - 文件: App/PuzzleCompassApp.swift
  - 实现应用入口点，配置环境对象
  - 完成后执行: Task 1.7

- [ ] **Task 1.7: 实现英文本地化** [CURSOR CRITICAL]
  - 文件: Utils/Localization.swift, Resources/Localizable.strings
  - 创建字符串常量文件，存储所有UI文本
  - 确保所有UI文本都使用英文
  - 实现本地化获取函数，以支持未来的多语言扩展
  - 严格禁止在代码中使用硬编码的中文字符串
  - 开发过程中定期检查所有字符串是否为英文
  - 完成后开始阶段2: Task 2.1
  - 示例实现:
  ```swift
  // Localizable.strings
  "main.button.capturePuzzle" = "Capture Complete Puzzle";
  "main.button.selectFromAlbum" = "Select from Album";
  
  // Localization.swift
  struct L10n {
      static let mainCapturePuzzle = NSLocalizedString("main.button.capturePuzzle", comment: "Main screen button to capture puzzle")
      static let mainSelectFromAlbum = NSLocalizedString("main.button.selectFromAlbum", comment: "Main screen button to select from album")
      // ... other strings
  }
  
  // Usage in views
  Text(L10n.mainCapturePuzzle)
  ```

### 阶段2: 主界面实现 [等待阶段1完成]
- [ ] **Task 2.1: 实现主页视图模型**
  - 文件: Views/Main/MainViewModel.swift
  - 实现主页的业务逻辑
  - 处理"拍摄流程"和"相册流程"的入口逻辑
  - 完成后执行: Task 2.2

- [ ] **Task 2.2: 实现主页界面**
  - 文件: Views/Main/MainView.swift
  - 严格按照"主屏幕设计"实现UI
  - 添加两个主按钮:"拍摄完整拼图"和"从相册选择"
  - 配置主按钮样式为大尺寸卡片式设计
  - 点击"拍摄完整拼图"按钮时导航到相机界面(puzzle模式)
  - 点击"从相册选择"按钮时导航到相册选择器
  - 完成后开始阶段3: Task 3.1

### 阶段3: 拍摄流程实现 [等待阶段2完成]
- [ ] **Task 3.1: 实现相机基础功能**
  - 文件: Views/Camera/CameraView.swift
  - 使用AVFoundation实现相机预览
  - 配置相机会话和预览层
  - 实现全屏相机预览
  - 实现底部大型拍摄按钮
  - 支持CameraMode切换(puzzle/piece)
  - 完成后执行: Task 3.2

- [ ] **Task 3.2: 实现相机叠加层**
  - 文件: Views/Camera/CameraOverlayView.swift
  - 实现取景辅助线帮助用户对齐拼图
  - 实现闪光灯控制和相册切换按钮
  - 根据CameraMode显示不同UI提示
  - 在puzzle模式下拍摄后显示"现在拍摄碎片"提示条
  - 完成后执行: Task 3.3

- [ ] **Task 3.3: 实现拍摄确认视图**
  - 文件: Views/Camera/ConfirmationView.swift
  - 实现拍摄流程步骤5中的确认界面
  - 显示拍摄的照片
  - 添加"确认"和"重拍"按钮
  - 用户确认后保存图像数据到AppState
  - 完成后执行: Task 3.4
  
- [ ] **Task 3.4: 实现拍摄引导视图**
  - 文件: Views/Camera/GuidanceView.swift
  - 实现拍摄过程中的引导提示
  - 添加视觉引导提示:"请确保碎片放在中央，光线充足"
  - 相机模式切换时显示对应引导信息
  - 完成后执行: Task 3.5

- [ ] **Task 3.5: 实现拼图扣取功能**
  - 文件: Services/PuzzleExtractor.swift
  - 严格实现拍摄流程步骤4中的自动扣取功能
  - 使用Vision框架识别矩形区域
  - 对识别出的拼图执行透视校正
  - 将结果转换为可用的图像数据
  - 完成后执行: Task 3.6

- [ ] **Task 3.6: 完成拍摄流程自动模式切换**
  - 文件: Views/Camera/CameraView.swift
  - 在完整拼图拍摄确认后自动切换到碎片拍摄模式
  - 实现拍摄流程步骤6中的自动切换
  - 显示"现在请拍摄碎片"提示
  - 完成后开始阶段4: Task 4.1

### 阶段4: 相册流程实现 [等待阶段3完成]
- [ ] **Task 4.1: 实现照片选择器**
  - 文件: Views/Camera/PhotoPickerView.swift
  - A.实现相册流程步骤2-3中的完整拼图选择:
    - 使用PHPickerViewController集成系统相册
    - 支持选择一张拼图照片
    - 获取选中的图像数据
  - B.实现相册流程步骤6-8中的碎片选择:
    - 支持选择一张或多张碎片照片
    - 确认后传递数据进行分析
  - 完成后执行: Task 4.2

- [ ] **Task 4.2: 实现图像处理工具**
  - 文件: Utils/ImageProcessor.swift
  - 实现相册流程中的图像基础处理
  - 支持图像裁剪、缩放和格式转换
  - 确保选择的图像能被正确处理和分析
  - 完成后执行: Task 4.3

- [ ] **Task 4.3: 实现图像存储服务**
  - 文件: Services/ImageStorage.swift
  - 实现图像数据的临时存储和读取
  - 负责处理拍摄流程和相册流程中的图像数据
  - 完成后开始阶段5: Task 5.1

### 阶段5: 拼图分析功能 [等待阶段4完成]
- [ ] **Task 5.1: 实现图像识别基础服务**
  - 文件: Services/VisionService.swift
  - 集成Vision框架
  - 配置基础图像识别功能
  - 实现特征点检测的基本方法
  - 完成后执行: Task 5.2

- [ ] **Task 5.2: 实现拼图匹配算法**
  - 文件: Services/PuzzleMatcher.swift
  - 实现拍摄流程步骤9和相册流程步骤9中的匹配功能
  - 使用特征点检测和模式匹配技术
  - 分析碎片在完整拼图中的位置
  - 计算匹配位置的坐标和置信度
  - 完成后执行: Task 5.3

- [ ] **Task 5.3: 实现多碎片处理**
  - 文件: Services/MultiPieceMatcher.swift
  - 支持多碎片同时识别和标记
  - 将每个碎片的分析结果合并到同一个拼图上
  - 为每个碎片分配不同的标识和颜色
  - 完成后执行: Task 5.4

- [ ] **Task 5.4: 实现错误处理**
  - 文件: Services/ErrorHandler.swift
  - 实现拼图识别失败时的错误处理
  - 生成用户友好的错误信息
  - 处理分析过程中可能出现的异常
  - 完成后执行: Task 5.5

- [ ] **Task 5.5: 实现轻量级提示视图**
  - 文件: Views/Shared/ToastView.swift
  - 实现错误处理中的Toast风格提示
  - 显示"无法识别拼图碎片，请重试"等提示
  - 确保3秒后自动消失
  - 完成后执行: Task 5.6

- [ ] **Task 5.6: 实现加载指示器**
  - 文件: Views/Shared/LoadingView.swift
  - 实现分析过程中的加载动画
  - 在匹配分析时显示加载状态
  - 完成后执行: Task 5.7

- [ ] **Task 5.7: 实现结果生成器**
  - 文件: Services/ResultGenerator.swift
  - 汇总分析结果，生成AnalysisResult对象
  - 准备结果数据用于界面显示
  - 完成拍摄流程步骤9和相册流程步骤9
  - 完成后开始阶段6: Task 6.1

### 阶段6: 结果展示与交互实现 [等待阶段5完成]
- [ ] **Task 6.1: 实现结果界面基础结构**
  - 文件: Views/Result/ResultView.swift
  - 严格实现结果界面设计
  - 上半部分(70%)显示完整拼图
  - 底部区域(30%)显示碎片缩略图
  - 添加"拍摄更多碎片"按钮(底部)
  - 添加"完成"按钮(右上角)
  - 实现结果操作流程的基本导航
  - 完成后执行: Task 6.2

- [ ] **Task 6.2: 实现高亮显示**
  - 文件: Views/Result/HighlightView.swift
  - 实现结果操作流程步骤1中的高亮显示
  - 使用荧光色绘制匹配位置区域
  - 确保高亮区域准确显示在拼图上对应位置
  - 完成后执行: Task 6.3

- [ ] **Task 6.3: 实现多碎片标记**
  - 文件: Views/Result/MultiPieceView.swift
  - 实现结果操作流程步骤2中的多碎片区分
  - 为每个碎片使用不同颜色边框标记
  - 支持结果页面中的多碎片同时显示
  - 完成后执行: Task 6.4

- [ ] **Task 6.4: 实现碎片缩略图视图**
  - 文件: Views/Result/PieceThumbnailView.swift
  - 显示底部区域的碎片缩略图列表
  - 为每个缩略图添加对应的颜色边框
  - 支持点击缩略图时高亮对应的匹配区域
  - 完成后执行: Task 6.5

- [ ] **Task 6.5: 实现缩放功能**
  - 文件: Views/Result/ZoomableImageView.swift
  - 实现结果操作流程步骤3中的缩放功能
  - 支持捏合手势进行缩放
  - 支持双击放大/缩小
  - 完成后执行: Task 6.6

- [ ] **Task 6.6: 实现"拍摄更多碎片"功能**
  - 文件: Views/Result/ResultView.swift
  - 实现结果操作流程步骤4-8
  - 点击"拍摄更多碎片"按钮时导航到相机(piece模式)
  - 保持当前拼图数据不变
  - 新拍摄的碎片分析后返回结果界面
  - 完成后执行: Task 6.7

- [ ] **Task 6.7: 实现结果实时更新**
  - 文件: Views/Result/ResultView.swift
  - 实现结果操作流程步骤9中的实时更新
  - 当添加新碎片后自动更新结果界面
  - 确保新的匹配结果正确显示
  - 完成后执行: Task 6.8

- [ ] **Task 6.8: 整合导航完成按钮**
  - 文件: Views/Result/ResultView.swift
  - 实现结果操作流程步骤10
  - 点击右上角"完成"按钮时返回主屏幕
  - 完成后执行: Task 6.9

- [ ] **Task 6.9: 用户流程完整性测试**
  - 验证三个用户流程的完整实现:
  - 拍摄流程: 确认全部10个步骤顺利执行
  - 相册流程: 确认全部10个步骤顺利执行
  - 结果操作流程: 确认全部10个步骤顺利执行
  - 完成后执行: Task 6.10

- [ ] **Task 6.10: 英文界面最终检查** [CURSOR CRITICAL]
  - 全面检查所有界面文本是否均使用英文
  - 检查范围:
    - 所有按钮文本
    - 所有标题和提示文本
    - 所有错误消息
    - 所有Toast提示
    - 所有导航栏标题
  - 检查方法:
    - 使用工具检索代码中的非ASCII字符
    - 完整运行所有用户流程，检查每个界面
    - 触发所有可能的错误状态，检查错误提示
  - 检查命令:
    ```bash
    # 查找所有Swift文件中的中文字符
    grep -r '[一-龥]' --include="*.swift" .
    
    # 检查本地化文件中是否有中文
    grep -r '[一-龥]' --include="*.strings" .
    ```

## 阶段验收检查单

每个阶段完成后必须进行以下检查，确保符合项目要求:

### UI文本检查 [CURSOR PRIORITY]
- [ ] 确认本阶段实现的所有界面中没有中文文本
- [ ] 确认所有UI字符串都通过本地化工具获取，而非硬编码
- [ ] 确认错误消息和Toast提示均使用英文
- [ ] 运行阶段相关功能，确认用户可见的所有文本为英文

### 代码质量检查
- [ ] 确认代码遵循SwiftUI最佳实践
- [ ] 确认视图代码与业务逻辑分离
- [ ] 确认所有必要的注释已添加
- [ ] 确认代码没有编译警告和错误

### 用户体验检查
- [ ] 确认界面响应迅速，无明显卡顿
- [ ] 确认错误处理机制正常工作
- [ ] 确认用户流程顺畅，无导航问题
- [ ] 确认键盘和手势交互正常

## 技术要点示例

### 权限配置
在Info.plist中添加:
```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相机拍摄拼图和碎片</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册选择拼图和碎片图片</string>
```

### 拍摄流程核心代码示例

#### 主屏幕按钮实现 (步骤1)
```swift
// MainView.swift
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // 大尺寸卡片式按钮
            Button {
                viewModel.startShootingFlow()
                appState.navigateToCamera(mode: .puzzle, source: .camera)
            } label: {
                CardButton(
                    title: "Capture Complete Puzzle",
                    iconName: "camera",
                    description: "Capture puzzle and pieces for matching"
                )
            }
            
            Button {
                viewModel.startAlbumFlow()
                appState.navigateToCamera(mode: .puzzle, source: .photoLibrary)
            } label: {
                CardButton(
                    title: "Select from Album",
                    iconName: "photo.on.rectangle",
                    description: "Select puzzle and pieces from album"
                )
            }
            
            Spacer()
        }
        .padding()
        .background(Color.background)
    }
}
```

#### 相机界面实现 (步骤2-3)
```swift
// CameraView.swift
struct CameraView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var camera = CameraController()
    @State private var capturedImage: UIImage?
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack {
            // 相机预览层
            CameraPreviewView(camera: camera)
                .edgesIgnoringSafeArea(.all)
            
            // 相机叠加层 - 包含辅助线和提示
            CameraOverlayView(mode: appState.cameraMode)
            
            // 底部控制栏
            VStack {
                Spacer()
                CameraControlBar(
                    onCapture: {
                        // 执行拍摄 (步骤3)
                        capturedImage = camera.capturePhoto()
                        showConfirmation = true
                    },
                    onFlashToggle: { camera.toggleFlash() }
                )
            }
        }
        .sheet(isPresented: $showConfirmation, content: {
            if let image = capturedImage {
                // 确认界面 (步骤5)
                ConfirmationView(
                    image: image,
                    onConfirm: {
                        handleImageConfirmation(image)
                    },
                    onRetake: {
                        capturedImage = nil
                        showConfirmation = false
                    }
                )
            }
        })
        .onChange(of: appState.cameraSource) { newValue in
            if newValue == .photoLibrary {
                presentPhotoPicker()
            }
        }
    }
    
    // 处理拍摄确认 (步骤4-6)
    private func handleImageConfirmation(_ image: UIImage) {
        if appState.cameraMode == .puzzle {
            // 扣取拼图 (步骤4)
            Task {
                if let puzzleImage = await PuzzleExtractor.extract(from: image) {
                    await MainActor.run {
                        appState.setPuzzleImage(puzzleImage)
                        
                        // 自动切换到拍摄碎片模式 (步骤6)
                        appState.cameraMode = .piece
                        showGuidanceToast("Now Capture Pieces")
                        capturedImage = nil
                        showConfirmation = false
                    }
                } else {
                    await MainActor.run {
                        showErrorToast("Puzzle recognition failed, please try again")
                        capturedImage = nil
                        showConfirmation = false
                    }
                }
            }
        } else {
            // 处理碎片照片 (步骤7-8)
            appState.addPieceImage(image)
            
            // 如果已经有完整拼图，则进行分析 (步骤9)
            if appState.hasPuzzleImage {
                proceedToAnalysis()
            }
        }
    }
    
    // 进行分析并显示结果 (步骤9-10)
    private func proceedToAnalysis() {
        appState.isAnalyzing = true
        
        Task {
            // 执行拼图分析
            if let result = await PuzzleMatcher.analyze(
                puzzle: appState.puzzleImage!,
                pieces: appState.pieceImages
            ) {
                await MainActor.run {
                    appState.isAnalyzing = false
                    appState.setAnalysisResult(result)
                    appState.navigateToResult()
                }
            } else {
                await MainActor.run {
                    appState.isAnalyzing = false
                    showErrorToast("Piece matching failed, please try again")
                }
            }
        }
    }
}
```

### 相册流程核心代码示例

#### 照片选择器实现 (步骤2-3, 6-8)
```swift
// PhotoPickerView.swift
struct PhotoPickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if appState.cameraMode == .puzzle {
                    // 选择完整拼图界面 (步骤2-3)
                    Text("Please select a complete puzzle photo")
                        .font(.headline)
                        .padding()
                    
                    PhotosGrid(
                        selection: $selectedImages,
                        maxSelectionCount: 1
                    )
                } else {
                    // 选择碎片界面 (步骤6-8)
                    Text("Please select one or more puzzle pieces")
                        .font(.headline)
                        .padding()
                    
                    PhotosGrid(
                        selection: $selectedImages,
                        maxSelectionCount: 10
                    )
                }
            }
            .navigationBarTitle(
                appState.cameraMode == .puzzle ? "Select Puzzle" : "Select Pieces", 
                displayMode: .inline
            )
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Confirm") {
                    confirmSelection()
                }
                .disabled(selectedImages.isEmpty)
            )
        }
    }
    
    private func confirmSelection() {
        if appState.cameraMode == .puzzle {
            // 处理完整拼图选择 (步骤3-5)
            if let puzzleImage = selectedImages.first {
                Task {
                    if let processedImage = await PuzzleExtractor.extract(from: puzzleImage) {
                        await MainActor.run {
                            appState.setPuzzleImage(processedImage)
                            
                            // 切换到碎片选择模式 (类似步骤6)
                            appState.cameraMode = .piece
                            presentationMode.wrappedValue.dismiss()
                            
                            // 显示选择碎片的提示
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                appState.navigateToCamera(mode: .piece, source: .photoLibrary)
                            }
                        }
                    } else {
                        await MainActor.run {
                            showErrorToast("Puzzle recognition failed, please select another image")
                        }
                    }
                }
            }
        } else {
            // 处理碎片选择 (步骤7-8)
            for image in selectedImages {
                appState.addPieceImage(image)
            }
            
            presentationMode.wrappedValue.dismiss()
            
            // 如果已经有完整拼图，则进行分析 (步骤9)
            if appState.hasPuzzleImage {
                proceedToAnalysis()
            }
        }
    }
    
    // 进行分析并显示结果 (步骤9-10)
    private func proceedToAnalysis() {
        appState.isAnalyzing = true
        
        Task {
            if let result = await PuzzleMatcher.analyze(
                puzzle: appState.puzzleImage!,
                pieces: appState.pieceImages
            ) {
                await MainActor.run {
                    appState.isAnalyzing = false
                    appState.setAnalysisResult(result)
                    appState.navigateToResult()
                }
            } else {
                await MainActor.run {
                    appState.isAnalyzing = false
                    showErrorToast("Piece matching failed, please select another image")
                }
            }
        }
    }
}
```

### 结果操作流程核心代码示例

#### 结果界面实现 (步骤1-4, 10)
```swift
// ResultView.swift
struct ResultView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPieceIndex: Int? = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 背景
            Color.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 上半部分(70%): 完整拼图和高亮显示 (步骤1-3)
                ZoomableImageView(
                    image: appState.puzzleImage!,
                    overlays: highlightOverlays(),
                    scale: $scale
                )
                .frame(height: UIScreen.main.bounds.height * 0.7)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                        .onEnded { _ in
                            withAnimation {
                                scale = 1.0
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        scale = scale == 1.0 ? 2.0 : 1.0
                    }
                }
                
                // 底部区域(30%): 碎片缩略图和操作按钮 (步骤4)
                VStack {
                    // 碎片缩略图列表
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<appState.pieceImages.count, id: \.self) { index in
                                PieceThumbnailView(
                                    image: appState.pieceImages[index],
                                    isSelected: selectedPieceIndex == index,
                                    color: pieceColors[index % pieceColors.count]
                                )
                                .frame(width: 80, height: 80)
                                .onTapGesture {
                                    selectedPieceIndex = index
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 100)
                    
                    // "拍摄更多碎片"按钮
                    Button {
                        captureMorePieces()
                    } label: {
                        Text("Capture More Pieces")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .background(Color.secondaryBackground)
            }
        }
        .navigationBarItems(
            trailing: Button("Done") {
                // 返回主屏幕 (步骤10)
                appState.navigateToMain()
            }
        )
        .navigationBarTitle("Puzzle Result", displayMode: .inline)
    }
    
    // 生成高亮叠加层 (步骤1-2)
    private func highlightOverlays() -> [HighlightOverlay] {
        var overlays: [HighlightOverlay] = []
        
        if let result = appState.analysisResult {
            for (index, match) in result.matches.enumerated() {
                let color = pieceColors[index % pieceColors.count]
                let isSelected = selectedPieceIndex == index
                
                overlays.append(HighlightOverlay(
                    rect: match.matchRect,
                    color: color,
                    opacity: isSelected ? 0.5 : 0.3,
                    lineWidth: isSelected ? 3 : 2
                ))
            }
        }
        
        return overlays
    }
    
    // 拍摄更多碎片 (步骤5-8)
    private func captureMorePieces() {
        // 保存当前状态并导航到相机
        appState.preserveCurrentResult()
        appState.navigateToCamera(mode: .piece, source: .camera)
    }
}
```

#### 拍摄更多碎片功能实现 (步骤5-9)
```swift
// AppState.swift
class AppState: ObservableObject {
    // ... 其他属性 ...
    
    // 用于实现"拍摄更多碎片"功能
    @Published var isAddingMorePieces: Bool = false
    private var previousResult: AnalysisResult?
    
    func preserveCurrentResult() {
        isAddingMorePieces = true
        previousResult = analysisResult
    }
    
    // 在相机中拍摄更多碎片后的结果处理
    func processAdditionalPieces() {
        isAnalyzing = true
        
        Task {
            if let puzzle = puzzleImage, !pieceImages.isEmpty {
                // 仅分析新添加的碎片
                let newPieceStartIndex = previousResult?.matches.count ?? 0
                let newPieces = Array(pieceImages[newPieceStartIndex...])
                
                if let newResult = await PuzzleMatcher.analyze(
                    puzzle: puzzle,
                    pieces: newPieces
                ) {
                    await MainActor.run {
                        // 合并新旧结果 (步骤9)
                        if let previous = previousResult {
                            let mergedResult = ResultGenerator.mergeResults(
                                previous: previous,
                                new: newResult
                            )
                            setAnalysisResult(mergedResult)
                        } else {
                            setAnalysisResult(newResult)
                        }
                        
                        isAnalyzing = false
                        isAddingMorePieces = false
                        
                        // 返回结果界面
                        navigateToResult()
                    }
                } else {
                    await MainActor.run {
                        isAnalyzing = false
                        // 失败处理...
                    }
                }
            }
        }
    }
}
```

### 相机初始化
```swift
func setupCamera() {
    let session = AVCaptureSession()
    session.sessionPreset = .photo
    
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
          let input = try? AVCaptureDeviceInput(device: device) else { return }
    
    session.addInput(input)
    // 配置输出和预览层...
}
```

### 图像分析异步处理
```swift
func analyzePuzzlePiece(piece: UIImage, in puzzle: UIImage) async -> CGRect? {
    do {
        // 使用Vision框架进行特征点匹配
        return try await performVisionAnalysis(piece: piece, puzzle: puzzle)
    } catch {
        await MainActor.run {
            errorHandler.show(error: .analysisFailure)
        }
        return nil
    }
}
```

### 状态管理
```swift
// 在视图中使用AppState
struct MainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Button("拍摄完整拼图") {
                appState.navigateToCamera(mode: .puzzle, source: .camera)
            }
            // ...
        }
    }
}
```

## 与用户流程的一致性检查

### 拍摄流程步骤与任务对应关系
1. **主屏幕点击"拍摄完整拼图"** → Task 2.2 主页界面
2. **进入相机界面** → Task 3.1 相机基础功能
3. **拍摄完整拼图照片** → Task 3.1 相机基础功能
4. **自动识别扣取拼图** → Task 3.5 拼图扣取功能
5. **显示确认界面** → Task 3.3 拍摄确认视图
6. **切换到拍摄碎片模式** → Task 3.6 自动模式切换
7. **拍摄碎片照片** → Task 3.1 相机基础功能
8. **确认碎片照片** → Task 3.3 拍摄确认视图
9. **分析匹配位置** → Task 5.2 拼图匹配算法, Task 5.7 结果生成器
10. **显示结果界面** → Task 6.1-6.5 结果界面相关任务

### 相册流程步骤与任务对应关系
1. **主屏幕点击"从相册选择"** → Task 2.2 主页界面
2. **打开系统相册选择器** → Task 4.1 照片选择器
3. **选择完整拼图照片** → Task 4.1 照片选择器
4. **自动识别扣取拼图** → Task 3.5 拼图扣取功能
5. **显示确认界面** → Task 3.3 拍摄确认视图
6. **提示选择碎片照片** → Task 4.1 照片选择器
7. **选择碎片照片** → Task 4.1 照片选择器
8. **确认碎片照片** → Task 4.1 照片选择器
9. **分析匹配位置** → Task 5.2 拼图匹配算法, Task 5.7 结果生成器
10. **显示结果界面** → Task 6.1-6.5 结果界面相关任务

### 结果操作流程步骤与任务对应关系
1. **显示完整拼图和高亮匹配位置** → Task 6.1-6.2 结果界面基础结构和高亮显示
2. **多碎片不同颜色标记** → Task 6.3 多碎片标记
3. **缩放查看匹配详情** → Task 6.5 缩放功能
4. **底部"拍摄更多碎片"按钮** → Task 6.1 结果界面基础结构
5. **点击"拍摄更多碎片"按钮** → Task 6.6 拍摄更多碎片功能
6. **跳转相机界面** → Task 6.6 拍摄更多碎片功能
7. **拍摄新碎片** → Task 3.1 相机基础功能
8. **分析新碎片** → Task 5.2 拼图匹配算法
9. **结果界面实时更新** → Task 6.7 结果实时更新
10. **点击"完成"返回主屏** → Task 6.8 整合导航完成按钮