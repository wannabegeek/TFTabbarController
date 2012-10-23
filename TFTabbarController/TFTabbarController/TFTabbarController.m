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

@property (strong, nonatomic) NSIndexSet *selectionIndexes;

@property (strong) NSMutableIndexSet *pendingInsertIndexes;
@property (strong) NSMutableIndexSet *pendingRemoveIndexes;

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

@synthesize selectedViewController = _selectedViewController;

@synthesize delegate = _delegate;

@synthesize arrayController = _arrayController;
@synthesize tabTitleKeyValuePath = _tabTitleKeyValuePath;
@synthesize selectionIndexes = _selectionIndexes;

@synthesize pendingInsertIndexes = _pendingInsertIndexes;
@synthesize pendingRemoveIndexes = _pendingRemoveIndexes;

- (id)init {
	if ((self = [super init])) {
		_viewControllerCache = [NSMutableDictionary dictionary];
		_arrangedObjects = [NSMutableArray array];
		_pendingInsertIndexes = [NSMutableIndexSet indexSet];
		_pendingRemoveIndexes = [NSMutableIndexSet indexSet];
	}
	return self;
}

- (void)awakeFromNib {
	if (_arrayController) {
		[self bind:@"arrangedObjects" toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];

		[self bind:@"selectionIndexes" toObject:_arrayController withKeyPath:NSSelectionIndexesBinding options:nil];
		[_arrayController bind:NSSelectionIndexesBinding toObject:self withKeyPath:@"selectionIndexes" options:nil];

		[self bind:@"canAdd" toObject:_arrayController withKeyPath:@"canAdd" options:nil];
		[self bind:@"canRemove" toObject:_arrayController withKeyPath:@"canRemove" options:nil];
	} else if ([_arrangedObjects count] > 0) {
		self.selectionIndexes = [NSIndexSet indexSetWithIndex:0];
	}

	[self bind:@"selectionIndexes" toObject:_tabBarView withKeyPath:@"selectionIndexes" options:nil];
	[_tabBarView bind:@"selectionIndexes" toObject:self withKeyPath:@"selectionIndexes" options:nil];
}

- (void)setSelectionIndexes:(NSIndexSet *)selectionIndexes {
	[self willChangeValueForKey:@"selectionIndexes"];
	_selectionIndexes = selectionIndexes;
	[self didChangeValueForKey:@"selectionIndexes"];

	NSArray *objects = _arrangedObjects;
	if (_arrayController) {
		objects = _arrayController.arrangedObjects;
	}


	if ([objects count]) {

		id selectedObject = nil;
		if ([_selectionIndexes lastIndex] >= [objects count]) {
			selectedObject = [objects objectAtIndex:[objects count] - 1];
		} else {
			selectedObject = [objects objectAtIndex:[_selectionIndexes lastIndex]];
		}

		NSString *identifier = [_delegate tabbarController:self identifierForObject:selectedObject];
		NSViewController *viewController = [_viewControllerCache objectForKey:identifier];
		if (!viewController) {
			viewController = [_delegate tabbarController:self viewControllerForIdentifier:identifier];
			[_viewControllerCache setObject:viewController forKey:identifier];
		}

		[_delegate tabbarController:self prepareViewController:viewController withObject:selectedObject];
		if (_selectedViewController != viewController) {
			for (NSView *subview in _contentView.subviews) {
				[subview removeFromSuperview];
			}
			viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
			[_contentView addSubview:viewController.view];
			_selectedViewController = viewController;

			NSView *v = viewController.view;
			NSDictionary *views = NSDictionaryOfVariableBindings(v);
			[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:views]];
			[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:views]];
		}

		if ([_delegate respondsToSelector:@selector(tabbarController:didTransitionToObject:)]) {
			[_delegate tabbarController:self didTransitionToObject:selectedObject];
		}
	} else {
		_selectedViewController = nil;
	}
}

- (void)setView:(NSView *)view {
	_view = view;
	if (!_arrayController) {
		_canAdd = YES;
		_canRemove = YES;
	}
	
	_enabled = YES;

	_tabBarView = [[TFTabbarView alloc] initWithFrame:NSZeroRect];
//	_tabBarView.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin;
	_tabBarView.controller = self;
	_tabBarView.translatesAutoresizingMaskIntoConstraints = NO;
	[_view addSubview:_tabBarView];

	_contentView = [[NSView alloc] initWithFrame:NSZeroRect];
//	_contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	_contentView.translatesAutoresizingMaskIntoConstraints = NO;

	[_view addSubview:_contentView];

	NSDictionary *views = NSDictionaryOfVariableBindings(_tabBarView, _contentView);
	[_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tabBarView]|" options:0 metrics:nil views:views]];
	[_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics:nil views:views]];
	[_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tabBarView(==22)][_contentView]|" options:0 metrics:nil views:views]];

	_tabBarView.contentView = _contentView;
}

