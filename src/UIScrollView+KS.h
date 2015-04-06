//
//  UIScrollView+KS.h
//  KSRefresh
//
//  Created by bing.hao on 15/4/6.
//  Copyright (c) 2015年 bing.hao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSDefaultHeadRefreshView.h"
#import "KSDefaultFootRefreshView.h"
#import "KSAutoFootRefreshView.h"

@interface UIScrollView (KS)

@property (nonatomic, strong) KSHeadRefreshView * header;
@property (nonatomic, strong) KSFootRefreshView * footer;

@end
