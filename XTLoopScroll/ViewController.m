//
//  ViewController.m
//  XTLoopScroll
//
//  Created by TuTu on 15/10/30.
//  Copyright © 2015年 teason. All rights reserved.
//

#import "XTLoopScrollView.h"
#import "ViewController.h"

@interface ViewController () <XTLoopScrollViewDelegate>

@end

@implementation ViewController

- (void)tapingCurrentIndex:(NSInteger)currentIndex
{
    NSLog(@"currently tapped picture's index is '%ld' ",(long)currentIndex) ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor blackColor] ;

    CGRect rect = CGRectMake(0, 20, APPFRAME.size.width, 100) ;
    XTLoopScrollView *loopScroll = [[XTLoopScrollView alloc] initWithFrame:rect
                                                              andImageList:@[@"1",@"2",@"3",@"4",@"5"]
                                                                   canLoop:YES
                                                                  duration:5.0] ;
    loopScroll.delegate = self ;
    loopScroll.color_pageControl        = [UIColor colorWithRed:250.0/255.0 green:219/255.0 blue:249/255.0 alpha:1] ;
    loopScroll.color_currentPageControl = [UIColor redColor] ;
    
    [self.view addSubview:loopScroll] ;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
