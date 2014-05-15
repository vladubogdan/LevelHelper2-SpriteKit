//
//  LHWeldJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
/**
 LHWeldJointNode class is used to load a LevelHelper weld joint. 
 The equivalent in SpriteKit is a SKPhysicsJointFixed joint object, which is a wrapper over Box2d b2WeldJoint.
 */

@interface LHWeldJointNode : SKNode <LHNodeProtocol>

+(instancetype)weldJointNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt;

/**
 Returns the point where the two bodies are connected together. In scene coordinates.
 */
-(CGPoint)anchorA;

/**
 Returns the unique identifier of this joint node.
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

/**
 Returns the actual SpriteKit joint that connects the two bodies together.
 */
-(SKPhysicsJointFixed*)joint;

/**
 Removes the joint from the world.
 */
-(void)removeFromParent;

@end
