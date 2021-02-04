//
//  AppDelegate.m
//  MDMMainThreadCheckerDemo
//
//  Created by mademao on 2020/8/17.
//  Copyright © 2020 mademao. All rights reserved.
//

#import "AppDelegate.h"
#import <MDMMainThreadChecker.h>
#import "CustomView.h"
#import <objc/runtime.h>

@interface AppDelegate () <MDMMainThreadCheckerDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *reportArray;
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MDMMainThreadChecker startCheckerWithDelegate:self];
    [MDMMainThreadChecker addCheckerForClass:[CustomView class] selector:@selector(name)];
    [MDMMainThreadChecker addCheckerForClass:object_getClass([CustomView class]) selector:@selector(testString)];
    
    return YES;
}


#pragma mark - MDMMainThreadCheckerDelegate

- (void)mainThreadCheckerSendReport:(NSString *)report
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.reportArray addObject:report];
        [self showReportIfNeeded];
    });
}


#pragma mark - private method

- (void)showReportIfNeeded
{
    if (self.reportArray.count <= 0 ||
        self.alertController) {
        return;
    }
    
    NSString *report = self.reportArray.firstObject;
    self.alertController = [UIAlertController alertControllerWithTitle:@"监测到子线程调用UI"
                                                                             message:report
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        [self.reportArray removeObject:report];
        self.alertController = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showReportIfNeeded];
        });
    }];
    [self.alertController addAction:alertAction];
    [self.window.rootViewController presentViewController:self.alertController animated:YES completion:nil];
}


#pragma mark - lazy load

- (NSMutableArray<NSString *> *)reportArray
{
    if (_reportArray == nil) {
        _reportArray = [NSMutableArray array];
    }
    return _reportArray;
}

@end
