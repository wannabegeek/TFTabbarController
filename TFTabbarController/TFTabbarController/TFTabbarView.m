//
//  TFTabbarView.m
//  TFTabbar
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "TFTabbarView.h"
#import "TFTabbarItemView.h"
#import "HoverButton.h"
#import "TFTabbarController.h"
#import "TFTabbarController_Private.h"

#define PRECEEDING_PADDING 10.0f
#define MIN_TAB_SIZE 150.0f
#define MAX_TAB_SIZE 250.0f

@interface TFTabbarView ()
@property (strong) NSMutableArray *itemViews;
@property (strong) HoverButton *addTabButton;

- (void)setupTabCells;
- (void)layoutTabViewsWithAnimation:(BOOL)animated;
@end

@implementation TFTabbarView

@synthesize selectionIndexes = _selectionIndexes;
@synthesize itemViews = _itemViews;
@synthesize addTabButton = _addTabButton;
@synthesize contentView = _contentView;
@synthesize controller = _controller;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

		_itemViews = [NSMutableArray array];

		NSRect addTabBtnFrame = NSInsetRect(self.bounds, 5.0f, 2.5f);
		addTabBtnFrame.origin.x = addTabBtnFrame.size.width - 20.0f;
		addTabBtnFrame.size.width = 20.0f;

		_addTabButton = [[HoverButton alloc] initWithFrame:addTabBtnFrame];
		NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.wannabegeek.TFTabbarController"];
		_addTabButton.normalImage = [frameworkBundle imageForResource:@"NewTab"];
		_addTabButton.hoverImage = [frameworkBundle imageForResource:@"NewTabHover"];
		_addTabButton.autoresizingMask = NSViewMinXMargin;
		_addTabButton.target = self;
		_addTabButton.action = @selector(addTab:);
		[self addSubview:_addTabButton];

		[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeKeyNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
		[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	[[NSColor colorWithCalibratedRed:0.733 green:0.733 blue:0.733 alpha:1] set];
	NSRectFill(self.bounds);

	NSRect lineRect = NSInsetRect(self.bounds, 0.0f, -0.5f);
	lineRect.size.height = 1.0f;
	NSBezierPath *line = [NSBezierPath bezierPathWithRect:lineRect];
	[[NSColor grayColor] set];
	[line stroke];
}

// Resizin our frame will cause our tabs to be resized
// since there is a max and a min size for the tab, some may be removed
- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[self layoutTabViewsWithAnimation:NO];
}

// This will sort the subviews to that the selected tab is on-top, falling away at both sides
// e.g. relative layer levels are 3|2|1|0|1|2|3
NSInteger sortSubViews(TFTabbarItemView *cell1, TFTabbarItemView *cell2, void *context) {
	if ([cell1 isKindOfClass:[TFTabbarItemView class]] && [cell2 isKindOfClass:[TFTabbarItemView class]]) {
//		NSLog(@"Sorting %lu[%@] <=> %lu[%@]", cell1.index, ((cell1.location == TFTabbarItemBeforeSelection)?@"<":(cell1.location == TFTabbarItemAfterSelection)?@">":@"*"), cell2.index, ((cell2.location == TFTabbarItemBeforeSelection)?@"<":(cell2.location == TFTabbarItemAfterSelection)?@">":@"*"));
		if (cell1.location == TFTabbarItemIsSelected) {
			return NSOrderedDescending;
		} else if (cell2.location == TFTabbarItemIsSelected) {
			return NSOrderedAscending;
		} if (cell1.location == TFTabbarItemBeforeSelection && cell2.location == TFTabbarItemAfterSelection) {
			return NSOrderedAscending;
		} else if (cell2.location == TFTabbarItemBeforeSelection && cell1.location == TFTabbarItemAfterSelection) {
			return NSOrderedDescending;
		} else if (cell1.location == TFTabbarItemBeforeSelection && cell2.location == TFTabbarItemBeforeSelection) {
			if (cell1.index < cell2.index) {
				return NSOrderedAscending;
			} else if (cell1.index > cell2.index) {
				return NSOrderedDescending;
			}
		} else if (cell1.location == TFTabbarItemAfterSelection && cell2.location == TFTabbarItemAfterSelection) {
			if (cell1.index < cell2.index) {
				return NSOrderedDescending;
			} else if (cell1.index > cell2.index) {
				return NSOrderedAscending;
			}
		}
	}
	return NSOrderedSame;
}

