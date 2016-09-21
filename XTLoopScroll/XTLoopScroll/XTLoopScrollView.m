//
//  XTLoopScrollView.m
//  XTLoopScroll
//
//  Created by TuTu on 15/10/30.
//  Copyright © 2015年 teason. All rights reserved.
//

#import "XTLoopScrollView.h"
#import "NSTimer+Addition.h"
#import "HWWeakTimer.h"

static int IMAGEVIEW_COUNT = 3 ;

@interface XTLoopScrollView () <UIScrollViewDelegate>
{
    UIScrollView            *_scrollView ;
    
    UIImageView             *_leftImageView;
    UIImageView             *_centerImageView;
    UIImageView             *_rightImageView;
    
    BOOL                    _bLoop ;
    NSInteger               _durationOfScroll ;

    NSTimer                 *_timerLoop ;           // 控制循环
    NSTimer                 *_timerOverflow ;       // 控制手动后的等待时间
    BOOL                    bOpenTimer ;            // 开关
}
@property (nonatomic)         int           currentImageIndex ;
@property (nonatomic)         int           imageCount ;
@property (nonatomic,strong)  UIPageControl *pageControl ;

@end

@implementation XTLoopScrollView
@synthesize color_currentPageControl = _color_currentPageControl ,
            color_pageControl = _color_pageControl ;

#pragma mark - Public prop
- (void)setImglist:(NSArray *)imglist
{
    _imglist = imglist ;
    
    self.imageCount = (int)self.imglist.count ;
    [self setDefaultImage] ;
}

- (void)setColor_pageControl:(UIColor *)color_pageControl
{
    _color_pageControl = color_pageControl ;
    
    self.pageControl.pageIndicatorTintColor = _color_pageControl ;
}

- (UIColor *)color_pageControl
{
    if (!_color_pageControl) {
        _color_pageControl = [UIColor grayColor] ;
    }
    return _color_pageControl ;
}

- (void)setColor_currentPageControl:(UIColor *)color_currentPageControl
{
    _color_currentPageControl = color_currentPageControl ;
    
    self.pageControl.currentPageIndicatorTintColor = _color_currentPageControl ;
}

- (UIColor *)color_currentPageControl
{
    if (!_color_currentPageControl) {
        _color_currentPageControl = [UIColor darkGrayColor] ;
    }
    return _color_currentPageControl ;
}

#pragma mark - private prop
- (void)setImageCount:(int)imageCount
{
    _imageCount = imageCount ;
    
    if (imageCount <= 1) {
        _scrollView.scrollEnabled = NO ;
        return ;
    }
    _scrollView.scrollEnabled = YES ;
    self.pageControl.numberOfPages = imageCount ;
    CGSize size = [self.pageControl sizeForNumberOfPages:imageCount];
    self.pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
    self.pageControl.center = CGPointMake(self.frame.size.width - size.width - 0. , self.frame.size.height - 20.) ;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init] ;
        _pageControl.pageIndicatorTintColor = self.color_pageControl ;
        _pageControl.currentPageIndicatorTintColor = self.color_currentPageControl ;
        if (!_pageControl.superview) {
            [self addSubview:_pageControl];
        }
    }
    
    return _pageControl ;
}


#pragma - Initial
- (instancetype)initWithFrame:(CGRect)frame
                 andImageList:(NSArray *)imglist
                      canLoop:(BOOL)canLoop
                     duration:(NSInteger)duration
{
    self = [self initWithFrame:frame canLoop:canLoop duration:duration] ;
    self.imglist = imglist ;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                      canLoop:(BOOL)canLoop
                     duration:(NSInteger)duration
{
    self = [super init];
    if (self)
    {
        self.frame = frame ;
        _bLoop = canLoop ;
        _durationOfScroll = duration ;
        self.backgroundColor = [UIColor whiteColor] ;
        [self setup] ;
        
        if (_bLoop) [self loopStart] ;
    }
    return self;
}


#pragma mark -

- (void)startLoop
{
    [self stopLoop] ;
    
    if (!_timerLoop.isValid || !_timerLoop) {
        [self loopStart] ;
    }
}

- (void)stopLoop
{
    _currentImageIndex = 0 ;
    [self setViewInDefault] ;
    
    [_timerLoop invalidate] ;
    _timerLoop = nil ;
    
    if ([_timerOverflow isValid]) [_timerOverflow invalidate] ;
}

#pragma mark -

- (void)setup
{
    //添加滚动控件
    [self addScrollView];
    //添加图片控件
    [self addImageViews];
}

- (void)loopStart
{
    if (_timerLoop == nil) {
        _timerLoop = [HWWeakTimer scheduledTimerWithTimeInterval:_durationOfScroll
                                                          target:self
                                                        selector:@selector(loopAction)
                                                        userInfo:nil
                                                         repeats:YES] ;
    }

}

- (void)loopAction
{
    if (_imageCount <= 1) return ;

    
    int leftImageIndex , rightImageIndex ;
    _currentImageIndex = (_currentImageIndex + 1) % _imageCount ;
    _centerImageView.image = [UIImage imageNamed:_imglist[_currentImageIndex]] ;
    
    leftImageIndex  = (_currentImageIndex + _imageCount - 1) % _imageCount ;
    rightImageIndex = (_currentImageIndex + 1) % _imageCount ;
    
    _leftImageView.image  = [UIImage imageNamed:_imglist[leftImageIndex]]  ;
    _rightImageView.image = [UIImage imageNamed:_imglist[rightImageIndex]] ;
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width , 0) animated:NO] ;
    
    CATransition *animation = [CATransition animation] ;
    [animation setDuration:0.35f] ;
    [animation setType:kCATransitionPush] ;
    [animation setSubtype:kCATransitionFromRight] ;
    [animation setFillMode:kCAFillModeForwards] ;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]] ;
    [_centerImageView.layer addAnimation:animation forKey:nil] ;
    
    _pageControl.currentPage=_currentImageIndex ;

}

