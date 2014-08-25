//
//  LHBezier.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodePhysicsProtocol.h"

/**
 LHBezier class is used to load and display a bezier from a level file.
 Users can retrieve a bezier objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHBezier : SKShapeNode <LHNodeProtocol, LHNodeAnimationProtocol, LHNodePhysicsProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;


/**
 Returns the points used to draw this bezier node. Array of NSValue with CGPoints;
 */
-(NSMutableArray*)linePoints;

/**
 Returns the size of the bezier node by computing the bounding box of the points.
 */
-(CGSize)size;

@end
