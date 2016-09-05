//
//  YFBannerView.m
//
//  Created by brave on 15/11/17.
//  Copyright © 2015年 Xingren. All rights reserved.
//

#import "YFBannerView.h"
#import "PureLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"

#define kBannerViewWidth self.frame.size.width
#define IMAGEVIEW_COUNT 3
#define kBannerViewHeight self.frame.size.height
#define ColorSet(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_height [UIScreen mainScreen].bounds.size.height

@implementation YFBannerItem

@end

@implementation YFBannerView
{
    UIScrollView *_scrollView;
    
    UIImageView *_leftImageView;
    
    UIImageView *_centerImageView;
    
    UIImageView *_rightImageView;
    
    UIPageControl *_pageControl;
    
    NSInteger _imageCount;
    
    NSInteger _currentImageIndex;
    
    NSTimer *_scrollTimer;
    
    NSMutableArray *_imageArray;
    
    BOOL _registeredKVO;
}

- (instancetype)initWithItemArray:(NSArray *)itemArray
{
    self = [super init];
    
    if (self) {
        
        self.itemArray = [NSArray arrayWithArray:itemArray];
        
        self.backgroundColor = ColorSet(240, 240, 240, 1.0);
    }
    
    return self;
}

- (void)setItemArray:(NSArray *)itemArray
{
    _itemArray = itemArray;
    
    if (_itemArray.count == 0) {
        
        return;
    }
    
    _imageCount = self.itemArray.count;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addScrollView];
    [self addImageViews];
    [self setDefaultImage];
    [self addPageControl];
}

-(void)addScrollView
{
    _scrollView = ({
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kBannerViewWidth, kBannerViewHeight)];
        
        scrollView.backgroundColor = ColorSet(240, 240, 240, 1.0);
        
        scrollView.delegate = self;
        
        // 只有一个 banner 不需要滑动
        if (_imageCount > 1)
        {
            scrollView.contentSize = CGSizeMake(IMAGEVIEW_COUNT*kBannerViewWidth, 0);
            
        } else {
            
            scrollView.contentSize = CGSizeMake(_imageCount*kBannerViewWidth, 0);
        }
        
        [scrollView setContentOffset:CGPointMake(kBannerViewWidth, 0) animated:NO];
        
        scrollView.pagingEnabled = YES;
        
        scrollView.showsHorizontalScrollIndicator = NO;
        
        scrollView.scrollsToTop = NO;
        
        scrollView;
    });
    
    _scrollView.isAccessibilityElement = YES;
    _scrollView.accessibilityIdentifier = @"bannerScroll";
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    
    [self addGestureRecognizer:tapGesture];
    
    [self addSubview:_scrollView];
}

-(void)addImageViews
{
    _leftImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kBannerViewWidth, 175.0/568*Screen_height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView;
    });
    
    _centerImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kBannerViewWidth, 0, kBannerViewWidth, 175.0/568*Screen_height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView;
    });
    
    [_scrollView addSubview:_leftImageView];
    [_scrollView addSubview:_centerImageView];
    
    if (_imageCount > 1)
    {
        _rightImageView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2*kBannerViewWidth, 0, kBannerViewWidth, 175.0/568*Screen_height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView;
        });
        
        [_scrollView addSubview:_rightImageView];
        
    }
}

-(void)setDefaultImage
{
    // 需要考虑只有1张的情况
    YFBannerItem *leftItem = _itemArray[_imageCount-1];
    YFBannerItem *centerItem = _itemArray[0];
    [self configureImageForImageView:_leftImageView bannerItem:leftItem];
    [self configureImageForImageView:_centerImageView bannerItem:centerItem];
    
    if (_imageCount > 1)
    {
        YFBannerItem *rightItem = _itemArray[1];
        [self configureImageForImageView:_rightImageView bannerItem:rightItem];
    }
    
    // 设置当前页
    _currentImageIndex = 0;
    
    _pageControl.currentPage = _currentImageIndex;
}

