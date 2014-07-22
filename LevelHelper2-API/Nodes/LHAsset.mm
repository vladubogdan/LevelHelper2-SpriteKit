//
//  LHAsset.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHAsset.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName;
@end

@implementation LHAsset
{
    CGSize _size;
    
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    LH_SAFE_RELEASE(_physicsProtocolImp);
    
    LH_SUPER_DEALLOC();
}


+ (instancetype)assetWithDictionary:(NSDictionary*)dict
                             parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initAssetWithDictionary:dict
                                                          parent:prnt]);
}

- (instancetype)initAssetWithDictionary:(NSDictionary*)dict
                                 parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        _size = [dict sizeForKey:@"size"];
#if LH_USE_BOX2D
        {
            CGPoint scl = [dict pointForKey:@"scale"];
            [self setXScale:scl.x];
            [self setYScale:scl.y];
        }
#endif
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        //scale must be set after loading the physic info or else spritekit will not resize the sprite anymore - bug
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setXScale:scl.x];
        [self setYScale:scl.y];
        
        
        LHScene* scene = (LHScene*)[self scene];
        
        NSDictionary* assetInfo = [scene assetInfoForFile:[dict objectForKey:@"assetFile"]];
        
        if(assetInfo)
        {
            [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:assetInfo];
        }
        else{
            NSLog(@"WARNING: COULD NOT FIND INFORMATION FOR ASSET %@", [self name]);
        }
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
    }
    
    return self;
}




+(instancetype)createWithName:(NSString*)assetName
                assetFileName:(NSString*)fileName
                       parent:(SKNode*)prnt
{
    return LH_AUTORELEASED([[self alloc] initWithName:assetName
                                        assetFileName:fileName
                                               parent:prnt]);
}

- (instancetype)initWithName:(NSString*)newName
               assetFileName:(NSString*)fileName
                      parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        [self setName:newName];
        
        LHScene* scene = (LHScene*)[prnt scene];

        NSDictionary* assetInfo = [scene assetInfoForFile:fileName];

        if(!assetInfo){
            NSLog(@"WARNING: COULD NOT FIND INFORMATION FOR ASSET %@", [self name]);
            return self;
        }

        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:assetInfo
                                                                                    node:self];
        _size = [assetInfo sizeForKey:@"size"];
        
#if LH_USE_BOX2D
        {
            [self setXScale:1];
            [self setYScale:1];
        }
#endif
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:assetInfo
                                                                                                node:self];
        
        //scale must be set after loading the physic info or else spritekit will not resize the sprite anymore - bug
        [self setXScale:1];
        [self setYScale:1];

        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:assetInfo];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:assetInfo
                                                                                                      node:self];
        
        
//#if LH_DEBUG
//        SKShapeNode* debugShapeNode = [SKShapeNode node];
//        CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(-_size.width*0.5,
//                                                            -_size.height*0.5,
//                                                            _size.width,
//                                                            _size.height),
//                                                 nil);
//        debugShapeNode.path = pathRef;
//        CGPathRelease(pathRef);
//        debugShapeNode.strokeColor = [SKColor greenColor];
//        [self addChild:debugShapeNode];
//#endif

    }
    
    return self;
}



-(CGSize)size{
    return _size;
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
