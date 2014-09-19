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
    NSDictionary* _tracedFixtures;
    
    CGSize _size;
    
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_tracedFixtures);
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
    
    
    if(self = [super init]){
        
        [prnt addChild:self];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        _size = [dict sizeForKey:@"size"];

        //scale is handled by physics protocol because of diferences between spritekit and box2d handling
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        LHScene* scene = (LHScene*)[self scene];
        
        BOOL fileExists = false;
        if([dict objectForKey:@"assetFile"])
        {
            NSDictionary* assetInfo = [scene assetInfoForFile:[dict objectForKey:@"assetFile"]];
        
            if(assetInfo)
            {
                fileExists = true;
                NSDictionary* tracedFix = [assetInfo objectForKey:@"tracedFixtures"];
                if(tracedFix){
                    _tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFix];
                }

                [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:assetInfo];
            }
        }        
        if(!fileExists){
            NSLog(@"WARNING: COULD NOT FIND INFORMATION FOR ASSET %@. This usually means that the asset was created but not saved. Check your level and in the Scene Navigator, click on the lock icon next to the asset name.", [self name]);
            [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
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

        
        NSDictionary* tracedFix = [assetInfo objectForKey:@"tracedFixtures"];
        if(tracedFix){
            _tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFix];
        }

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:assetInfo
                                                                                    node:self];
        _size = [assetInfo sizeForKey:@"size"];
        
        //scale is handled by physics protocol because of diferences between spritekit and box2d handling
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:assetInfo
                                                                                                node:self];
        
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
        
        [self update:0 delta:0];
    }
    
    return self;
}

-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid{
    return [_tracedFixtures objectForKey:uuid];
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
