//
//  LHCamera.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
/**
 LHCamera class is used to load a camera object from a level file.
 Users can retrieve camera objects by calling the scene (LHScene) cameraWithName: method.
 */

@class LHScene;
@interface LHCamera : SKNode <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                             scene:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                             scene:(SKNode*)prnt;


/**
 Returns wheter or not this camera is the active camera.
 */
-(BOOL)isActive;

/**
 Sets this camera as the active camera.
 @param value True for active, false for inactive.
 */
-(void)setActive:(BOOL)value;

/**
 Returns the followed node or nil if no node is being fallowed;
 */
-(SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)followedNode;

/**
 Set a node that should be followed by this camera.
 @param node The node that should be followed.
 */
-(void)followNode:(SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)node;

/**
 Returns wheter or not this camera is restricted to the game world rectangle.
 */
-(BOOL)restrictedToGameWorld;

/**
 Set the restricted to game world state of this camera.
 @param value Wheter or not to restrict the camera to the game world area.
 */
-(void)setRestrictedToGameWorld:(BOOL)value;

@end
