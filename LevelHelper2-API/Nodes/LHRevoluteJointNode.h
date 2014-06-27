//
//  LHRevoluteJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHJointNodeProtocol.h"

/**
 LHRevoluteJointNode class is used to load a LevelHelper revolute joint.
 The equivalent in SpriteKit is a SKPhysicsJointPin joint object, which is a wrapper over Box2d b2RevoluteJoint.
 */

@interface LHRevoluteJointNode : SKNode <LHNodeProtocol, LHJointNodeProtocol>

+(instancetype)revoluteJointNodeWithDictionary:(NSDictionary*)dict
                                        parent:(SKNode*)prnt;

/**
 Returns whether or not this joint has a rotation limit.
 */
-(BOOL)hasLimit;

/**
 Returns the smallest angle allowed for the joint to rotate. In degrees.
 */
-(float)lowerAngleLimit;

/**
 Returns the largest angle allowed for the joint to rotate. In degrees.
 */
-(float)upperAngleLimit;

/**
 Removes the joint from the world.
 */
-(void)removeFromParent;

@end
