//
//  LHDistanceJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHJointNodeProtocol.h"

/**
 LHDistanceJointNode class is used to load a LevelHelper distance joint.
 The equivalent in SpriteKit is a SKPhysicsJointSpring joint object, which is a wrapper over Box2d b2DistanceJoint.
 */

@interface LHDistanceJointNode : SKNode <LHNodeProtocol, LHJointNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

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
