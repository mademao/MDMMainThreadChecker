//
//  CustomView.h
//  MDMMainThreadCheckerDemo
//
//  Created by mademao on 2021/2/4.
//  Copyright © 2021 mademao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomView : UIView

@property (nonatomic, copy) NSString *name;

+ (NSString *)testString;

@end

NS_ASSUME_NONNULL_END
