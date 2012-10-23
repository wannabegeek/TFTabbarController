//
//  TFTabbarItemCell.m
//  TFTabbar
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "TFTabbarItemView.h"
#import "HoverButton.h"

#define CORNER_RADIUS 5.0f

const CGFloat tabCornerRadius = CORNER_RADIUS;

@interface TFTabbarItemView ()
@property (strong) HoverButton *closeButton;
@property (strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL canClose;
@end

@implementation TFTabbarItemView

@synthesize index = _index;
@synthesize location = _location;
@synthesize title = _title;
@synthesize trackingArea = _trackingArea;
@synthesize delegate = _delegate;
@synthesize canClose = _canClose;

- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect])) {
		_canClose = YES;
		_closeButton = [[HoverButton alloc] initWithFrame:NSZeroRect];
		_closeButton.translatesAutoresizingMaskIntoConstraints = NO;
		NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.wannabegeek.TFTabbarController"];
		_closeButton.normalImage = [frameworkBundle imageForResource:@"TabClose"];
		_closeButton.hoverImage = [frameworkBundle imageForResource:@"TabClosePressed"];
		_closeButton.target = self;
		_closeButton.action = @selector(removeTab:);
		[self addSubview:_closeButton];

		NSDictionary *views = NSDictionaryOfVariableBindings(_closeButton);
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15.0-[_closeButton(==12)]" options:0 metrics:nil views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_closeButton(==12)]" options:0 metrics:nil views:views]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_closeButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];


		_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
        [self addTrackingArea:_trackingArea];
		[_closeButton setHidden:YES];
	}

	return self;
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[self removeTrackingArea:_trackingArea];
	if (_canClose) {
		_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
		[self addTrackingArea:_trackingArea];
	}
}

