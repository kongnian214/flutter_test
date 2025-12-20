# 圣诞氛围展示 App 规划

## 产品愿景
- 打造一款可以随时开启的“圣诞惊喜陈列室”，展现平安夜与圣诞节的沉浸式氛围。
- 以视觉冲击和互动彩蛋为核心，强调“好看 + 惊喜”。
- 可作为线下活动、线上祝福或直播背景，支持快速切换主题方案与音效组合。

## 体验蓝图
1. **雪夜开场**：应用启动即播放星轨与飘雪动画，Logo 暖光渐入并同步音效。
2. **多层主舞台**：背景天空、远景圣诞村、近景圣诞树与前景粒子叠加，随时间缓慢变化。
3. **互动特效区**：滑动、长按、摇晃设备都会点亮不同彩蛋，可设置组合触发链路。
4. **节日倒计时**：翻牌动效展示距离平安夜/圣诞节天数，归零后触发烟花全屏盛宴。
5. **音乐与氛围面板**：实时切换背景乐、音效、主题色温与粒子密度，并保存偏好。

## 页面分工
- **舞台**：主视觉与核心控制台，保留 Aurora/Snow/祝福文案/音频等高频操作，舞台重点彩蛋（Magic Dust、North Pole Mail、Bell Chime、Gift Fireworks）在此直接开关。
- **特效库**：以卡片形式浏览特效描述、全屏预览和“一键应用到舞台”，便于查找灵感。
- **互动**：承载 Playgound 彩蛋与高级特效遥控（Meteor、Polar Wind、Ribbon Portal 等），附设备动作/脚本灵感，可随时将结果同步到舞台。

## 场景与特效库（可混搭）
- Aurora Sky：Shader 模拟极光丝带，颜色随当地时间渐变。
- Snow Field：粒子雪花支持不同尺寸、风向与融化衰减。
- Glowing Tree：圣诞树灯串随音乐节奏闪烁，峰值增亮。
- Gift Fireworks：点击礼盒生成礼物烟花，粒子拖尾带彩带残影。
- Crystal Particles：手指滑动绘制冰晶轨迹，离屏后粉碎成碎片雨。
- Candy Cane Rain：糖果棒定时从顶部缓落，落地发出木质敲击声。
- Starry Village：远景房屋窗户随机亮灭，配合烟囱蒸汽与微光。
- Frost Transition：切换界面时使用冰霜结晶遮罩，随后融化露出新场景。
- Ribbon Portal：长按屏幕展开旋转丝带传送门，引导进入隐藏彩蛋页。
- Toy Parade：Rive 玩具沿轨迹行进，碰撞时弹出碎屑粒子。
- Bell Chime：双指轻点触发巨型铃铛晃动，伴随震动与音符光点。
- Meteor Shower：夜间自动出现流星雨，划过时拖拽动态模糊尾巴。
- Magic Dust：语音输入“圣诞快乐”或在舞台控制台写下祝福后，全屏散播金色粒子拼出文字。
- Polar Wind：麦克风或传感器模拟风力，影响雪花方向。
- Cookie Baking：接近午夜出现烘焙桌面，烟雾和香味气泡缓缓上升。
- Midnight Clockwork：巨大齿轮钟表旋转，整点喷射火花强调仪式感。
- Star Choir：音符光球根据频谱漂浮，音量越大越亮。
- Lantern Drift：温暖纸灯从底部飘向天空，经过时点亮附近粒子。
- North Pole Mail：随机掉落信封，点击显示祝福语并伴随雪狐奔跑动画。
- Aurora Trails：镜头移动时保留拖尾，形成沉浸式极光廊道。

## 互动玩法
- **手势组合**：单击、双击、长按、拖拽、捏合、旋转分别映射不同特效，可在设置面板自定义。
- **设备动作**：摇晃触发彩灯乱闪；倾斜改变雪落方向；敲击桌面通过麦克风检测节奏点亮鼓点灯。
- **社交祝福**：选择特效组合生成短视频/GIF，附定制祝福语与头像贴纸。

