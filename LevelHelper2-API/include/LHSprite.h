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
/**
 LHSprite class is used to load textured rectangles that are found in a level file.
 Users can retrieve a sprite object by calling the scene (LHScene) childNodeWithName: method.
 */

@interface LHSprite : SKSpriteNode <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)spriteNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt;


/**
 Returns the unique identifier of this sprite node.
 */
-(NSString*)uuid;

/**
 Returns all the tags of the node. (array with NSString's);
 */
-(NSArray*)tags;

/**
Returns the user property object assigned to this object or nil.
 */
-(id<LHUserPropertyProtocol>)userProperty;

-(void)setSpriteFrameWithName:(NSString*)spriteFrame;

@end
