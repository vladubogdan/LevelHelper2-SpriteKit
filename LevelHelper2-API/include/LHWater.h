//
//  LHWater.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"

/**
 LHWater class is used to load and display a water area from a level file.
 Users can retrieve a water objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHWater : SKShapeNode <LHNodeProtocol>

+ (instancetype)waterNodeWithDictionary:(NSDictionary*)dict
                                 parent:(SKNode*)prnt;


/**
 Returns the unique identifier of this water node.
 */
-(NSString*)uuid;

/**
 Returns all tag values of the node.
 */
-(NSArray*)tags;

/**
 Returns the user property object assigned to this object or nil.
 */
-(id<LHUserPropertyProtocol>)userProperty;

@end