-(void)addPageControl
{
    // 图片少于2张 不显示pageControl
    if (_imageCount < 2)
    {
        return;
    }
    
    _pageControl = ({
        
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        
        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:193/255.0 green:219/255.0 blue:249/255.0 alpha:1];
        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0 green:150/255.0 blue:1 alpha:1];
        pageControl.numberOfPages = _imageCount;
        pageControl;
    });
    
    [self addSubview:_pageControl];
    
    [_pageControl autoSetDimensionsToSize:CGSizeMake(60, 8)];
    
    [_pageControl autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:-6.f];
    
    [_pageControl autoAlignAxisToSuperviewAxis:ALAxisVertical];
}

- (void)setPageControlTintColor:(UIColor *)pageControlTintColor
{
    _pageControlTintColor = pageControlTintColor;
    
    _pageControl.pageIndicatorTintColor = _pageControlTintColor;
}

- (void)setPageControlHilightColor:(UIColor *)pageControlHilightColor
{
    _pageControlHilightColor = pageControlHilightColor;
    
    _pageControl.currentPageIndicatorTintColor = _pageControlHilightColor;
}

- (void)setSpringAttachScrollView:(UIScrollView *)springAttachScrollView
{
    if (_registeredKVO) {
        
        [_springAttachScrollView removeObserver:self forKeyPath:@"contentOffset"];
        
        _registeredKVO = NO;
    }
    
    _springAttachScrollView = springAttachScrollView;
    
    if (_springWithScroll) {
        
        [_springAttachScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        
        _registeredKVO = YES;
    }
}

- (void)setSpringWithScroll:(BOOL)springWithScroll
{
    if (_registeredKVO) {
        
        [_springAttachScrollView removeObserver:self forKeyPath:@"contentOffset"];
        
        _registeredKVO = NO;
    }
    
    _springWithScroll = springWithScroll;
    
    if (_springWithScroll) {
        
        [_springAttachScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        
        _registeredKVO = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"contentOffset"]) {
        
        return;
    }
    
    CGFloat offsetY = [change[@"new"] CGPointValue].y;
    
    CGFloat actualDropdownHeight = (-offsetY) - 111.0;
    
    [self jellySpecialEffectsAdjustWithDropdownHeight:actualDropdownHeight];
    
}

#pragma mark - scrollview delegate
#pragma mark -
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!_itemArray || _itemArray.count == 0 || _itemArray.count == 1) {
        
        return;
    }
    
    [self reloadImage];
    
    [_scrollView setContentOffset:CGPointMake(kBannerViewWidth, 0) animated:NO];
    
    _pageControl.currentPage = _currentImageIndex;
    
    [self startAutoScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopAutoScroll];
}

#pragma mark - auto scroll
#pragma mark -
- (void)startAutoScroll
{
    if (!_itemArray || _itemArray.count == 0 || _itemArray.count == 1) {
        return;
    }
    
    if (_isLoop) {
        
        if (_scrollTimer && [_scrollTimer isValid]) {
            
            [_scrollTimer invalidate];
        }
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoScrollAction) userInfo:nil repeats:YES];
    }
}

- (void)stopAutoScroll
{
    if (_scrollTimer) {
        
        [_scrollTimer invalidate];
        
        _scrollTimer = nil;
    }
}

- (void)autoScrollAction
{
    if (!_itemArray || _itemArray.count == 0 || _itemArray.count == 1) {
        
        return;
    }
    
    // 1.n && n`
    YFBannerItem *next, *next2, *currrent;
    
    NSInteger nextIndex = _currentImageIndex == _itemArray.count - 1 ? 0 : (_currentImageIndex + 1);
    NSInteger next2Index = nextIndex == _itemArray.count - 1 ? 0 : (nextIndex + 1);
    
    next = [_itemArray objectAtIndex:nextIndex];
    next2 = [_itemArray objectAtIndex:next2Index];
    currrent = [_itemArray objectAtIndex:_currentImageIndex];
    
    // 2
    [self configureImageForImageView:_rightImageView bannerItem:next2];
    
    // 3
    [self configureImageForImageView:_leftImageView bannerItem:currrent];
    
    // 4
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    // 5
    [self configureImageForImageView:_centerImageView bannerItem:next];
    
    // 6
    [_scrollView setContentOffset:CGPointMake(kBannerViewWidth, 0) animated:YES];
    
    _currentImageIndex = nextIndex;
    
    _pageControl.currentPage = _currentImageIndex;
}

