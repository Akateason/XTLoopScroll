# XTLoopScroll
iOS auto Loop scrollview

###HOW TO USE IT ?  http://www.jianshu.com/p/a43ffcf666d9

1自动轮播
2点击监听回调当前图片
3手动滑动后重新计算轮播的开始时间, 良好的用户体验


    XTLoopScrollView *loopScroll = [[XTLoopScrollView alloc] initWithFrame:rect
                                                              andImageList:@[@"1",@"2",@"3",@"4",@"5"]
                                                                   canLoop:YES
                                                                  duration:5.0] ;

    loopScroll.color_pageControl        = [UIColor colorWithRed:250.0/255.0 green:219/255.0 blue:249/255.0 alpha:1] ;
    loopScroll.color_currentPageControl = [UIColor redColor] ;

    [self.view addSubview:loopScroll] ;
    
    
    
