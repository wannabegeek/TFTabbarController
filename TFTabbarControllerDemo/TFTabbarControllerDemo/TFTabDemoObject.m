//
//  TFTabDemoObject.m
//  TFTabbarControllerDemo
//
//  Created by Tom Fewster on 18/10/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "TFTabDemoObject.h"

@implementation TFTabDemoObject

@synthesize name = _name;

-(id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithName:self.name];
}

+ (id)tabDemoObjectWithName:(NSString *)name {
	return [[TFTabDemoObject alloc] initWithName:name];
}

- (id)initWithName:(NSString *)name {
	if ((self = [super init])) {
		_name = name;
	}

	return self;
}

@end
