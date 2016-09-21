//
//  NSTimer+Addition.m
//  XTLoopScroll
//
//  Created by TuTu on 15/11/2.
//  Copyright © 2015年 teason. All rights reserved.
//

#import "NSTimer+Addition.h"

@implementation NSTimer (Addition)

- (void)pause
{
    [self setFireDate:[NSDate distantFuture]];
}

- (void)resume
{
    [self setFireDate:[NSDate date]];
}

@end
