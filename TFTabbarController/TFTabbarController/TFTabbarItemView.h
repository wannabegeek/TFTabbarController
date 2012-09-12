//
//  TFTabbarItemCell.h
//  TFTabbar
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const CGFloat tabCornerRadius;

typedef enum {
	TFTabbarItemIsSelected,
	TFTabbarItemBeforeSelection,
	TFTabbarItemAfterSelection
} TFTabbarItemLocation;

@class TFTabbarItemView;
@protocol TFTabbarItemViewDelegate <NSObject>
- (void)selectedTab:(TFTabbarItemView *)itemView;
- (void)removeTab:(TFTabbarItemView *)itemView;
@end

@interface TFTabbarItemView : NSView

@property (assign) NSUInteger index;
@property (strong) NSString *title;
@property (assign) TFTabbarItemLocation location;

@property (weak) NSObject<TFTabbarItemViewDelegate> *delegate;

- (void)setCanClose:(BOOL)value;

@end
