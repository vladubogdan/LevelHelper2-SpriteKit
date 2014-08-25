//
//  LHUINode.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
/**
 LHNode class is used to load the UI elements.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHUINode : SKSpriteNode <LHNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

@end
