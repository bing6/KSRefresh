//
//  KSRefreshView.m
//  KSRefresh
//
//  Created by bing.hao on 15/4/4.
//  Copyright (c) 2015年 bing.hao. All rights reserved.
//

#import "KSRefreshView.h"


@implementation KSHeadRefreshView

@synthesize targetView = _targetView;
@synthesize targetViewOriginalEdgeInsets = _targetViewOriginalEdgeInsets;
@synthesize state = _state;
@synthesize delegate = _delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, -KSRefreshView_Height, KS_SCREEN_WIDTH, KSRefreshView_Height);
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<KSRefreshViewDelegate>)delegate
{
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setState:(RefreshViewState)state
{
    _state = state;
    if ([self.delegate respondsToSelector:@selector(refreshView:didChangeState:)]) {
        [self.delegate refreshView:self didChangeState:self.state];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:nil];
    
    if (newSuperview) {
        self.targetView = (UIScrollView *)newSuperview;
        self.targetViewOriginalEdgeInsets = self.targetView.contentInset;
        [self.targetView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.state == RefreshViewStateLoading) {
        return;
    }
    
    CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
    UIEdgeInsets original = self.targetViewOriginalEdgeInsets;
    
    CGFloat offsetThreshold = self.frame.origin.y - original.top;
    
    if (!self.targetView.isDragging && self.state == RefreshViewStateTriggered) {
        self.state = RefreshViewStateLoading;
    } else if (point.y > offsetThreshold && point.y < - original.top && self.targetView.isDragging && self.state != RefreshViewStateLoading) {
        self.state = RefreshViewStateVisible;
    } else if (point.y < offsetThreshold && self.targetView.isDragging && self.state == RefreshViewStateVisible) {
        self.state = RefreshViewStateTriggered;
    } else if (point.y >= -original.top && self.state != RefreshViewStateDefault) {
        self.state = RefreshViewStateDefault;
    }
}

@end


@implementation KSFootRefreshView

@synthesize targetView = _targetView;
@synthesize targetViewOriginalEdgeInsets = _targetViewOriginalEdgeInsets;
@synthesize state = _state;
@synthesize delegate = _delegate;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, KS_SCREEN_WIDTH, KSRefreshView_Height);
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<KSRefreshViewDelegate>)delegate
{
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setState:(RefreshViewState)state
{
    _state = state;
    if ([self.delegate respondsToSelector:@selector(refreshView:didChangeState:)]) {
        [self.delegate refreshView:self didChangeState:self.state];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:nil];
    [self.superview removeObserver:self forKeyPath:@"contentSize" context:nil];
    
    if (newSuperview) {
        self.targetView = (UIScrollView *)newSuperview;
        self.targetViewOriginalEdgeInsets = self.targetView.contentInset;
        [self.targetView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [self.targetView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (self.hidden || self.isLastPage || RefreshViewStateLoading == self.state) {
            return;
        }
        
        CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        CGFloat offsetThreshold = self.frame.origin.y;
        CGFloat currentY        = point.y + self.targetView.frame.size.height;
        
        if (self.targetView.isDragging == NO && self.state == RefreshViewStateTriggered) {
            self.state = RefreshViewStateLoading;
        } else if (self.targetView.isDragging && currentY > offsetThreshold && currentY < offsetThreshold + KSRefreshView_Height && self.state != RefreshViewStateLoading) {
            self.state = RefreshViewStateVisible;
        } else if (self.targetView.isDragging && currentY >= (offsetThreshold + KSRefreshView_Height) && self.state == RefreshViewStateVisible) {
            self.state = RefreshViewStateTriggered;
        } else if (currentY <= offsetThreshold && self.state != RefreshViewStateDefault && self.state != RefreshViewStateLoading) {
            self.state = RefreshViewStateDefault;
        }
        
        return;
    }
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGSize size = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];
        CGFloat bottom = self.targetViewOriginalEdgeInsets.bottom;
        
        self.hidden = !(size.height > self.targetView.frame.size.height);
        CGRect frame = self.frame;
        frame.origin.x = 0;
        frame.origin.y = MAX(size.height, self.frame.size.height) + bottom;
        self.frame  = frame;
            
        return;
    }
}


@end



















