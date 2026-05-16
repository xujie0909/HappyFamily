import os

base = r'C:\Users\xujie\AppData\Local\Pub\Cache\hosted\pub.dev'

# Fix amap_flutter_location build.gradle
path = os.path.join(base, r'amap_flutter_location-3.0.0\android\build.gradle')
with open(path, 'r', encoding='utf-8') as f:
    c = f.read()
c = c.replace('compileSdkVersion 29', 'namespace "com.amap.flutter.location"\n    compileSdkVersion 34')
c = c.replace('minSdkVersion 16', 'minSdkVersion 21')
with open(path, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: location build.gradle')

# Fix amap_flutter_map build.gradle
path = os.path.join(base, r'amap_flutter_map-3.0.0\android\build.gradle')
with open(path, 'r', encoding='utf-8') as f:
    c = f.read()
c = c.replace('compileSdkVersion 29', 'namespace "com.amap.flutter.amap_flutter_map"\n    compileSdkVersion 34')
c = c.replace('minSdkVersion 16', 'minSdkVersion 21')
with open(path, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: map build.gradle')

# Fix AMapFlutterMapPlugin.java - remove registerWith (v1 API)
path = os.path.join(base, r'amap_flutter_map-3.0.0\android\src\main\java\com\amap\flutter\map\AMapFlutterMapPlugin.java')
with open(path, 'r', encoding='utf-8') as f:
    c = f.read()
c = c.replace('import io.flutter.plugin.common.PluginRegistry;\n', '')
# Remove registerWith method
import re
c = re.sub(
    r'\s*public static void registerWith\(PluginRegistry\.Registrar registrar\).*?^\s*\}\n',
    '\n',
    c,
    flags=re.DOTALL | re.MULTILINE
)
with open(path, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: AMapFlutterMapPlugin.java')

# Fix ConvertUtil.java - replace FlutterMain with FlutterInjector
path = os.path.join(base, r'amap_flutter_map-3.0.0\android\src\main\java\com\amap\flutter\map\utils\ConvertUtil.java')
with open(path, 'r', encoding='utf-8') as f:
    c = f.read()
c = c.replace('import io.flutter.view.FlutterMain;', 'import io.flutter.FlutterInjector;')
c = c.replace('FlutterMain.getLookupKeyForAsset(', 'FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(')
with open(path, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: ConvertUtil.java')

print('All done!')
