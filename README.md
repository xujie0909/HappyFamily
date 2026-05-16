# HappyFamily - 家庭位置共享 App

## 项目结构

```
HappyFamily/
├── backend/              # Node.js 后端
│   ├── src/
│   │   ├── app.js        # 入口，Express + Socket.io
│   │   ├── config/db.js  # MongoDB 连接
│   │   ├── models/       # User, Family, Location
│   │   ├── controllers/  # auth, family 业务逻辑
│   │   ├── routes/       # REST API 路由
│   │   ├── middleware/   # JWT 鉴权
│   │   └── socket/       # 实时位置 Socket.io
│   ├── package.json
│   └── .env.example
│
└── happyfamily_app/      # Flutter 前端
    ├── lib/
    │   ├── main.dart
    │   ├── models/       # User, Family, Location
    │   ├── providers/    # AuthProvider, FamilyProvider
    │   ├── screens/      # Login, Register, Map, Settings, FamilySetup
    │   ├── services/     # ApiService, SocketService, LocationService
    │   └── widgets/      # MemberAvatarMarker, MemberInfoCard
    ├── pubspec.yaml
    └── android/
        └── app/
            └── src/main/AndroidManifest.xml
```

## 开发前准备

### 1. 申请高德地图 API Key（免费）

1. 访问 https://console.amap.com/
2. 注册/登录，进入「我的应用」→「创建新应用」
3. 添加 Key，平台选「Android」
4. SHA1 获取方式：`keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
5. 将 Key 填入以下位置：
   - `happyfamily_app/lib/utils/constants.dart` 的 `amapAndroidKey`
   - `happyfamily_app/android/app/src/main/AndroidManifest.xml` 的 meta-data value
   - `happyfamily_app/lib/screens/map_screen.dart` 的 `AMapApiKey(androidKey: ...)`

### 2. 启动后端

```bash
cd backend
cp .env.example .env   # 编辑 .env，填入 JWT_SECRET
npm install
npm run dev            # 开发模式（需安装 nodemon）
# 或
npm start              # 生产模式
```

**环境要求：**
- Node.js >= 18
- MongoDB（本地安装或 MongoDB Atlas 云）

### 3. 启动 Flutter App

```bash
cd happyfamily_app
flutter pub get
flutter run
```

**环境要求：**
- Flutter SDK >= 3.0
- Android SDK，模拟器或真机

> 注意：如果使用真机测试，将 `constants.dart` 中的 `10.0.2.2` 替换为电脑的局域网 IP，例如 `192.168.1.100`

## 功能说明

| 功能 | 说明 |
|------|------|
| 注册/登录 | 手机号 + 密码 |
| 创建家庭 | 生成6位邀请码 |
| 加入家庭 | 输入邀请码 |
| 地图展示 | 高德地图实时显示所有家庭成员位置 |
| 实时位置 | WebSocket 推送，每5秒更新一次 |
| 速度/状态 | 自动识别静止/步行/骑行/驾车 |
| 在线状态 | 绿点=在线，灰点=离线 |
| 邀请码分享 | 点击地图右下角分享按钮 |
