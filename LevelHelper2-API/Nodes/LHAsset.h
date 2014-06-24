//
//  LHAsset.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"

/**
 LHAsset class is used to load an asset object from a level file or from the resources folder.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHAsset : SKNode <LHNodeProtocol, LHNodeAnimationProtocol>

+(instancetype)assetWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;


@end
