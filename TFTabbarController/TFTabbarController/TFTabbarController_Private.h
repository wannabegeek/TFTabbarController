//
//  TFTabbarController_Private.h
//  TFTabbarController
//
//  Created by Tom Fewster on 12/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <TFTabbarController/TFTabbarController.h>

@interface TFTabbarController ()

- (void)requestNewTabFromDelegate;
- (void)requestRemovalOfTabAtIndex:(NSUInteger)index;
- (NSString *)requestTabTitleFromDelegateForIndex:(NSUInteger)index;

@end
