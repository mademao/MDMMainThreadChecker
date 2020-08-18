//
//  AppDelegate.m
//  MDMMainThreadCheckerDemo
//
//  Created by mademao on 2020/8/17.
//  Copyright © 2020 mademao. All rights reserved.
//

#import "AppDelegate.h"
#import <MDMMainThreadChecker.h>

@interface AppDelegate () <MDMMainThreadCheckerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MDMMainThreadChecker startCheckerWithDelegate:self];
    
    return YES;
}


#pragma mark - MDMMainThreadCheckerDelegate

- (void)mainThreadCheckerSendReport:(NSString *)report
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"监测到子线程调用UI" message:report preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertAction];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}


@end