- (void)addObject:(id)object animated:(BOOL)animated {
	[self insertObject:object atIndex:[_arrangedObjects count] animated:animated];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index animated:(BOOL)animated {
	NSAssert(_arrayController == nil, @"You can't use this method is you are using an NSArrayController for content");
	[_arrangedObjects insertObject:object atIndex:index];
	[_tabBarView createNewTabAtIndex:index animated:animated];

	if ([_selectionIndexes count] == 0) {
		self.selectionIndexes = [NSIndexSet indexSetWithIndex:0];
	}

//	if ([_arrangedObjects count] == 1) {
//		_tabBarView.selectedIndex = 0;
//	} else if (index < _tabBarView.selectedIndex) {
//		_tabBarView.selectedIndex = _tabBarView.selectedIndex++;
//	}
}

- (void)addObjects:(NSArray *)objects animated:(BOOL)animated {
	for (id object in objects) {
		[self addObject:object animated:animated];
	}
}

- (void)removeObjectAtIndex:(NSUInteger)index animated:(BOOL)animated {
	NSAssert(_arrayController == nil, @"You can't use this method is you are using an NSArrayController for content");
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:_tabTitleKeyValuePath]) {
		[_tabBarView refreshTitles];
	}
}

- (void)setArrangedObjects:(NSMutableArray *)arrangedObjects {

	NSArray *originalObjects = [_arrangedObjects copy];
	_arrangedObjects = [arrangedObjects mutableCopy];

	if (_tabTitleKeyValuePath) {
		for (id obj in originalObjects) {
			[obj removeObserver:self forKeyPath:_tabTitleKeyValuePath];
		}
		for (id obj in _arrangedObjects) {
			[obj addObserver:self forKeyPath:_tabTitleKeyValuePath options:0 context:nil];
		}
	}

	NSInteger diff = [originalObjects count] - [_arrangedObjects count];

	if (diff > 0) {
		__block NSInteger count = diff;
		[_pendingRemoveIndexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop) {
			[_tabBarView removeTabAtIndex:idx animated:YES];
			count--;
		}];
		while (count > 0) {
			[_tabBarView removeTabAtIndex:0 animated:NO];
			count--;
		}
	} else if (diff < 0) {
		__block NSInteger count = diff;
		[_pendingInsertIndexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop) {
			[_tabBarView createNewTabAtIndex:idx animated:YES];
			count++;
		}];
		while (count < 0) {
			[_tabBarView createNewTabAtIndex:[originalObjects count] + (count - diff) animated:NO];
			count++;
		}
	}

	[_pendingInsertIndexes removeAllIndexes];
	[_pendingRemoveIndexes removeAllIndexes];
	[self updateTabbarTitles];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	[self willChangeValueForKey:@"selectedIndex"];
	_selectedIndex = selectedIndex;
//	_tabBarView.selectedIndex = _selectedIndex;
	[self didChangeValueForKey:@"selectedIndex"];
}

- (void)updateTabbarTitles {
	[_tabBarView refreshTitles];
	[_tabBarView setNeedsDisplay:YES];
}

- (void)requestNewTabFromDelegate {
	if (_arrayController) {
		id object = [_arrayController newObject];
		[_arrayController addObject:object];
		[_pendingInsertIndexes addIndex:[_arrayController.arrangedObjects count]];
	} else {
		if (_delegate && [_delegate respondsToSelector:@selector(tabbarControllerDidAddNewObject:)]) {
			[_delegate tabbarControllerDidAddNewObject:self];
		}
	}
}

- (NSString *)requestTabTitleFromDelegateForIndex:(NSUInteger)index {
	if (_arrayController && _tabTitleKeyValuePath) {
		NSArray *objects = _arrayController.arrangedObjects;
		if (index >= [objects count]) {
			return nil;
		} else {
			return [[_arrayController.arrangedObjects objectAtIndex:index] valueForKeyPath:_tabTitleKeyValuePath];
		}
	} else {
		if (_delegate && [_delegate respondsToSelector:@selector(tabbarController:titleForObject:)]) {
			return [_delegate tabbarController:self titleForObject:[_arrangedObjects objectAtIndex:index]];
		}
	}
	return nil;
}

- (void)requestRemovalOfTabAtIndex:(NSUInteger)index {
	if (_arrayController) {
		id object = [_arrayController.arrangedObjects objectAtIndex:index];
		[_pendingRemoveIndexes addIndexes:[_arrayController.arrangedObjects indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			return [object isEqual:obj];
		}]];
		[_arrayController removeObject:object];
	} else {
		id object = [_arrangedObjects objectAtIndex:index];
		if (_delegate && [_delegate respondsToSelector:@selector(tabbarController:didRemoveObject:)]) {
			[_delegate tabbarController:self didRemoveObject:object];
		}
	}
}

@end