// This will resize our tabs, removeing/addind as appropriate
- (void)layoutTabViewsWithAnimation:(BOOL)animated {
	NSRect itemFrame = self.bounds;
	itemFrame.origin.x = PRECEEDING_PADDING;

	CGFloat usableTabSpace = self.bounds.size.width - PRECEEDING_PADDING - (self.bounds.size.width - _addTabButton.frame.origin.x);
	CGFloat tabWidth = usableTabSpace / (CGFloat)[_itemViews count];

	tabWidth = MAX(tabWidth, MIN_TAB_SIZE);
	if (tabWidth > MAX_TAB_SIZE) {
		tabWidth = MAX_TAB_SIZE;
	}
	itemFrame.size.width = tabWidth;

	for (TFTabbarItemView *itemView in _itemViews) {
		if (itemFrame.origin.x + itemFrame.size.width > usableTabSpace) {
			// set the frame anyway, so when it re-appears it is animated fromt he correct location
			itemView.frame = itemFrame;
			[itemView removeFromSuperview];
		} else {
			if (!itemView.superview) {
				[self addSubview:itemView];
			}
			if (animated) {
				[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
					[context setDuration:0.25f];
					[[itemView animator] setFrame:itemFrame];
				} completionHandler:^{
					itemView.frame = itemFrame;
				}];
			} else {
				itemView.frame = itemFrame;
			}
		}
		itemFrame.origin.x += itemFrame.size.width - (tabCornerRadius * 4.0f);
	}

	[self sortSubviewsUsingFunction:sortSubViews context:nil];
}

- (void)createNewTabAtIndex:(NSUInteger)index animated:(BOOL)animated {
	TFTabbarItemView *itemView = [[TFTabbarItemView alloc] initWithFrame:NSZeroRect];
	itemView.delegate = self;
	itemView.title = [_controller requestTabTitleFromDelegateForIndex:index];
	[self addSubview:itemView];
	[_itemViews insertObject:itemView atIndex:index];

	[self layoutTabViewsWithAnimation:animated];
	[self setupTabCells];
}

- (void)removeTabAtIndex:(NSUInteger)index animated:(BOOL)animated {
	TFTabbarItemView *itemView = [_itemViews objectAtIndex:index];
	[itemView removeFromSuperview];
	[_itemViews removeObject:itemView];

	if ([_selectionIndexes lastIndex] == [_itemViews count]) {
		[self willChangeValueForKey:@"selectedIndex"];
		[NSIndexSet indexSetWithIndex:[_selectionIndexes lastIndex]-1];
		[self didChangeValueForKey:@"selectedIndex"];
	}

	[self layoutTabViewsWithAnimation:animated];
	[self setupTabCells];
}

- (void)refreshTitles {
	for (TFTabbarItemView *itemView in _itemViews) {
		NSString *previousTitle = itemView.title;
		itemView.title = [_controller requestTabTitleFromDelegateForIndex:[_itemViews indexOfObject:itemView]];
		if (![itemView.title isEqualToString:previousTitle]) {
			[itemView setNeedsDisplay:YES];
		}
	}
}

- (void)updateProperties {
	[_addTabButton setHidden:!_controller.canAdd];
	[_addTabButton setEnabled:_controller.enabled];
	for (TFTabbarItemView *itemView in _itemViews) {
		[itemView setCanClose:(_controller.enabled && _controller.canRemove)];
	}
}


- (void)setupTabCells {
	TFTabbarItemLocation currentTabLocation = TFTabbarItemBeforeSelection;

	for (NSUInteger index = 0; index < [_itemViews count]; index++) {
		TFTabbarItemView *itemView = [_itemViews objectAtIndex:index];
		itemView.index = index;
		if (index == [_selectionIndexes lastIndex]) {
			currentTabLocation = TFTabbarItemIsSelected;
		} else if (currentTabLocation == TFTabbarItemIsSelected) {
			currentTabLocation = TFTabbarItemAfterSelection;
		}

		itemView.location = currentTabLocation;
	}

	[self sortSubviewsUsingFunction:sortSubViews context:nil];
}

// This is called when the '+' button is clicked
- (void)addTab:(id)sender {
	NSLog(@"Need to add a tab");
	[_controller requestNewTabFromDelegate];
}

- (void)setSelectionIndexes:(NSIndexSet *)selectionIndexes {
	[self willChangeValueForKey:@"selectionIndexes"];
	_selectionIndexes = selectionIndexes;
	if ([_itemViews count] != 0) {
		if ([_selectionIndexes lastIndex] >= [_itemViews count]) {
			_selectionIndexes = [NSIndexSet indexSetWithIndex:[_itemViews count] - 1];
		}
		[self selectedTab:[_itemViews objectAtIndex:[_selectionIndexes lastIndex]]];
	}
	[self didChangeValueForKey:@"selectionIndexes"];
}

#pragma mark - TFTabbarItemViewDelegate

// Called when the use select a tab
// Our controller is observing the selectedIndex value for changes, which then swaps in our new viewController
- (void)selectedTab:(TFTabbarItemView *)itemView {
	if (_controller.enabled) {
		[self willChangeValueForKey:@"selectionIndexes"];
		_selectionIndexes = [NSIndexSet indexSetWithIndex:itemView.index];
		[self setupTabCells];
		[self setNeedsDisplay:YES];
		[self didChangeValueForKey:@"selectionIndexes"];
	}
}

- (void)removeTab:(TFTabbarItemView *)itemView {
	NSLog(@"Need to request removal of tab");
	[_controller requestRemovalOfTabAtIndex:[_itemViews indexOfObject:itemView]];
}

#pragma mark - NSTabViewDelegate

- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView {
//	[self setupTabCells];
	[self setNeedsDisplay:YES];
}

@end