## 特效触发条件与效果
| 特效 | 触发方式 | 效果说明 |
| --- | --- | --- |
| Aurora Sky | 氛围控制台开启或夜间自动启用 | Shader 极光丝带随时间/音乐渐变，铺满背景营造冷暖对比 |
| Snow Field | 控制台切换 Snow Field 并调节粒子密度 | 多尺寸雪花粒子受风向与重力影响，具备融化和拖尾衰减 |
| Glowing Tree | 开启音乐模式或选择灯光主题 | 圣诞树灯串与节奏同步闪烁，峰值时增强光晕 |
| Gift Fireworks | 点击/拖动互动彩蛋区域或“触发烟花”按钮 | 礼物烟花在触点爆开，粒子附带彩带残影 |
| Crystal Particles | Playground 中滑动或长按 | 手势轨迹绘制成冰晶，离屏后碎裂成碎片雨 |
| Candy Cane Rain | 计时器每 20 秒触发，可在控制台关闭 | 糖果棒从顶部缓落，落地伴随木质敲击声和震动 |
| Starry Village | 始终启用，夜间亮度提升 | 远景房屋窗户随机亮灭，烟囱冒蒸汽与微光 |
| Frost Transition | 切换页面/主题时自动 | 冰霜遮罩覆盖并逐渐融化露出新场景 |
| Ribbon Portal | Playground 长按 >500ms | 丝带传送门展开并释放粒子，引导至隐藏页面 |
| Toy Parade | 特效库启用或“童话木屋”主题 | 玩具士兵沿轨迹行进，碰撞时弹出碎屑粒子 |
| Bell Chime | 双指轻点屏幕上方或摇晃设备 | 巨型铃铛摆动，伴随震动与音符光点散开 |
| Meteor Shower | 当地时间 ≥20:00 自动播放 | 流星带动态模糊尾巴，穿越夜空后渐隐 |
| Magic Dust | 语音“圣诞快乐”/快速多点点击/舞台祝福输入 | 金色粒子全屏散布并拼出自定义祝福文字 |
| Polar Wind | 启用传感器融合并读取加速度/麦克风 | 风力影响雪花方向与粒子速度 |
| Cookie Baking | 23:30 以后自动出现 | 烘焙桌面浮现，烟雾和香味气泡缓缓上升 |
| Midnight Clockwork | 倒计时时/整点触发 | 巨大齿轮旋转，整点喷射火花粒子 |
| Star Choir | 音乐模式 + 麦克风音量 | 音符光球根据频谱漂浮，音量越大越闪亮 |
| Lantern Drift | 氛围控制台勾选 Lantern Drift | 纸灯自下而上漂浮，经过处唤醒周围粒子 |
| North Pole Mail | 每隔 30 秒掉落信封或摇动设备 | 信封展开你写的祝福语并伴随雪狐动画 |
| Aurora Trails | 设备移动或 Playground 拖动 | GPU 粒子留下拖尾，形成极光走廊 |

## 功能完成度
- [ ] 多层背景与节日倒计时
- [ ] 氛围控制台（雪花/极光/灯笼/烟花）
- [ ] 底部导航与分页布局
- [ ] 互动彩蛋 Playground 粒子体验
- [ ] 传感器/设备动作联动
- [ ] 音乐同步 Star Choir 与音效淡入淡出

## 技术方案
- Flutter 3.x + Dart 3.x，充分利用 Impeller 渲染管线。
- 动画：Rive/Lottie 处理骨骼动画，CustomPainter + Shader 实现粒子与光效，使用 FragmentProgram 编写自定义着色器。
- 音频：just_audio 播放 BGM，udioplayers 处理短音效；可用 ssets_audio_player 实现淡入淡出。
- 传感器：sensors_plus 获取加速度计/陀螺仪，shake、proximity_sensor 等插件扩展互动。
- 状态管理：Riverpod 或 Bloc，方便在主题切换时同步效果参数与本地化文案。
- 资产管理：统一纹理、音效、HDR 背景等清单，配合 
lutter_cache_manager 做懒加载与缓存清理。

## 性能与优化
- 粒子系统使用批渲染、对象池与时间步长控制，保持 60fps。
- Shader/动画支持自适应帧率，根据设备性能自动降级（关闭模糊、降低粒子数量）。
- 预加载关键纹理与音频，避免首次触发卡顿；Idle 状态降低刷新率。
- 使用 
lutter_driver、integration_test 与 profile 模式检测 GPU/CPU 占用，必要时提供低功耗模式。

