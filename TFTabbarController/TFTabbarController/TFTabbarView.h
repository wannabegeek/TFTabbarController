//
//  TFTabbarView.h
//  TFTabbar
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TFTabbarItemView.h"

@class TFTabbarController;

extern const CGFloat tabCornerRadius;

@interface TFTabbarView : NSView <TFTabbarItemViewDelegate, NSTabViewDelegate>

@property (nonatomic, weak) IBOutlet NSView *contentView;
@property (weak) TFTabbarController *controller;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (void)createNewTabAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeTabAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)refreshTitles;
@end
