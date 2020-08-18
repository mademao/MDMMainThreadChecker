//
//  ViewController.m
//  MDMMainThreadCheckerDemo
//
//  Created by mademao on 2020/8/17.
//  Copyright © 2020 mademao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"子线程调用UI操作前NSLog打印");
        printf("子线程调用UI操作前printf打印\n");
        self.view.alpha = 0.8;
        NSLog(@"子线程调用UI操作后NSLog打印");
        printf("子线程调用UI操作后printf打印\n");
    });

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"子线程调用UI操作前NSLog打印");
        printf("子线程调用UI操作前printf打印\n");
        self.view.backgroundColor = [UIColor redColor];
        NSLog(@"子线程调用UI操作后NSLog打印");
        printf("子线程调用UI操作后printf打印\n");
    });
}


@end
