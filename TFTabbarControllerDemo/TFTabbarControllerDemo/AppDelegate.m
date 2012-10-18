//
//  AppDelegate.m
//  TFTabbarDemo
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "AppDelegate.h"
#import "TFTabbarControllerDemoViewController.h"
#import "TFTabDemoObject.h"

@interface AppDelegate ()
@property (weak) IBOutlet TFTabbarController *tabbarControllerWithBindings;
@property (weak) IBOutlet TFTabbarController *tabbarControllerWithoutBindings;
@property (strong) IBOutlet TFTabbarControllerDemoViewController *viewController;
@end

//#define USE_BINDINGS 1

@implementation AppDelegate

@synthesize tabbarControllerWithBindings = _tabbarControllerWithBindings;
@synthesize tabbarControllerWithoutBindings = _tabbarControllerWithoutBindings;
@synthesize content = _content;
@synthesize viewController = _viewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	self.content = [NSArray arrayWithObjects:[TFTabDemoObject tabDemoObjectWithName:@"Tab 1"], [TFTabDemoObject tabDemoObjectWithName:@"Tab 2"], [TFTabDemoObject tabDemoObjectWithName:@"Tab 3"], nil];
	[_tabbarControllerWithoutBindings addObjects:self.content animated:NO];
}

- (NSString *)tabbarController:(TFTabbarController *)tabbarController identifierForObject:(id)object {
	return @"Demo View";
}

- (NSViewController *)tabbarController:(TFTabbarController *)tabbarController viewControllerForIdentifier:(NSString *)identifier {
	if (tabbarController == _tabbarControllerWithoutBindings) {
		return [[TFTabbarControllerDemoViewController alloc] initWithNibName:@"TFTabbarControllerDemoView" bundle:nil];
	} else {
		return self.viewController;
	}
}

- (NSString *)tabbarController:(TFTabbarController *)tabbarController titleForObject:(id)object {
	return [object valueForKeyPath:@"name"];
}

- (void)tabbarController:(TFTabbarController *)tabbarController prepareViewController:(NSViewController *)viewController withObject:(id)object {
}

- (void)tabbarController:(TFTabbarController *)tabbarController didTransitionToObject:(id)object {
	if (tabbarController == _tabbarControllerWithoutBindings) {
		TFTabbarControllerDemoViewController *vc = (TFTabbarControllerDemoViewController *)tabbarController.selectedViewController;
		vc.textField.stringValue = [object valueForKeyPath:@"name"];
	}
}

- (void)tabbarControllerDidAddNewObject:(TFTabbarController *)tabbarController {
	if (tabbarController == _tabbarControllerWithoutBindings) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = NSDateFormatterNoStyle;
		dateFormatter.timeStyle = NSDateFormatterMediumStyle;

		[_tabbarControllerWithoutBindings addObject:[TFTabDemoObject tabDemoObjectWithName:[NSString stringWithFormat:@"Another New Tab [%@]", [dateFormatter stringFromDate:[NSDate date]]]] animated:YES];
		_tabbarControllerWithoutBindings.canRemove = ([_tabbarControllerWithoutBindings.objects count] > 1);
		_tabbarControllerWithoutBindings.canAdd = ([_tabbarControllerWithoutBindings.objects count] < 7);
	}
}

- (void)tabbarController:(TFTabbarController *)tabbarController didRemoveObject:(id)object {
	if (tabbarController == _tabbarControllerWithoutBindings) {
		[_tabbarControllerWithoutBindings removeObjectAtIndex:[tabbarController.objects indexOfObject:object] animated:YES];
		_tabbarControllerWithoutBindings.canRemove = ([_tabbarControllerWithoutBindings.objects count] > 1);
		_tabbarControllerWithoutBindings.canAdd = ([_tabbarControllerWithoutBindings.objects count] < 7);
	}
}

@end
