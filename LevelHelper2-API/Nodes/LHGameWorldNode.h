//
//  LHGameWorldNode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
/**
 LHNode class is used to load the game world elements.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHGameWorldNode : SKNode <LHNodeProtocol>

+(instancetype)gameWorldNodeWithDictionary:(NSDictionary*)dict
                                    parent:(SKNode*)prnt;

@end
