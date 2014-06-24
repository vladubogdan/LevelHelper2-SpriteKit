//
//  LHWater.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"

/**
 LHWater class is used to load and display a water area from a level file.
 Users can retrieve a water objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHWater : SKShapeNode <LHNodeProtocol>

+ (instancetype)waterNodeWithDictionary:(NSDictionary*)dict
                                 parent:(SKNode*)prnt;



@end
