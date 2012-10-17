//
//  TFTabbar.h
//  TFTabbar
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFTabbarController;

@protocol TFTabbarDelegate <NSObject>
- (NSString *)tabbarController:(TFTabbarController *)tabbarController titleForObject:(id)object;
- (NSString *)tabbarController:(TFTabbarController *)tabbarController identifierForObject:(id)object;
- (NSViewController *)tabbarController:(TFTabbarController *)tabbarController viewControllerForIdentifier:(NSString *)identifier;
- (void)tabbarController:(TFTabbarController *)tabbarController prepareViewController:(NSViewController *)viewController withObject:(id)object;

- (void)tabbarControllerDidAddNewObject:(TFTabbarController *)tabbarController;
- (void)tabbarController:(TFTabbarController *)tabbarController didRemoveObject:(id)object;

@optional
- (void)tabbarController:(TFTabbarController *)tabbarController didTransitionToObject:(id)object;

@end


@interface TFTabbarController : NSObject

@property (nonatomic, weak) IBOutlet NSView *view;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (weak) IBOutlet NSObject<TFTabbarDelegate> *delegate;
@property (nonatomic, strong, readonly) NSArray *objects;
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, assign) BOOL canAdd;
@property (nonatomic, assign) BOOL canRemove;
@property (nonatomic, assign) BOOL enabled;

@property(nonatomic, strong, readonly) NSViewController *selectedViewController;

- (void)updateTabbarTitles;

- (void)addObject:(id)object animated:(BOOL)animated;
- (void)insertObject:(id)object atIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)addObjects:(NSArray *)objects animated:(BOOL)animated;
- (void)removeObjectAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeAllObjectsAnimated:(BOOL)animated;
@end
