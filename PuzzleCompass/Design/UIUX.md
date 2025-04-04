为PuzzleCompass应用创建HTML+CSS UI原型，实现所有界面在index.html中平铺展示。

具体要求：
1. 创建完整index.html文件结构，包含<!DOCTYPE html>、<html>、<head>、<body>等基础标签
2. 在<head>中使用<style>标签定义所有CSS样式
3. 使用CSS Grid在<body>中平铺所有界面原型，每个界面放入独立<div>容器
4. 严格遵循文档规范的UI设计参数：
   - 主色: #4A90E2
   - 强调色: #50E3C2
   - 背景色: #F7F7F7
   - 文本色: #333333

将开发过程分成以下几个批次，每次只实现部分界面：
批次1: 创建index.html基础结构和样式，实现主界面(MainView)
批次2: 添加相机界面(CameraView)和拍摄确认界面(ConfirmationView)
批次3: 添加碎片拍摄界面和相册选择界面(PhotoPickerView)
批次4: 添加结果界面(ResultView)和多碎片显示界面

请先实现批次1的内容。确保代码有清晰注释，每个界面包含标题和说明其在用户流程中的位置。