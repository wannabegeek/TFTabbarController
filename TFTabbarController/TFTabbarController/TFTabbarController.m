//
//  TFTabbar.m
//  TFTabbar
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "TFTabbarController.h"
#import "TFTabbarView.h"

@interface TFTabbarController ()
@property (strong) TFTabbarView *tabBarView;
@property (strong) NSView *contentView;
@property (strong) NSMutableDictionary *viewControllerCache;
@property (nonatomic, strong) NSMutableArray *arrangedObjects;

@end

@implementation TFTabbarController

@synthesize view = _view;
@synthesize tabBarView = _tabBarView;
@synthesize contentView = _contentView;

@synthesize arrangedObjects = _arrangedObjects;
@synthesize selectedIndex = _selectedIndex;
@synthesize viewControllerCache = _viewControllerCache;
@synthesize canAdd = _canAdd;
@synthesize canRemove = _canRemove;
@synthesize enabled = _enabled;

@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		_viewControllerCache = [NSMutableDictionary dictionary];
		_arrangedObjects = [NSMutableArray array];
	}
	return self;
}

- (void)setView:(NSView *)view {
	_view = view;

	_canAdd = YES;
	_canRemove = YES;
	_enabled = YES;

	NSRect frame = _view.bounds;
	frame.origin.y = frame.size.height - 22.0f;
	frame.size.height = 22.0f;
	_tabBarView = [[TFTabbarView alloc] initWithFrame:frame];
	_tabBarView.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin;
	_tabBarView.controller = self;
	[_view addSubview:_tabBarView];
	[_tabBarView addObserver:self forKeyPath:@"selectedIndex" options:0 context:nil];

	frame = _view.bounds;
	frame.size.height -= 22.0f;
	_contentView = [[NSView alloc] initWithFrame:frame];
	_contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

	[_view addSubview:_contentView];

	_tabBarView.contentView = _contentView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == _tabBarView && [keyPath isEqualToString:@"selectedIndex"]) {
		[self willChangeValueForKey:@"selectedIndex"];
		_selectedIndex = _tabBarView.selectedIndex;
		[self didChangeValueForKey:@"selectedIndex"];
		if ([_arrangedObjects count]) {
			id object = [_arrangedObjects objectAtIndex:_selectedIndex];
			NSString *identifier = [_delegate tabbarController:self identifierForObject:object];
			NSViewController *viewController = [_viewControllerCache objectForKey:identifier];
			if (!viewController) {
				viewController = [_delegate tabbarController:self viewControllerForIdentifier:identifier];
				[_viewControllerCache setObject:viewController forKey:identifier];
			}

			[_delegate tabbarController:self prepareViewController:viewController withObject:object];
			for (NSView *subview in _contentView.subviews) {
				[subview removeFromSuperview];
			}
			[viewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
			[_contentView addSubview:viewController.view];

			NSView *v = viewController.view;
			NSDictionary *views = NSDictionaryOfVariableBindings(v);
			[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:views]];
			[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:views]];
		}
	}
}

//- (void)setArrangedObjects:(NSArray *)arrangedObjects {
//	NSArray *originalObjects = [_arrangedObjects copy];
//	_arrangedObjects = arrangedObjects;
//
//	// work out which tabs to remove first...
//	for (NSInteger index = [originalObjects count]-1; index >= 0; index--) {
//		id originalObject = [originalObjects objectAtIndex:index];
//		NSUInteger newIndex = [_arrangedObjects indexOfObject:originalObject];
//		if (newIndex == NSNotFound) {
//			// Our object has been removed
//			NSLog(@"'%@' has been removed [%ld]", originalObject, index);
//			[_tabBarView removeTabAtIndex:index];
//		}
//	}
//
//	// work out which tabs to add...
//	for (NSUInteger index = 0; index < [_arrangedObjects count]; index++) {
//		id newObject = [_arrangedObjects objectAtIndex:index];
//		NSUInteger originalIndex = [originalObjects indexOfObject:newObject];
//		if (originalIndex == NSNotFound) {
//			// Our object has been removed
//			NSLog(@"'%@' has been added [%lu]", newObject, index);
//			[_tabBarView createNewTabAtIndex:index];
//		}
//	}
//}

- (void)addObject:(id)object animated:(BOOL)animated {
	[self insertObject:object atIndex:[_arrangedObjects count] animated:animated];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index animated:(BOOL)animated {
	[_arrangedObjects insertObject:object atIndex:index];
	[_tabBarView createNewTabAtIndex:index animated:animated];
	if ([_arrangedObjects count] == 1) {
		_tabBarView.selectedIndex = 0;
	} else if (index < _tabBarView.selectedIndex) {
		_tabBarView.selectedIndex = _tabBarView.selectedIndex++;
	}
}

- (void)addObjects:(NSArray *)objects animated:(BOOL)animated {
	for (id object in objects) {
		[self addObject:object animated:animated];
	}
}

- (void)removeObjectAtIndex:(NSUInteger)index animated:(BOOL)animated {
	[_arrangedObjects removeObjectAtIndex:index];
	[_tabBarView removeTabAtIndex:index animated:animated];
}

- (void)removeAllObjectsAnimated:(BOOL)animated {
	for (NSInteger i = [_arrangedObjects count] - 1; i >= 0 ; i--) {
		[self removeObjectAtIndex:i animated:animated];
	}
}

- (NSUInteger)count {
	return [_arrangedObjects count];
}

- (NSArray *)objects {
	return [_arrangedObjects copy];
}

- (void)setCanAdd:(BOOL)canAdd {
	_canAdd = canAdd;
	[_tabBarView updateProperties];
}

- (void)setCanRemove:(BOOL)canRemove {
	_canRemove = canRemove;
	[_tabBarView updateProperties];
}

- (void)enabled:(BOOL)enabled {
	_enabled = enabled;
	[_tabBarView updateProperties];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	[self willChangeValueForKey:@"selectedIndex"];
	_selectedIndex = selectedIndex;
	_tabBarView.selectedIndex = _selectedIndex;
	[self didChangeValueForKey:@"selectedIndex"];
}

- (void)updateTabbarTitles {
	[_tabBarView refreshTitles];
	[_tabBarView setNeedsDisplay:YES];
}

- (void)requestNewTabFromDelegate {
	if (_delegate && [_delegate respondsToSelector:@selector(tabbarControllerDidAddNewObject:)]) {
		[_delegate tabbarControllerDidAddNewObject:self];
	}
}

- (NSString *)requestTabTitleFromDelegateForIndex:(NSUInteger)index {
	if (_delegate && [_delegate respondsToSelector:@selector(tabbarController:titleForObject:)]) {
		return [_delegate tabbarController:self titleForObject:[_arrangedObjects objectAtIndex:index]];
	}
	return nil;
}

- (void)requestRemovalOfTabAtIndex:(NSUInteger)index {
//	NSMutableArray *temp = [_arrangedObjects mutableCopy];
	id object = [_arrangedObjects objectAtIndex:index];
//	[temp removeObjectAtIndex:index];
//	_arrangedObjects = temp;
	if (_delegate && [_delegate respondsToSelector:@selector(tabbarController:didRemoveObject:)]) {
		[_delegate tabbarController:self didRemoveObject:object];
	}
}

@end
