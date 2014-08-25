//
//  LHParallaxLayer.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"

/**
 LHParallaxLayer class is used to load a parallax layer object from a level file.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHParallaxLayer : SKNode <LHNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;


/**
 Returns the x ratio that is used to calculate the children position.
 */
-(float)xRatio;

/**
 Returns the y ratio that is used to calculate the children position.
 */
-(float)yRatio;
@end
