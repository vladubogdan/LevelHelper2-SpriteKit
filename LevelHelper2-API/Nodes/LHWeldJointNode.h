//
//  LHWeldJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHJointNodeProtocol.h"

/**
 LHWeldJointNode class is used to load a LevelHelper weld joint. 
 The equivalent in SpriteKit is a SKPhysicsJointFixed joint object, which is a wrapper over Box2d b2WeldJoint.
 */

@interface LHWeldJointNode : SKNode <LHNodeProtocol, LHJointNodeProtocol>

+(instancetype)weldJointNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt;



/**
 Removes the joint from the world.
 */
-(void)removeFromParent;

@end
