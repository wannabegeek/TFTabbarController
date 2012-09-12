//
//  AppDelegate.h
//  TFTabbarDemo
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TFTabbarController/TFTabbarController.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, TFTabbarDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
