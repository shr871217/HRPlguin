# HRPlguin
支持调试阶段快捷方式mork数据，快捷方式生成property 属性代码避免重复的工作

这个插件支持两个功能

1. DEBUG 开关mork数据，这个对于调试阶段可以避免假数据提价上线的低级错误,如下图gif
   ![image](DEBUG3.gif)
   
2. 支持快捷方式生成property属性
   ps :  @property (nonatomic, strong) <type> <name>
   pw :  @property (nonatomic, weak) <type> <name>
   pa :  @property (nonatomic, assign) <type> <name> 
   
   
###如何使用（how）

1. 将编译生成的**QHRDebug.xcplugin** 拷贝到~/Library/Application Support/Developer/Shared/Xcode/Plug-ins 目录下，重启

2. 正常重启xcode 就生效了，在xcode 的view 目录下能看见插件的两个功能和对应的快捷方式

3. 如果xcode 没有生效，重启的时候用如下命令 `*tail -f /var/log/system.log* ` 打印出xcode 日志，正常是因为xcode 升级了，但是QHRDebug.xcplugin 没有支持到这个版本，那么如何适配呢，a 先找出当前xcode 的uuid ，用命令 `defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID` ，然后将输出的日志添加到插件的工程文件plist DVTPlugInCompatibilityUUIDs 字段中，重新回到第一步，重新编译


