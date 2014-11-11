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


/**
 Set the camera position. The center of the view if the camera is active.
 @param position The new camera position.
 */
-(void)setPosition:(CGPoint)position;


/**
 Set the camera view offset unit. This value is added to the camera position as an offset.
 @param unit The new camera offset unit. This value is multipled with the screen dimensions and added to the camera position.
 */
-(void)setOffsetUnit:(CGPoint)unit;

/**
 Returns the camera unit offset.
 */
-(CGPoint)offsetUnit;

/**
 Set the important camera view unit. This value is multipled with the screen dimensions. The area is based on the center.
 Based on this area the camera position will be calculated based on the following node movement.
 This value is ignored when camera is not following a node.
 @param unit The new camera important area unit. This value is multipled with the screen dimensions.
 */
-(void)setImportantAreaUnit:(CGSize)unit;

/**
 Returns the camera important area unit.
 */
-(CGSize)importantAreaUnit;

/**
 Set whether or not the camera should move on x axis.
 This value is ignored when camera is not following a node.
 @param val A boolean value specifying if camera should move on x axis.
 */
-(void)setLockX:(BOOL)val;

/**
 Returns the camera x axis movement locking state.
 */
-(BOOL)lockX;

/**
 Set whether or not the camera should move on y axis.
 This value is ignored when camera is not following a node.
 @param val A boolean value specifying if camera should move on y axis.
 */
-(void)setLockY:(BOOL)val;

/**
 Returns the camera y axis movement locking state.
 */
-(BOOL)lockY;

/**
 When an important area is set, and the following node has exist it or has changed direction,
 smooth movement will make the camera reach its new position in a non-snapping mode.
 This value is ignored when camera is not following a node.
 @param val A boolean value specifying if camera should reach its important area smoothly.
 */
-(void)setSmoothMovement:(BOOL)val;

/**
 Returns if the camera is trying to reach the important area smoothly.
 */
-(BOOL)smoothMovement;


#pragma mark - ZOOMING

/**
 Set the camera zoom level by adding the value to the current zoom level.
 Only works if the camera is active.
 @param value Set zoom value that will be added/substracted from the currect camera zoom level.
 @param seconds The time needed for the camera to reach the zoom value specified.
 */
-(void)zoomByValue:(float)value inSeconds:(float)seconds;

/**
 Set the camera zoom level.
 Only works if the camera is active.
 @param value Set new zoom value of the camera.
 @param seconds The time needed for the camera to reach the zoom value specified.
 */
-(void)zoomToValue:(float)value inSeconds:(float)seconds;

/**
 Get the current camera zoom value.
 */
-(float)zoomValue;

/**
 Set the camera zoom value without any delay.
 */
-(void)setZoomValue:(float)val;

#pragma mark - LOOK AT

/**
 Makes the camera to look at a specific position by moving from the current or followed object position to this new position in a period of time.
 You should not use this method to move the camera manually. Use setPosition: instead.
 This method should be used only when you want to make the player aware of something in the game world, like a checkpoint it needs to reach.
 @param gwPosition The position the camera will look at. A point value in Game World Node coordinate.
 @param seconds The time needed for the camera to reach the position value specified.
 */
-(void)lookAtPosition:(CGPoint)gwPosition inSeconds:(float)seconds;

/**
 Makes the camera to look at a specific node by moving from the current or followed object position to the position of the node in a period of time.
 You should not use this method to move the camera manually. Use setPosition: instead.
 This method should be used only when you want to make the player aware of something in the game world, like a checkpoint it needs to reach.
 @param node The node the camera will look at. A CCNode* derived object (e.g LHSprite, LHNode, ...).
 @param seconds The time needed for the camera to reach the position of the node specified.
 */
-(void)lookAtNode:(SKNode*)node inSeconds:(float)seconds;

/**
 Resets the lookAt position by moving the camera back to its original position before the camera was made to lookAt or to the followed object position.
 The reset is instant.
 */
-(void)resetLookAt;

/**
 Resets the lookAt position by moving the camera back to its original position before the camera was made to lookAt or to the followed object position in a period of time.
 @param seconds The time needed for the camera to move back from the lookAt position to its original or followed node position.
 */
-(void)resetLookAtInSeconds:(float)seconds;

/**
 Returns whether or not this camera is currently looking at something. A boolean value.;
 */
-(BOOL)isLookingAt;

#pragma mark - PINCH ZOOM
/**
 Sets the camera to zoom on pinch gesture on iOS or scroll wheel on Mac OS when active.
 The zoom will be centered on the followed node or on the center of the pinch.
 */
-(void)setUsePinchOrScrollWheelToZoom:(BOOL)value;

/**
 Returns whether or not this camera is zooming on pinch gesture on iOS or on scroll wheel on Mac OS.
 */
-(BOOL)usePinchOrScrollWheelToZoom;

@end
