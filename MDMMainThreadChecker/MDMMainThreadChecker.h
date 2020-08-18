//
//  MDMMainThreadChecker.h
//  MDMMainThreadChecker
//
//  Created by mademao on 2020/8/17.
//  Copyright © 2020 mademao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MDMMainThreadCheckerDelegate <NSObject>

/// 监测到子线程调用UI的回调，该回调可能会在子线程触发
/// @param report 监测到的方法栈内容
- (void)mainThreadCheckerSendReport:(NSString *)report;

@end

@interface MDMMainThreadChecker : NSObject

/// 开启主线程UI监测
/// @param delegate 代理
+ (void)startCheckerWithDelegate:(id<MDMMainThreadCheckerDelegate>)delegate;

@end

