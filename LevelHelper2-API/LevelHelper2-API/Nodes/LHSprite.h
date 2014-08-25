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


-(void)setSpriteFrameWithName:(NSString*)spriteFrame;

@end