- (void)tapped {
    
    if (!_itemArray.count) {
        return;
    }
    
    YFBannerItem *item = [_itemArray objectAtIndex:_currentImageIndex];
    
    if (item && item.itemSelector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [item.itemTarget performSelector:item.itemSelector withObject:item.urlString];
#pragma clang diagnostic pop
    }
}

- (void)configureImageForImageView:(UIImageView *)imageView bannerItem:(YFBannerItem *)item
{
    if (!item.image) {
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrlString] placeholderImage:item.placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (image && !error) {
                
                item.image = image;
            }
        }];
        
    } else {
        
        imageView.image = item.image;
    }
}

-(void)reloadImage
{
    if (!_itemArray || _itemArray.count == 0 || _itemArray.count == 1) {
        
        return;
    }
    
    int leftImageIndex, rightImageIndex;
    CGPoint offset = _scrollView.contentOffset;
    
    if (offset.x > kBannerViewWidth)
    {
        // 向右滑动
        _currentImageIndex = (_currentImageIndex + 1) % _imageCount;
    }
    else if(offset.x < kBannerViewWidth)
    {
        // 向左滑动
        _currentImageIndex = (_currentImageIndex + _imageCount - 1) % _imageCount;
    }
    
    YFBannerItem *centerItem = _itemArray[_currentImageIndex];
    [self configureImageForImageView:_centerImageView bannerItem:centerItem];
    
    // 重新设置左右图片
    leftImageIndex = (_currentImageIndex + (int)_imageCount-1) % (int)_imageCount;
    rightImageIndex = (_currentImageIndex + 1) % (int)_imageCount;
    
    YFBannerItem *leftItem = _itemArray[leftImageIndex];
    YFBannerItem *rightItem = _itemArray[rightImageIndex];
    
    [self configureImageForImageView:_leftImageView bannerItem:leftItem];
    [self configureImageForImageView:_rightImageView bannerItem:rightItem];
}

- (void)dealloc
{
    _scrollView.delegate = nil;
    
    if (_registeredKVO) {
        
        [_springAttachScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
}


- (void)jellySpecialEffectsAdjustWithDropdownHeight:(CGFloat)dropdownHeight
{
    CGRect newFrame = self.frame;
    
    if (dropdownHeight > 0) {
        
        newFrame.origin.y = - 64;
        
        newFrame.size.height = dropdownHeight + 175;
        
        self.frame = newFrame;
        
        _scrollView.frame = self.bounds;
        
        for (UIView *scrollSubview in _scrollView.subviews) {
            
            if ([scrollSubview isMemberOfClass:[UIImageView class]]) {
                
                CGRect oldFrame = scrollSubview.frame;
                CGRect newFrame = CGRectZero;
                newFrame.size.height = _scrollView.frame.size.height;
                newFrame.size.width = oldFrame.size.width;
                
                scrollSubview.frame = newFrame;
                scrollSubview.center = CGPointMake(CGRectGetMidX(oldFrame), CGRectGetMidY(_scrollView.bounds));
            }
        }
        
    } else {
        
        newFrame.size.height = 175;
        newFrame.origin.y = dropdownHeight - 64;
        
        self.frame = newFrame;
        
        _scrollView.frame = self.bounds;
        
        for (UIView *scrollSubview in _scrollView.subviews) {
            
            if ([scrollSubview isMemberOfClass:[UIImageView class]]) {
                
                CGRect oldFrame = scrollSubview.frame;
                CGRect newFrame = CGRectZero;
                newFrame.size.height = _scrollView.frame.size.height;
                newFrame.size.width = oldFrame.size.width;
                
                scrollSubview.frame = newFrame;
                scrollSubview.center = CGPointMake(CGRectGetMidX(oldFrame), CGRectGetMidY(_scrollView.bounds));
            }
        }
    }
}

@end
