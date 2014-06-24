//
//  LHDistanceJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
/**
 LHDistanceJointNode class is used to load a LevelHelper distance joint.
 The equivalent in SpriteKit is a SKPhysicsJointSpring joint object, which is a wrapper over Box2d b2DistanceJoint.
 */

@interface LHDistanceJointNode : SKNode <LHNodeProtocol>

+(instancetype)distanceJointNodeWithDictionary:(NSDictionary*)dict
                                        parent:(SKNode*)prnt;

/**
 Returns the point where the joint is connected with the first body. In scene coordinates.
 */
-(CGPoint)anchorA;

/**
 Returns the point where the joint is connected with the second body. In scene coordinates.
 */
-(CGPoint)anchorB;

/**
 Returns the actual SpriteKit joint that connects the two bodies together.
 */
-(SKPhysicsJointSpring*)joint;

/**
 Returns the damping ratio of the SpriteKit joint.
 */
-(CGFloat)damping;

/**
 Returns the frequency of the SpriteKit joint.
 */
-(CGFloat)frequency;

/**
 Removes the joint from the world.
 */
-(void)removeFromParent;
@end
