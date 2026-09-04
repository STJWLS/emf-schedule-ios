# EMF 课表 · iOS 壳应用（Xcode 工程源码）

iOS 应用**必须在 macOS 上用 Xcode 编译**（Windows 无法构建 iOS App），本目录是完整可打开的 Xcode 工程源码。

## 原理

与 Android 版一致：App 只是一个 **WKWebView 壳**，加载网页版看板：

```
https://stjwls.github.io/kitten/emf-schedule/
```

网页端（后端）更新后，App 打开即是最新内容，**无需重新构建/上架**。

## 在 Mac 上构建（两步）

1. **打开工程**：双击 `EMFSchedule.xcodeproj`（Xcode 14+）
2. **签名**：选中 `EMFSchedule` target → Signing & Capabilities → 勾选
   `Automatically manage signing`，Team 选择你的 Apple ID：
   - 免费 Apple ID：可直接装到自己设备，签名 7 天有效（到期重签即可，内容永远来自网页，不受影响）
   - 开发者账号（99 美元/年）：可分发 TestFlight / App Store
3. 选择真机设备 → `⌘R` 运行；或 Product → Archive 导出 IPA

## 无 Mac 构建（GitHub Actions 免费 macOS runner）

1. 把本目录（`EMFSchedule.xcodeproj` + `EMFSchedule/`）推到一个**公开** GitHub 仓库
2. 把 `ci/ios-build.yml` 复制为该仓库的 `.github/workflows/ios-build.yml`
3. Actions 页手动触发「iOS Build」→ 在 Artifacts 下载产物：
   - 默认：**无签名 .app**（验证编译，免费零配置）
   - 取消注释 workflow 中的签名步骤并配置 Secrets（.p12 + .mobileprovision，
     需 Apple Developer 账号）→ 产出**可安装 IPA**

> 工程已含共享 Scheme（`xcshareddata/xcschemes/`），CI 的 `xcodebuild -scheme` 可直接使用。
> 更多方案（本地 macOS 虚拟机 / rcodesign 签名）见 Vault 笔记「无Mac构建iOS方案探索」。

## 工程结构

| 文件 | 作用 |
| --- | --- |
| `EMFSchedule/EMFScheduleApp.swift` | App 入口（SwiftUI `@main`） |
| `EMFSchedule/ContentView.swift` | 主界面：顶栏（品牌点/标题/刷新/Safari）+ WKWebView + 加载条 + 离线重试条；配色与网页版一致（米白/复旦蓝/马卡龙粉） |
| `EMFSchedule/Info.plist` | 应用元信息（显示名「EMF 课表」、Bundle ID `com.stjwls.EMFSchedule`） |
| `EMFSchedule/Assets.xcassets` | App 图标（1024×1024，与 Android 版同款设计） |
| `EMFSchedule.xcodeproj/project.pbxproj` | Xcode 工程定义（iOS 15.0+，iPhone/iPad） |

## 行为约定（与 Android 版一致）

- 站内链接（stjwls.github.io）留在 WebView；外链跳转系统 Safari
- 支持边缘侧滑返回/前进手势
- 加载失败显示粉色提示条，点击重试
