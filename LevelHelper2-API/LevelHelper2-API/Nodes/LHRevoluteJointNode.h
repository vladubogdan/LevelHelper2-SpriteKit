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

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
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
 Returns the lower angle limit
 */
-(CGFloat)lowerAngle;

/**
 Returns the upper angle limit
 */
-(CGFloat)upperAngle;


/**
 Returns the maximum motor torque
 */
-(CGFloat)maxMotorTorque;

/**
 Returns the motor speed.
 */
-(CGFloat)motorSpeed;

@end
