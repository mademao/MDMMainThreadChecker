# iOS主线程UI调用监测工具

## 一、Xcode主线程UI调用监测使用介绍

在iOS中，UI的调用只能在主线程中进行，若在子线程中调用UI，会发生意想不到的问题。

Xcode为开发者提供了在调试时的UI调用监测，该功能是默认开启的：

![Xcode提供的UI调用监测功能](https://github.com/mademao/MDMMainThreadChecker/raw/master/pic/XcodeMainThreadChecker.png)

该功能在使用Xcode Run进行调试时，若发生UI调用，会发生相应的提醒：1.控制台展示调用栈 2.Xcode增加一个Runtime Issue

![Xcode控制台提示](https://github.com/mademao/MDMMainThreadChecker/raw/master/pic/Xcode_ConsoleResult.png)

![Xcode新增的Runtime Issue](https://github.com/mademao/MDMMainThreadChecker/raw/master/pic/Xcode_RuntimeIssue.png)

另外还可以增加一个Runtime类型的断点，指定该断点为MainThreadChecker，当发生UI调用时，会进入断点：

![Xcode提供的UI调用监测功能](https://github.com/mademao/MDMMainThreadChecker/raw/master/pic/Xcode_RuntimeIssueBreakCreate.png)

![Xcode提供的UI调用监测功能](https://github.com/mademao/MDMMainThreadChecker/raw/master/pic/Xcode_RuntimeIssueBreakEdit.png)

![Xcode提供的UI调用监测功能](https://github.com/mademao/MDMMainThreadChecker/raw/master/pic/Xcode_RuntimeIssueBreak.png)



## 二、功能缺陷及补救

以上功能只有在连接Xcode运行时才会生效，在断开Xcode之后，无论是Debug包还是Release包，均无法触发该监测功能。

Xcode实现该功能是依赖于设备上的```libMainThreadChecker.dylib```库，我们可以通过```dlopen```方法强制加载该库让非Xcode环境下也拥有监测功能。

另外在检测到UI调用时，在Xcode环境下，会将调用栈输出到控制台，经过测试，```libMainThreadChecker.dylib```使用的是```NSLog```进行输出的，由于```NSLog```是将信息输出到```STDERR```中，我们可以通过```NSPipe```与```dup2```将```STDERR```输出拦截，通过对信息的文案的判断，进而获取监测到的UI调用，最后可以通过一些Alert来进行警告展示。

![Xcode提供的UI调用监测功能](https://github.com/mademao/MDMMainThreadChecker/raw/master/pic/MainThreadChecker_Result.png)

## 三、功能扩展

`libMainThreadChecker.dylib`库仅支持对系统提供的一些特定类的特定API进行调用监测（例如UIKit框架中UIView类），如果我们想要对项目内自己编写的类的某些方法进行主线程调用监测，仅仅简单加载`libMainThreadChecker.dylib`是无法满足的。

通过对`libMainThreadChecker.dylib`库的汇编代码调研，发现`libMainThreadChecker.dylib`是通过内部的`__main_thread_add_check_for_selector`方法来进行类和方法的注册的，那么我们同样可以通过`dlsym`来调用该方法，以达到对自定义类和方法的主线程调用监测。

**以上框架主要解决在测试过程中对UI子线程调用的监测，不建议将该功能上线到正式环境。**