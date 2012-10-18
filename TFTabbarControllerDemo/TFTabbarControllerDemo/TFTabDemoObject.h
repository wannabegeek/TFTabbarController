//
//  TFTabDemoObject.h
//  TFTabbarControllerDemo
//
//  Created by Tom Fewster on 18/10/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFTabDemoObject : NSObject <NSCopying>

@property (strong) NSString *name;

+ (id)tabDemoObjectWithName:(NSString *)name;
- (id)initWithName:(NSString *)name;

@end
