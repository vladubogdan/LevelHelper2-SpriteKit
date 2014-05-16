//
//  LHRopeJointNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 27/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
/**
 LHRopeJointNode class is used to load a LevelHelper rope joint.
 The equivalent in SpriteKit is a SKPhysicsJointLimit joint object, which is a wrapper over Box2d b2RopeJoint.
 */

@interface LHRopeJointNode : SKNode <LHNodeProtocol>

+(instancetype)ropeJointNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt;

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
 Returns the point where the joint is connected by the first body. In scene coordinates.
 */
-(CGPoint)anchorA;

/**
 Returns the point where the joint is connected by the second body. In scene coordinates.
 */
-(CGPoint)anchorB;

/**
 Returns whether or not this rope joint can be cut.
 */
-(BOOL)canBeCut;

/**
 If the line described by ptA and ptB intersects with the rope joint, the rope will be cut in two. This method ignores "canBeCut".
 */
-(void)cutWithLineFromPointA:(CGPoint)ptA
                    toPointB:(CGPoint)ptB;

@end
