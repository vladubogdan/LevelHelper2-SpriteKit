//
//  LHSprite.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSprite.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHAnimation.h"
#import "LHConfig.h"
#import "LHGameWorldNode.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSString*)currentDeviceSuffix;
@end

@implementation LHSprite
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
    
    __unsafe_unretained SKTextureAtlas* atlas;
}

-(void)dealloc{

    atlas = nil;
    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    
    LH_SUPER_DEALLOC();
}

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                               parent:prnt]);
}


- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{

    
    if(self = [super initWithColor:[SKColor whiteColor] size:CGSizeZero]){
        
        [prnt addChild:self];
        
        LHScene* scene = (LHScene*)[self scene];
        NSString* imagePath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                      folder:[dict objectForKey:@"relativeImagePath"]
                                                      suffix:[scene currentDeviceSuffix]];
        
        SKTexture* texture = nil;
        
        NSString* spriteName = [dict objectForKey:@"spriteName"];
        if(spriteName){
            NSString* atlasName = [[imagePath lastPathComponent] stringByDeletingPathExtension];
            atlasName = [[scene relativePath] stringByAppendingPathComponent:atlasName];
            atlas = [scene textureAtlasWithImagePath:atlasName];
            texture = [atlas textureNamed:spriteName];
        }
        else{
            texture = [scene textureWithImagePath:imagePath];
        }
        
        
        if(texture){
            [self setTexture:texture];
            [self setSize:texture.size];
        }

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];

        [self setColor:[dict colorForKey:@"colorOverlay"]];

        if(texture){
            [self setSize:texture.size];
        }

        //scale is handled by physics protocol because of diferences between spritekit and box2d handling

        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
                
    
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
        
    }
    return self;
}

-(void)setSpriteFrameWithName:(NSString*)spriteFrame{
    if(atlas){
        SKTexture* texture = [atlas textureNamed:spriteFrame];
        if(texture){
            [self setTexture:texture];
            
            float xScale = [self xScale];
            float yScale = [self yScale];
            
            [self setXScale:1];
            [self setYScale:1];
            
            [self setSize:texture.size];
            
            [self setXScale:xScale];
            [self setYScale:yScale];
        }
    }
}

#pragma mark - Box2D Support
#if LH_USE_BOX2D
LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION
#endif //LH_USE_BOX2D


#pragma mark - Common Physics Engines Support
LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    [_physicsProtocolImp update:currentTime delta:dt];
    [_nodeProtocolImp update:currentTime delta:dt];
    [_animationProtocolImp update:currentTime delta:dt];
}

#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
