//
//  LHSprite.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
#import "LHUserPropertyProtocol.h"
#import "LHNodePhysicsProtocol.h"

/**
 LHSprite class is used to load textured rectangles that are found in a level file.
 Users can retrieve a sprite object by calling the scene (LHScene) childNodeWithName: method.
 */

@interface LHSprite : SKSpriteNode <LHNodeProtocol, LHNodeAnimationProtocol, LHNodePhysicsProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;



/**
 * Creates a sprite with an sprite frame name using a sprite sheet name.
 *
 * @param   spriteFrameName A string which indicates the sprite frame name.
 * @param   imageFile A string which indicates the image file containing the sprite texture. This file will be used to look for the plist file.
 * @param   folder A string which indicates the folder that contains the image & plist file. The folder must be added as reference in Xcode - blue icon.
 * @param   prnt A parent node. Must be in the LHScene hierarchy.
 * @return  An autoreleased sprite object
 
 Eg:
 @code
 PUBLISH_FOLDER/ (added as reference in Xcode - has Blue icon)
 carParts-568.atlasc
 carParts-667.atlasc
 carParts-736.atlasc
 carParts-ipad.atlasc
 carParts.atlasc
 
 LHSprite* sprite = [LHSprite createWithSpriteName:@"carBody" imageFile:@"carParts.atlasc" folder:@"PUBLISH_FOLDER/" parent:[self gameWorldNode]];
 if(sprite){
    [sprite setPosition:location];
 }
 
 @endcode
 */
+ (instancetype)createWithSpriteName:(NSString*)spriteFrameName
                           atlasFile:(NSString*)imageFile
                              folder:(NSString*)folder
                              parent:(SKNode*)prnt;

-(instancetype)initWithSpriteName:(NSString*)spriteFrameName
                        atlasFile:(NSString*)imageFile
                           folder:(NSString*)folder
                           parent:(SKNode*)prnt;


/**
 Change the sprite texture rectangle with the a new texture rectangle defined by the sprite frame with a specific name.
 @param spriteFrame The name of the sprite texture rectangle as defined in the Sprite Packing Editor.
 */
-(void)setSpriteFrameWithName:(NSString*)spriteFrame;

/**
 Returns the sprite image file path.
 */
-(NSString*)imageFilePath;

/**
 Returns the sprite frame name.
 */
-(NSString*)spriteFrameName;

@end
