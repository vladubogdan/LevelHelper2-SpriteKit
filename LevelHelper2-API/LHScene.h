//
//  LHScene.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"

#import "LHConfig.h"


@class LHScene;
@class LHGameWorldNode;
@class LHUINode;
@class LHBackUINode;
@class LHAnimation;


#if LH_USE_BOX2D
#ifdef __cplusplus
#include "Box2D.h"
#endif
#endif //LH_USE_BOX2D

@protocol LHCollisionHandlingProtocol <NSObject>

@required
#if LH_USE_BOX2D

-(BOOL)shouldDisableContactBetweenNodeA:(SKNode*)a
                               andNodeB:(SKNode*)b;

-(void)didBeginContactBetweenNodeA:(SKNode*)a
                          andNodeB:(SKNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse;

-(void)didEndContactBetweenNodeA:(SKNode*)a
                        andNodeB:(SKNode*)b;

#else //spritekit

- (void)didBeginContact:(SKPhysicsContact *)contact;
- (void)didEndContact:(SKPhysicsContact *)contact;

#endif

@end


@protocol LHAnimationNotificationsProtocol <NSObject>

@required
-(void)didFinishedPlayingAnimation:(LHAnimation*)anim;
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim;

@end



#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif // __has_feature(objc_arc)

/**
 LHScene class is used to load a level file into SpriteKit engine.
 End users will have to subclass this class in order to add the game logic.
 */
@interface LHScene : SKScene <LHNodeProtocol>

#if TARGET_OS_IPHONE
+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile;
#else
+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile size:(CGSize)size;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile size:(CGSize)size;
#endif

/**
 Returns a SKTextureAtlas object that was previously loaded or a new one.
 @param atlasPath The path of the atlas (usually a sprite name)
 @return A texture atlas or nil if not found.
 */
-(SKTextureAtlas*)textureAtlasWithImagePath:(NSString*)atlasPath;

/**
 Returns a SKTexture object that was previously loaded or a new one.
 @param imagePath The path of the image file.
 @return A texture object or nil if image could not be found.
 */
-(SKTexture*)textureWithImagePath:(NSString*)imagePath;


/**
 Returns the game world rectangle or CGRectZero if the game world rectangle is not set in the level file.
 */
-(CGRect)gameWorldRect;


/**
 Returns the game world node. All children of this node will move with the camera. For UI elements use the uiNode.
 */
-(LHGameWorldNode*)gameWorldNode;

/**
 Returns the Front UI node. All children of this node will NOT move with the camera.
 */
-(LHUINode*)uiNode;

/**
 Returns the Back UI node. All children of this node will NOT move with the camera.
 */

-(LHBackUINode*)backUINode;

/**
 Returns the relative plist path that was used to load this scene information.
 */
-(NSString*)relativePath;

#pragma mark- ANIMATION HANDLING

/**
 Set a animation notifications delegate. 
 When subclassing LHScene, if you overwrite the animation notifications methods make sure you call super or this will no longer work.
 If you delete the delegate object make sure you null-ify the animation notifications delegate.
 @param del The object that implements the LHAnimationNotificationsProtocol methods.
 */
-(void)setAnimationNotificationsDelegate:(id<LHAnimationNotificationsProtocol>)del;

-(void)didFinishedPlayingAnimation:(LHAnimation*)anim;
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim;


#pragma mark- COLLISION HANDLING

/**
 Set a collision handling delegate.
 When subclassing LHScene, if you overwrite the collision handling methods make sure you call super or this will no longer work.
 If you delete the delegate object make sure you null-ify the collision handling delegate.
  @param del The object that implements the LHCollisionHandlingProtocol methods.
 */
-(void)setCollisionHandlingDelegate:(id<LHCollisionHandlingProtocol>)del;

#if LH_USE_BOX2D

/**
 Overwrite this methods to receive collision informations when using Box2d.
 This method is called prior the collision happening and lets the user decide whether or not the collision should happen. 
  @param a First node that participates in the collision.
  @param b Second node that participates in the collision.
  @return A boolean value telling whether or not the 2 nodes should collide. Default is YES.
  @discussion Available only when using Box2d.
  @discussion Useful when you have a character that jumps from platform to platform. When the character is under the platform you want to disable collision, but once the character is on top of the platform you want the collision to be triggers in order for the character to stay on top of the platform.
 */
-(BOOL)shouldDisableContactBetweenNodeA:(SKNode*)a
                               andNodeB:(SKNode*)b;

/**
 Overwrite this methods to receive collision informations when using Box2d.
 Called when the collision begins. Called with every new contact point between two nodes. May be called multiple times for same two nodes, because the point at which the nodes are touching has changed.
 @param a First node that participates in the collision.
 @param b Second node that participates in the collision.
 @param scenePt The location where the two nodes collided in scene coordinates.
 @param impulse The impulse of the collision.
 @discussion Available only when using Box2d.
*/
-(void)didBeginContactBetweenNodeA:(SKNode*)a
                          andNodeB:(SKNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse;

/**
 Overwrite this methods to receive collision informations when using Box2d.
 Called when the collision ends. Called when two nodes no longer collide at a specific point. May be called multiple times for same two nodes, because the point at which the nodes are touching has changed.
 @param a First node that participates in the collision.
 @param b Second node that participates in the collision.
 @discussion Available only when using Box2d.
 */
-(void)didEndContactBetweenNodeA:(SKNode*)a
                        andNodeB:(SKNode*)b;

#else //spritekit

/**
 Overwrite this methods to receive collision informations.
 @param contact Object containing the collision information.
 @discussion Available when using SpriteKit own physics engine.
 This methods just forwards the call to SpriteKit API. Consult Sprite Kit documentation for more info.
 */
- (void)didBeginContact:(SKPhysicsContact *)contact;

/**
 Overwrite this methods to receive collision informations.
 @param contact Object containing the collision information.
 @discussion Available when using SpriteKit own physics engine. This methods just forwards the call to SpriteKit API. Consult Sprite Kit documentation for more info.
 */
- (void)didEndContact:(SKPhysicsContact *)contact;
#endif


#pragma mark - Box2d Support

#if LH_USE_BOX2D
#ifdef __cplusplus
/**
 This method Returns the b2World object used for the physics simulation.
 @discussion Available only when using Box2d.
*/
-(b2World*)box2dWorld;

/**
 The point to meter ratio used to convert SpriteKit to Box2d coordinates. Overwrite this method to provide your own.
 @discussion Available only when using Box2d.
 */
-(float)ptm;

/**
 Converts SpriteKit points to Box2d points.
 @param point The point to be converted.
 @discussion Available only when using Box2d.
 */
-(b2Vec2)metersFromPoint:(CGPoint)point;

/**
 Converts Box2d points to SpriteKit points.
 @param vec The Box2d point to be converted.
 @discussion Available only when using Box2d.
 */
-(CGPoint)pointFromMeters:(b2Vec2)vec;

/**
 Converts a SpriteKit value to Box2d meters.
 @param val The value to be converted.
 @discussion Available only when using Box2d.
 */
-(float)metersFromValue:(float)val;

/**
 Converts a Box2d value to a SpriteKit value.
 @param meter The Box2d value to be converted.
 @discussion Available only when using Box2d.
 */
-(float)valueFromMeters:(float)meter;

#endif
#endif //LH_USE_BOX2D


/**
 Get the global gravity force.
 */
-(CGPoint)globalGravity;

/**
 Sets the global gravity force
 @param gravity A point representing the gravity force in x and y direction.
 */
-(void)setGlobalGravity:(CGPoint)gravity;


@end
