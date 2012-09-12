//
//  HoverButton.h
//  TFTabbar
//
//  Created by Tom Fewster on 11/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HoverButton : NSButton
@property (nonatomic, strong) NSImage *normalImage;
@property (nonatomic, strong) NSImage *hoverImage;
@end