#pragma mark 添加控件
- (void)addScrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init] ;
    }
    CGRect rect = CGRectZero ;
    rect.size = self.frame.size ;
    _scrollView.frame = rect ;
    _scrollView.bounces = false ;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(IMAGEVIEW_COUNT * _scrollView.frame.size.width, _scrollView.frame.size.height) ;
    //设置当前显示的位置为中间图片
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
    
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator=NO;
    
    if (![_scrollView superview]) {
        [self addSubview:_scrollView] ;
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollView)] ;
    [_scrollView addGestureRecognizer:tapGesture] ;
}

- (void)tapScrollView
{
    NSLog(@"tap in xtloopscroll : %d",_currentImageIndex) ;
    [self.delegate tapingCurrentIndex:_currentImageIndex] ;
}

#pragma mark 添加图片三个控件
- (void)addImageViews
{
    _leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    _leftImageView.layer.masksToBounds = YES ;
    [_scrollView addSubview:_leftImageView];
    _centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)] ;
    _centerImageView.contentMode = UIViewContentModeScaleAspectFill;
    _centerImageView.layer.masksToBounds = YES ;
    [_scrollView addSubview:_centerImageView] ;
    _rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(2 * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)] ;
    _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    _rightImageView.layer.masksToBounds = YES ;
    [_scrollView addSubview:_rightImageView] ;
}

#pragma mark 设置默认显示图片
- (void)setDefaultImage
{
    if (!_imglist || !_imglist.count) {
        return ;
    }
    
    _centerImageView.image  = [UIImage imageNamed:_imglist[0]] ;
    if (_imageCount > 1)
    {
        _leftImageView.image    = [UIImage imageNamed:_imglist[_imageCount - 1]] ;
        _rightImageView.image   = [UIImage imageNamed:_imglist[1]] ;
    }
    // current index
    _currentImageIndex = 0 ;
    _pageControl.currentPage = 0 ;

}

#pragma mark 滚动停止事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //重新加载图片
    [self reloadImage];
    //移动到中间
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
    //设置分页
    self.pageControl.currentPage = _currentImageIndex;
}

- (void)setViewInDefault
{
    //重新加载图片
    [self reloadImage];
    //移动到中间
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
    //设置分页
    self.pageControl.currentPage = _currentImageIndex;
}


#pragma mark 重新加载图片
- (void)reloadImage
{
    if (!_imageCount) {
        return ;
    }
    
    [self resumeTimerWithDelay] ;
    
    int leftImageIndex,rightImageIndex ;
    CGPoint offset = [_scrollView contentOffset] ;
    
    if (offset.x > self.frame.size.width)
    { //  向右滑动
        _currentImageIndex = (_currentImageIndex + 1) % _imageCount ;
    }
    else if(offset.x < self.frame.size.width)
    { //  向左滑动
        _currentImageIndex = (_currentImageIndex + _imageCount - 1) % _imageCount ;
    }
    
    _centerImageView.image = [UIImage imageNamed:_imglist[_currentImageIndex]];
    
    //  重新设置左右图片
    leftImageIndex  = (_currentImageIndex + _imageCount - 1) % _imageCount ;
    rightImageIndex = (_currentImageIndex + 1) % _imageCount ;
    _leftImageView.image  = [UIImage imageNamed:_imglist[leftImageIndex]]  ;
    _rightImageView.image = [UIImage imageNamed:_imglist[rightImageIndex]] ;
    
}

- (void)resumeTimerWithDelay
{
    [_timerLoop pause] ;

    if (!bOpenTimer)
    {
        if ([_timerOverflow isValid])
        {
            [_timerOverflow invalidate] ;
        }

        _timerOverflow = [HWWeakTimer scheduledTimerWithTimeInterval:_durationOfScroll
                                                              target:self
                                                            selector:@selector(timerIsOverflow)
                                                            userInfo:nil
                                                             repeats:NO] ;
    }
}

- (void)timerIsOverflow
{
    bOpenTimer = YES ;
    
    if (bOpenTimer)
    {
        [_timerLoop resume] ;
        bOpenTimer = NO ;
        
        [_timerOverflow invalidate] ;
        _timerOverflow = nil ;
    }
}


- (void)dealloc
{
    [_timerLoop invalidate] ;
    [_timerOverflow invalidate] ;
    
    _timerLoop = nil ;
    _timerOverflow = nil ;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
