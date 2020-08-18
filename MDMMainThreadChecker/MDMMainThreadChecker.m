//
//  MDMMainThreadChecker.m
//  MDMMainThreadChecker
//
//  Created by mademao on 2020/8/17.
//  Copyright © 2020 mademao. All rights reserved.
//

#import "MDMMainThreadChecker.h"
#include <sys/sysctl.h>
#include <dlfcn.h>

/// 判断当前运行环境是否为连接Xcode调试环境，方法由苹果提供
/// https://developer.apple.com/library/archive/qa/qa1361/_index.html#//apple_ref/doc/uid/DTS10003368
static bool AmIBeingDebugged(void)
    // Returns true if the current process is being debugged (either
    // running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
 
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
 
    info.kp_proc.p_flag = 0;
 
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
 
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
 
    // Call sysctl.
 
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
 
    // We're being debugged if the P_TRACED flag is set.
 
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

@interface MDMMainThreadChecker ()

@property (nonatomic, assign) BOOL isRunning;

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, weak) id<MDMMainThreadCheckerDelegate> delegate;

@end

@implementation MDMMainThreadChecker

#pragma mark - Public Methods

+ (void)startCheckerWithDelegate:(id<MDMMainThreadCheckerDelegate>)delegate
{
    [[MDMMainThreadChecker sharedInstance] startCheckerWithDelegate:delegate];
}


#pragma mark - Private Methods

static MDMMainThreadChecker *checker = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checker = [[MDMMainThreadChecker alloc] init];
    });
    return checker;
}

- (void)startCheckerWithDelegate:(id<MDMMainThreadCheckerDelegate>)delegate
{
    self.delegate = delegate;
    
    if (self.isRunning) {
        return;
    }
    self.isRunning = YES;
    
    if (AmIBeingDebugged()) {
        return;
    }
    
#if TARGET_IPHONE_SIMULATOR
    return;  
#endif
    [self redirectSTD:STDERR_FILENO];
    dlopen("/Developer/usr/lib/libMainThreadChecker.dylib", RTLD_LAZY);
}

- (void)redirectSTD:(int)fd
{
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading];
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle];
    [pipeReadHandle readInBackgroundAndNotify];
}

- (void)redirectNotificationHandle:(NSNotification *)notification
{
    
    dispatch_async(self.queue, ^{
        if (self.delegate == nil ||
            [self.delegate respondsToSelector:@selector(mainThreadCheckerSendReport:)] == NO) {
            return;
        }
        NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([string containsString:@"Main Thread Checker"]) {
            [self.delegate mainThreadCheckerSendReport:string];
        }
    });
    
    if ([notification.object isKindOfClass:[NSFileHandle class]] == NO) {
        return;
    }
    
    NSFileHandle *pipeReadHandle = (NSFileHandle *)notification.object;
    [pipeReadHandle readInBackgroundAndNotify];
}


- (dispatch_queue_t)queue
{
    if (_queue == nil) {
        _queue = dispatch_queue_create("com.mademao.MainThreadChecker", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

@end