## 迭代计划
1. **原型探索 Day1-2**：搭建基础舞台、粒子框架、色板和音频通道。
2. **特效堆栈 Day3-6**：实现至少 12 种核心特效模块，并提供调节入口。
3. **互动彩蛋 Day7-8**：完成手势/传感器映射、彩蛋触发逻辑、倒计时联动。
4. **性能与发布 Day9**：适配主流机型、压缩资源、准备图标与上架素材。

## 验收标准
- 至少 15 组可组合的特效，可在设置中自由启用/禁用。
- 主要交互延迟 <100ms，帧率稳定在 60fps（中高端）/45fps（低端）以上。
- 倒计时、音乐、主题切换互不干扰，状态重启后可恢复。

## Dev Progress (2025-12-14)
- [x] Riverpod 2.6 + `ProviderScope` wired via `lib/core/bootstrap.dart` to own initialization/orientation flow
- [x] Domain/Data/Presentation layers carved out with `MockExperienceRepository` + entity classes for future data swap
- [x] Stage tab now powered by `StageExperienceController` and `CountdownService`, decoupling countdown/visual toggles from widgets
- [x] Effect & interaction tabs fetch through repository providers with loading/error surfaces for empty states
- [x] 特效库新增分页/骨架体验，舞台可通过“触发烟花”按钮看到即时反馈
- [x] 特效卡片支持详情抽屉与一键应用舞台层
- [x] SceneController 插件化 Aurora/Snow/Lantern/Firework 层并接入舞台 Stack，方便后续 Playground/共享场景扩展
- [x] Starry Village 层实现小镇灯光/烟囱蒸汽/星空闪烁，可在氛围控制台独立开关，补齐 README 特效库中的远景背景项
- [x] Candy Cane Rain 粒子层（糖果棒缓慢下落 + 光晕）投入 SceneController，并提供控制台开关，呼应 README 的定时特效条目
- [x] 舞台画布升级为全局背景，特效卡片新增“全屏预览”，并限制简单特效开关最多同时 3 个，贴合实际体验需求
- [x] 特效层置前 + 沉浸模式切换：支持“信息面板/纯特效”两种视图，并在沉浸模式下提供退出提示
- [x] 新增 Meteor Shower/Magic Dust 全屏 Demo：EffectPreviewPage 识别更多特效关键词，并在 README 中标记可实时预览的列表
- [x] Crystal Particles & Ribbon Portal Playground：手势拖拽生成晶体拖尾，长按触发丝带传送门带火花粒子
- [x] Glowing Tree 舞台层：音律灯串圣诞树接入 SceneController + 控制台开关，并在全屏预览实时脉冲
- [x] Frost Transition 覆盖层：冰霜结晶遮罩支持全屏预览与舞台切换时叠加，控制台可独立开关
- [x] Cookie Baking 场景：木质烘焙桌面 + 热气蒸汽可叠加至舞台，支持 Effect 列表应用/全屏预览
- [x] Toy Parade 线路：玩具巡游路线与粒子火花层集成，可在舞台控制台和全屏预览中体验
- [x] Midnight Clockwork 齿轮：巨型机械钟层支持舞台叠加、全屏预览与 Effect 卡片应用
- [x] North Pole Mail 信件：信封坠落 + 雪狐轨迹层接入舞台和全屏预览，控制台可开关
- [x] Polar Wind 预设：Snow Field 接入风力参数，控制台可调风向并与特效卡片联动
- [x] Bell Chime 钟声：舞台新增铃铛摇摆与音符光点层，支持控制台开关和全屏预览
- [x] Star Choir 光球：音符光球实时响应强度（模拟音量）并接入舞台/全屏预览
- [x] Aurora Trails 拖尾：新增极光拖尾层，控制台可开关，卡片可应用/预览
- [x] Gift Fireworks 自动礼盒烟花：舞台接入礼盒烟花开关，应用时自动定时触发
- [x] FestiveAudioController：引入 just_audio + 本地音频资产，Glowing Tree/Bell Chime/Star Choir 按真实节奏脉动并提供舞台音频面板
- [x] Blessing Composer + Magic Dust/North Pole Mail：写下或随机生成祝福，粒子与信件实时显示自定义内容
- [x] 舞台/互动分工重构：舞台聚焦基础氛围 + 核心彩蛋，互动页集中管理高级特效、Playground 与脚本触发

