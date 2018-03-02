# LSConsole
## 日志实时显示以及快速修改沙盒值方便测试,支持摇一摇出现，隐藏，以及一直悬浮显示

![image](https://github.com/lsmakethebest/LSConsole/blob/master/1.gif)
![image](https://github.com/lsmakethebest/LSConsole/blob/master/2.gif)

```
1.第一步
    //如果你定义了自己的log比如DLog,需要把DLog改成如下所示
    #define DLog(fmt, ...) LSLog(fmt,##__VA_ARGS__)
    //如果是新项目没有自定义log,则使用LSLog即可，但还是推荐自定义Log来解耦
    
2.第二步

#import "LSConsole.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //开启设置
    [LSConsole startDebugWithIsAlwaysShow:NO];//NO需要摇一摇出现,YES则一直显示
}

```

##  如果想修改默认值，在LSConsoleDefine.h文件里修改
```
//存储的本地日志文件最大数量
#define LSConsoleMaxFileCount    5
//textView上最多显示数量，避免卡顿，如果卡顿请降低改数值
#define LSConsoleMaxTextLength  10000
#define LSConsoleDefaultPrefix  @"LS"  //此处为寻找沙盒值时的前缀改成你定义的前缀就好了

```

## 项目所用摇一摇功能是给UIWindow加了分类监听通知，如果老项目已经有此功能了，可以去除此分类，在摇一摇时发送已定义的摇晃通知即可

