//
//  YFBannerView.h
//
//  Created by brave on 15/11/17.
//  Copyright © 2015年 Xingren. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief  控制在banner上滚动的每一张画面的属性
 */
@interface YFBannerItem : NSObject

/**
 *  @brief 显示的图片
 */
@property (nonatomic, strong) UIImage *image;

/**
 *  @brief  图片的url地址 @note 优先使用`image`，找不到就会下载url
 */
@property (nonatomic, strong) NSString *imageUrlString;

/**
 *  @brief  正在从url下载时的占位图片
 */
@property (nonatomic, strong) UIImage *placeHolderImage;

/**
 *  @brief url
 */
@property (nonatomic, strong) NSString *urlString;

/**
 *  @brief  点击图片触发动作的target
 */
@property (nonatomic, weak) id itemTarget;

/**
 *  @brief  点击图片触发的selector
 */
@property (nonatomic, assign) SEL itemSelector;

@end


@interface YFBannerView : UIView <UIScrollViewDelegate>

/**
 *  @brief  是否开启循环滚动，默认YES
 */
@property (nonatomic, assign) BOOL isLoop;

/**
 *  @brief  分页指示颜色，默认：FIXME
 */
@property (nonatomic, strong) UIColor *pageControlTintColor;

/**
 *  @brief  分页指示高亮颜色，默认：FIXME
 */
@property (nonatomic, strong) UIColor *pageControlHilightColor;

/**
 *  @brief  是否随scrollView的contentOffset进行拉伸 @note 必须保证`springAttachScrollView`有值才能启用果冻效果
 */
@property (nonatomic, assign) BOOL springWithScroll;

/**
 *  @brief 如果打开springWithScroll，banner将会随springAttachScrollView的offset进行拉伸
 */
@property (nonatomic, weak) UIScrollView *springAttachScrollView;

/**
 *  @brief  banner显示的内容数组，成员都是XRBannerItem对象 @note 赋值该属性将导致重绘
 */
@property (nonatomic, strong) NSArray *itemArray;

/**
 *  @brief 初始化方法
 */
- (instancetype)initWithItemArray:(NSArray *)itemArray;

/**
 *  @brief  开始自动滚动
 */
- (void)startAutoScroll;

/**
 *  @brief  停止自动滚动
 */
- (void)stopAutoScroll;

@end
