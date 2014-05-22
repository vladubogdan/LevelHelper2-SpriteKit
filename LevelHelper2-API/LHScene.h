//
//  LHScene.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif // __has_feature(objc_arc)

/**
 LHScene class is used to load a level file into SpriteKit engine.
 End users will have to subclass this class in order to add they're game logic.
 */

@class LHCamera;
@class LHScene;

@interface LHSceneNode : SKNode
+(instancetype)nodeWithScene:(LHScene*)val;
@end


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
 Because of the restrictions impose by SpriteKit all nodes are added to a subnode of the scene.
 This method, returns that subnode.
 */
-(SKNode*)sceneNode;

/**
 Returns the informations that can be used to create an asset dynamically by specifying the file name.
 The asset file must be in the same folder as the scene file.
 If the asset file is not found it will return nil.
 
 @param assetFileName The name of the asset that. Do not provide an extension. E.g If file is named "myAsset.lhasset.plist" then yous should pass @"myAsset.lhasset"
 @return A dictionary containing the asset information or nil.
 */
-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName;



#pragma mark - LHNodeProtocol

/**
 Returns the unique identifier of the node.
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
 Returns the scene to which this node belongs to.
 */
-(LHScene*)scene;

/**
 Returns a node with the specified unique name or nil if that node is not found in the children hierarchy.
 @param name The unique name of the node.
 @return A node or or nil.
 */
-(SKNode <LHNodeProtocol>*)childNodeWithName:(NSString*)name;

/**
 Returns a node with the specified unique identifier or nil if that node is not found in the children hierarchy.
 @param uuid The unique idenfier of the node.
 @return A node or or nil.
 */
-(SKNode <LHNodeProtocol>*)childNodeWithUUID:(NSString*)uuid;

/**
 Returns all children nodes that have the specified tag values.
 @param tagValues An array containing tag names. Array of NSString's.
 @param any Specify if all or just one tag value of the node needs to be in common with the passed ones.
 @return A node or or nil.
 */
-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any;

/**
 Returns all children nodes that are of specified class type.
 @param type A "Class" type.
 @return An array with all the found nodes of the specified class.
 */
-(NSMutableArray*)childrenOfType:(Class)type;


@end
