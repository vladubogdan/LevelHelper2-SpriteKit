//
//  LHRevoluteJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
/**
 LHRevoluteJointNode class is used to load a LevelHelper revolute joint.
 The equivalent in SpriteKit is a SKPhysicsJointPin joint object, which is a wrapper over Box2d b2RevoluteJoint.
 */

@interface LHRevoluteJointNode : SKNode <LHNodeProtocol>

+(instancetype)revoluteJointNodeWithDictionary:(NSDictionary*)dict
                                        parent:(SKNode*)prnt;

/**
 Returns the point where the two bodies are connected together. In scene coordinates.
 */
-(CGPoint)anchorA;

/**
 Returns the actual SpriteKit joint that connects the two bodies together.
 */
-(SKPhysicsJointPin*)joint;

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
