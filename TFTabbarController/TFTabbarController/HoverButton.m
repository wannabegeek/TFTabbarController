//
//  HoverButton.m
//  TFTabbar
//
//  Created by Tom Fewster on 11/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "HoverButton.h"

@interface HoverButton ()
@property (strong) NSTrackingArea *trackingArea;
@end

@implementation HoverButton

@synthesize normalImage = _normalImage;
@synthesize hoverImage = _hoverImage;
@synthesize trackingArea = _trackingArea;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.bordered = NO;
		self.title = nil;

		_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
        [self addTrackingArea:_trackingArea];

		[self.cell setHighlightsBy:NSContentsCellMask];
    }

    return self;
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[self removeTrackingArea:_trackingArea];
	_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

- (void)setNormalImage:(NSImage *)normalImage {
	_normalImage = normalImage;
	self.image = _normalImage;
}


- (void)mouseEntered:(NSEvent *)theEvent {
//	[super mouseEntered:theEvent];
	self.image = _hoverImage;
}

- (void)mouseExited:(NSEvent *)theEvent {
//	[super mouseExited:theEvent];
	self.image = _normalImage;
}

@end
