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

#if LH_USE_BOX2D
#ifdef __cplusplus
#include "Box2D.h"
#endif
#endif //LH_USE_BOX2D


#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif // __has_feature(objc_arc)

/**
 LHScene class is used to load a level file into SpriteKit engine.
 End users will have to subclass this class in order to add they're game logic.
 */

@class LHScene;
@class LHGameWorldNode;
@class LHUINode;


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
 Returns the UI node. All children of this node will NOT move with the camera.
 */
-(LHUINode*)uiNode;


/**
 Returns the informations that can be used to create an asset dynamically by specifying the file name.
 The asset file must be in the same folder as the scene file.
 If the asset file is not found it will return nil.
 
 @param assetFileName The name of the asset that. Do not provide an extension. E.g If file is named "myAsset.lhasset.plist" then yous should pass @"myAsset.lhasset"
 @return A dictionary containing the asset information or nil.
 */
-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName;


#pragma mark - Box2d Support

#if LH_USE_BOX2D
#ifdef __cplusplus
-(b2World*)box2dWorld;

-(float)ptm;

-(b2Vec2)metersFromPoint:(CGPoint)point;
-(CGPoint)pointFromMeters:(b2Vec2)vec;

-(float)metersFromValue:(float)val;
-(float)valueFromMeters:(float)meter;

#endif
#endif //LH_USE_BOX2D


/*Get the global gravity force.
 */
-(CGPoint)globalGravity;
/*Sets the global gravity force
 @param gravity A point representing the gravity force in x and y direction.
 */
-(void)setGlobalGravity:(CGPoint)gravity;


@end