- (void)drawRect:(NSRect)dirtyRect {

	NSRect tabBounds = NSInsetRect(self.bounds, CORNER_RADIUS, 0.0f);

	NSBezierPath *path = [NSBezierPath bezierPath];
	NSPoint topMid = NSMakePoint(NSMidX(tabBounds), NSMaxY(tabBounds));
	NSPoint topLeft = NSMakePoint(NSMinX(tabBounds) + CORNER_RADIUS, NSMaxY(tabBounds));
//	NSPoint topLeftInner = NSMakePoint(NSMinX(tabBounds) + CORNER_RADIUS, NSMaxY(tabBounds));
	NSPoint topRight = NSMakePoint(NSMaxX(tabBounds) - CORNER_RADIUS, NSMaxY(tabBounds));
	NSPoint bottomRight = NSMakePoint(NSMaxX(tabBounds) - CORNER_RADIUS, NSMinY(tabBounds));
	NSPoint bottomRightOuter = NSMakePoint(NSMaxX(tabBounds), NSMinY(tabBounds));
	NSPoint bottomRightInner = NSMakePoint(NSMaxX(tabBounds) - CORNER_RADIUS, NSMinY(tabBounds) + CORNER_RADIUS);

	NSPoint bottomLeft = NSMakePoint(NSMinX(tabBounds) + CORNER_RADIUS, NSMinY(tabBounds));
	NSPoint bottomLeftOuter = NSMakePoint(NSMinX(tabBounds), NSMinY(tabBounds));
	NSPoint bottomLeftInner = NSMakePoint(NSMinX(tabBounds) + CORNER_RADIUS, NSMinY(tabBounds) + CORNER_RADIUS);

//	NSPoint leftMid = NSMakePoint(NSMinX(tabBounds) + CORNER_RADIUS, NSMaxY(tabBounds));
//	NSPoint rightMid = NSMakePoint(NSMaxX(tabBounds) - CORNER_RADIUS, NSMaxY(tabBounds));

	[path moveToPoint: bottomLeftOuter];
	[path appendBezierPathWithArcFromPoint:bottomLeft toPoint:bottomLeftInner radius:CORNER_RADIUS];
	[path appendBezierPathWithArcFromPoint:topLeft toPoint:topMid radius:CORNER_RADIUS];
	[path appendBezierPathWithArcFromPoint:topRight toPoint:bottomRightInner radius:CORNER_RADIUS];
	[path appendBezierPathWithArcFromPoint:bottomRight toPoint:bottomRightOuter radius:CORNER_RADIUS];
	[path closePath];


//	if (_location == TFTabbarItemIsSelected) {
//	} else if (_location == TFTabbarItemBeforeSelection) {
//		[path moveToPoint: bottomLeftOuter];
//		[path appendBezierPathWithArcFromPoint:bottomLeft toPoint:bottomLeftInner radius:CORNER_RADIUS];
//		[path appendBezierPathWithArcFromPoint:topLeft toPoint:topMid radius:CORNER_RADIUS];
//	} else {
//		[path moveToPoint:topMid];
//		[path appendBezierPathWithArcFromPoint:topRight toPoint:bottomRightInner radius:CORNER_RADIUS];
//		[path appendBezierPathWithArcFromPoint:bottomRight toPoint:bottomRightOuter radius:CORNER_RADIUS];
//	}


	if (_location == TFTabbarItemIsSelected) {
		[[NSGraphicsContext currentContext] saveGraphicsState];

		NSShadow *shadow = [[NSShadow alloc] init];
		shadow.shadowBlurRadius = 5.0f;
		shadow.shadowColor = [NSColor blackColor];
		//	shadow.shadowOffset = NSMakeSize(0.0f, 1.0f);
		[shadow set];

		[[NSColor windowBackgroundColor] set];
		[path fill];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
	} else if (_index != 0) {
		[[NSGraphicsContext currentContext] saveGraphicsState];

		NSShadow *shadow = [[NSShadow alloc] init];
		shadow.shadowBlurRadius = 5.0f;
		shadow.shadowColor = [NSColor blackColor];
		//	shadow.shadowOffset = NSMakeSize(0.0f, 1.0f);
		[shadow set];

		[[NSColor colorWithCalibratedRed:0.733 green:0.733 blue:0.733 alpha:1] set];
		[path fill];

		[[NSGraphicsContext currentContext] restoreGraphicsState];
		[[NSColor grayColor] set];
		[path stroke];
	}

	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowBlurRadius = 1.0f;
	shadow.shadowColor = [NSColor whiteColor];
	shadow.shadowOffset = NSMakeSize(0.0f, -1.0f);
	[shadow set];

	NSColor *fontColor = [[self window] isKeyWindow]?[NSColor colorWithCalibratedRed:0.220 green:0.220 blue:0.220 alpha:1]:[NSColor colorWithCalibratedRed:0.486 green:0.486 blue:0.486 alpha:1];
	NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Bold" size:12.0f], NSFontAttributeName, fontColor, NSForegroundColorAttributeName, nil];
	NSSize titleSize = [_title sizeWithAttributes:titleAttributes];
	NSRect titleRect = NSInsetRect(self.bounds, 20.0f, 5.0f);
	NSPoint titleLocation = NSMakePoint(NSMidX(titleRect) - titleSize.width / 2.0f, titleRect.origin.y);

	[_title drawAtPoint:titleLocation withAttributes:titleAttributes];

}

- (void)mouseDown:(NSEvent *)theEvent {
	if (_delegate && [_delegate respondsToSelector:@selector(selectedTab:)]) {
		[_delegate selectedTab:self];
	}
}

- (void)mouseEntered:(NSEvent *)theEvent {
	[super mouseEntered:theEvent];
	[_closeButton setHidden:NO];
}

- (void)mouseExited:(NSEvent *)theEvent {
	[super mouseExited:theEvent];
	[_closeButton setHidden:YES];
}

- (void)removeTab:(id)sender {
	if (_delegate && [_delegate respondsToSelector:@selector(removeTab:)]) {
		[_delegate removeTab:self];
	}
}

- (void)setCanClose:(BOOL)value {
	if (_canClose != value) {
		_canClose = value;
		if (_canClose) {
			_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
			[self addTrackingArea:_trackingArea];
		} else {
			[self removeTrackingArea:_trackingArea];
			[_closeButton setHidden:YES];
		}
	}
}


@end
