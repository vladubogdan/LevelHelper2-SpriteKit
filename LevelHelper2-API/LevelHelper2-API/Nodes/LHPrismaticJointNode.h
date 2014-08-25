//
//  LHPrismaticJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHJointNodeProtocol.h"

/**
 LHPrismaticJointNode class is used to load a LevelHelper prismatic joint.
 The equivalent in SpriteKit is a SKPhysicsJointSliding joint object, which is a wrapper over Box2d b2PrismaticJoint.
 */

@interface LHPrismaticJointNode : SKNode <LHNodeProtocol, LHJointNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

-(instancetype)initWithDictionary:(NSDictionary*)dict
                           parent:(SKNode*)prnt;


/**
 Returns whether or not the limit is enabled on the joint.
 */
-(BOOL)enableLimit;

/**
 Returns whether or not the motor is enabled on the joint.
 */
-(BOOL)enableMotor;

/**
 Returns the lower translation limit.
 */
-(CGFloat)lowerTranslation;

/**
 Returns the upper translation limit.
 */
-(CGFloat)upperTranslation;

/**
 Returns the maximum motor force.
 */
-(CGFloat)maxMotorForce;

/**
 Returns the motor speed in degrees.
 */
-(CGFloat)motorSpeed;

/**
 Returns the axis on which this joint is moving.
 */
-(CGPoint)axis;

/**
 Removes the joint from the world.
 */
-(void)removeFromParent;
@end