## Architecture Snapshot
```
lib/
  core/                // bootstrap + theme + DI
  data/
    repositories/
    sources/
  domain/
    entities/
    services/
    value_objects
  presentation/
    app/
    shell/
    stage/
    effects/
    interaction/
    shared/
```

## Next Implementation Targets
- 将 `SceneController` 插件注册与状态持久化暴露给 Playground/互动页，支持多入口共用层配置，并允许插件声明优先级/层级
- Replace mock repositories with JSON/API + caching strategy, including offline hydration and tagging
- Expand interaction tab with real sensor/gesture/voice inputs plus multi-device sync (BLE/WebSocket abstraction)
- 构建 widget/golden/integration tests + README 内的 CI 指南，确保迭代 Rhythm 中“新增特效需配套测试”得以执行
- 针对导航切页的性能：优先使用懒加载 + KeepAlive 的列表视图，避免 BackdropFilter/模糊叠加；若需要玻璃拟态效果，可以只在舞台等核心区域使用。
- 特效库分页 + 骨架：数据层提供分页接口，UI 通过懒加载滚动并在加载中显示骨架卡片，保障切页和滚动的流畅体验。

## Iteration Rhythm
- 每次迭代聚焦 1–2 个特效或交互玩法：如先完成 Aurora Sky Shader 调参与一个新的互动事件，再进入下一轮
- 对应 README 的 Dev Progress 保持同步记录，说明“已完成特效 + 新玩法”以及验证方式
- 为每个新增特效建立独立的组件/配置文件，提交前至少补一条 widget/golden 用例，避免集中修改造成卡顿

## 本地环境与依赖安装
1. **安装工具链**：使用 Flutter stable 3.24.x（Dart 3.7）并确保 Android Studio（含 Android SDK/NDK）、Xcode 15+（iOS/macOS）或 Visual Studio 2022（Windows 桌面）已装好。
2. **检测环境**：首次 clone 后运行 `flutter doctor -v`，根据提示补齐缺失组件并接受 `flutter doctor --android-licenses`。
3. **获取依赖**：在项目根目录执行 `flutter pub get`；如需升级所有包可改用 `flutter pub upgrade --major-versions`。
4. **平台特定安装**：
   - iOS/macOS：`cd ios && pod install --repo-update`，Xcode 中选择对应 target 以保证签名信息同步。
   - Windows/Linux 桌面：先运行 `flutter config --enable-windows-desktop`（或 `--enable-linux-desktop`）开启桌面端支持。
   - Web：`flutter config --enable-web`，必要时安装最新 Chrome 作为调试浏览器。
5. **常用校验**：`flutter analyze`（静态检查）、`flutter test`（单元/Widget 测试）和 `dart run build_runner watch`（如后续引入代码生成）。

## 导出安装包与交付
| 平台 | 打包命令 | 输出产物 |
| --- | --- | --- |
| Android APK | `flutter build apk --release --dart-define=ENV=prod` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android AAB | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| iOS/ipa | `flutter build ipa --release`（需配置 `ios/Runner.xcodeproj` 签名） | `build/ios/ipa/*.ipa` |
| macOS | `flutter build macos --release` | `build/macos/Build/Products/Release/*.app` |
| Windows | `flutter build windows --release` | `build/windows/runner/Release/*.exe` |
| Linux | `flutter build linux --release` | `build/linux/x64/release/bundle/` |
| Web | `flutter build web --release` | `build/web/` 静态资源，可直接部署 |

- Android 如需多渠道，可在 `android/app/build.gradle` 配置 `productFlavors` 并通过 `flutter build apk --flavor staging` 导出不同渠道包。
- iOS/macOS 打包建议在 `flutter build` 后通过 Xcode `Archive → Distribute App` 输出 TestFlight/App Store 版本。
- Windows/Linux 桌面如需安装器，可在生成的 Release 目录基础上使用 `MSIX Packaging Tool`、`makeself` 等二次封装。
- Web 导出目录可上传到 CDN/静态网站服务，或配合 Server-Side Render/边缘缓存策略进行加速。
