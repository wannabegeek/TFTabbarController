//
//  AppDelegate.m
//  TFTabbarDemo
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "AppDelegate.h"
#import "TFTabbarControllerDemoViewController.h"

@interface AppDelegate ()
@property (weak) IBOutlet TFTabbarController *tabbarController;
@end

@implementation AppDelegate

@synthesize tabbarController = _tabbarController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	NSArray *array = [NSArray arrayWithObjects:@"Tab 1", @"Tab 2", @"Tab 3", @"Tab 4", nil];
	[_tabbarController addObjects:array];
}

- (NSString *)tabbarController:(TFTabbarController *)tabbarController identifierForObject:(id)object {
	return @"Demo View";
}

- (NSViewController *)tabbarController:(TFTabbarController *)tabbarController viewControllerForIdentifier:(NSString *)identifier {
	return [[TFTabbarControllerDemoViewController alloc] initWithNibName:@"TFTabbarControllerDemoView" bundle:nil];
}

- (NSString *)tabbarController:(TFTabbarController *)tabbarController titleForObject:(id)object {
	return object;
}


- (void)tabbarController:(TFTabbarController *)tabbarController prepareViewController:(NSViewController *)viewController withObject:(id)object {
	TFTabbarControllerDemoViewController *vc = (TFTabbarControllerDemoViewController *)viewController;
	vc.textField.stringValue = object;
}

- (void)tabbarControllerDidAddNewObject:(TFTabbarController *)tabbarController {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterNoStyle;
	dateFormatter.timeStyle = NSDateFormatterMediumStyle;
	[_tabbarController addObject:[NSString stringWithFormat:@"Another New Tab [%@]", [dateFormatter stringFromDate:[NSDate date]]]];
}

- (void)tabbarController:(TFTabbarController *)tabbarController didRemoveObject:(id)object {
	[_tabbarController removeObjectAtIndex:[tabbarController.objects indexOfObject:object]];
}

@end
