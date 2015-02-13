//
//  LHBone.mm
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHBone.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHAnimation.h"
#import "LHBoneNodes.h"
#import "SKNode+Transforms.h"

@interface LHBoneConnection : NSObject
{
    float angleDelta;
    CGPoint positionDelta;
    __weak SKNode* connectedNode;
    NSString* connectedNodeName;
    __weak LHBone* bone;
}

-(id)initWithDictionary:(NSDictionary*)dict bone:(LHBone*)prnt;

-(float)angleDelta;
-(CGPoint)positionDelta;
-(SKNode*)connectedNode;
-(NSString*)connectedNodeName;
-(LHBone*)bone;
-(void)updateDeltas;

@end


@implementation LHBoneConnection

-(id)initWithDictionary:(NSDictionary*)dict bone:(LHBone*)prnt
{
    self = [super init];
    if(self){
        bone = prnt;
        
        angleDelta = [dict floatForKey:@"angleDelta"];
        positionDelta = [dict pointForKey:@"positionDelta"];
        
        NSString* nm = [dict objectForKey:@"nodeName"];
        if(nm){
            connectedNodeName = [[NSString alloc] initWithString:nm];
        }
    }
    return self;
}

-(void)dealloc{
    
    bone = nil;
    LH_SAFE_RELEASE(connectedNodeName);
    connectedNode = nil;
    LH_SUPER_DEALLOC();
}

-(float)angleDelta{
    return angleDelta;
}
-(CGPoint)positionDelta{
    return positionDelta;
}
-(SKNode*)connectedNode{
    if(!connectedNode && connectedNodeName && bone){
        LHBoneNodes* str = [bone rootBoneNodes];
        SKNode* node = [str childNodeWithName:connectedNodeName];
        if(node){
            connectedNode = node;
            [self updateDeltas];
        }
    }
    return connectedNode;
}

-(NSString*)connectedNodeName{
    return connectedNodeName;
}

-(LHBone*)bone{
    return bone;
}
-(void)updateDeltas{
    
    SKNode* node = [self connectedNode];
    
    if(!node)return;
    
    float boneWorldAngle = [[bone parent] convertToWorldAngle:[bone zRotation]];
    float spriteWorldAngle = [[node parent] convertToWorldAngle:[node zRotation]];
    angleDelta = spriteWorldAngle - boneWorldAngle;

    CGPoint nodeWorldPos = [node convertToWorldSpaceAR:CGPointZero];
    positionDelta = [bone convertToNodeSpace:nodeWorldPos];

//    [node setAnchorByKeepingPosition:ccp(0.5, 0.5)];
}

@end






@implementation LHBone
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    
    float maxAngle;
    float minAngle;
    BOOL rigid;
    NSMutableArray* connections;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    LH_SAFE_RELEASE(connections);

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
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];

        
        maxAngle = [dict floatForKey:@"maxAngle"];
        minAngle = [dict floatForKey:@"minAngle"];
        rigid = [dict boolForKey:@"rigid"];
        
        connections = [[NSMutableArray alloc] init];
        
        NSArray* conInfo = [dict objectForKey:@"connections"];
        for(NSDictionary* dict in conInfo)
        {
            LHBoneConnection* con = LH_AUTORELEASED([[LHBoneConnection alloc] initWithDictionary:dict bone:self]);
            [connections addObject:con];
        }

        
//#if LH_DEBUG
//
//        
//        CGSize size = [dict sizeForKey:@"size"];
//        
//        CGSize prntSize = CGSizeZero;
//        if([prnt respondsToSelector:@selector(lhContentSize)]){
//            prntSize = [(id<LHNodeProtocol>)prnt lhContentSize];
//        }
//        
//        SKShapeNode* debugShapeNode = [SKShapeNode node];
//        
//        CGPoint pos = CGPointMake(size.width*0.5, -prntSize.height*0.5);
//        [debugShapeNode setPosition:pos];
//         
//        CGMutablePathRef debugLinePath = CGPathCreateMutable();
//        CGPathMoveToPoint(debugLinePath, nil, size.width*0.5, 0);
//        CGPathAddLineToPoint(debugLinePath, nil, size.width*0.5, size.height);
//        
//        
//        debugShapeNode.path = debugLinePath;
//        CGPathRelease(debugLinePath);
//        
//        debugShapeNode.strokeColor = [SKColor yellowColor];
//        [self addChild:debugShapeNode];
//        
//#endif//LH_DEBUG
        
    }
    
    
    
    return self;
}

-(float)maxAngle{
    return maxAngle;
}
-(float)minAngle{
    return minAngle;
}
-(BOOL)rigid{
    return rigid;
}

-(BOOL)isRoot{
    return ![[self parent] isKindOfClass:[LHBone class]];
}


-(LHBone*)rootBone{
    if([self isRoot]){
        return self;
    }
    return [(LHBone*)[self parent] rootBone];
}
-(LHBoneNodes *)rootBoneNodes{
    
    if([self rootBone])
    {
        NSArray* sprStruct = [[self rootBone] childrenOfType:[LHBoneNodes class]];
        if(sprStruct && [sprStruct count] > 0){
            return [sprStruct objectAtIndex:0];
        }
    }
    return nil;
}

-(void)transformConnectedSprites
{
    float curWorldAngle = [[self parent] convertToWorldAngle:[self zRotation]];
    CGPoint curWorldPos = [[self parent] convertToWorldSpace:[self position]];

    for(LHBoneConnection* con in connections)
    {
        SKNode* sprite = [con connectedNode];
        if(sprite)
        {
            CGPoint unit = [sprite unitForGlobalPosition:curWorldPos];
            
            float newSpriteAngle = [[sprite parent] convertToNodeAngle:curWorldAngle] + [con angleDelta];

            CGPoint prevAnchor = CGPointMake(0.5, 0.5);
            if([sprite isKindOfClass:[SKSpriteNode class]])
            {
                prevAnchor = [(SKSpriteNode*)sprite anchorPoint];
                [(SKSpriteNode*)sprite setAnchorPoint:unit];
            }
            
            
            [sprite setZRotation:newSpriteAngle];
            if([sprite isKindOfClass:[SKSpriteNode class]]){
                [(SKSpriteNode*)sprite setAnchorPoint:prevAnchor];
            }
        
            CGPoint posDif = [con positionDelta];
            CGPoint deltaWorldPos = [self convertToWorldSpace:posDif];
            CGPoint newSpritePos = [[sprite parent] convertToNodeSpace:deltaWorldPos];
            [sprite setPosition:newSpritePos];
        }
    }
    
    for(LHBone* b in [self children]){
        if([b isKindOfClass:[LHBone class]]){
            [b transformConnectedSprites];
        }
    }
}

-(void)setZRotation:(CGFloat)zRotation{
    [super setZRotation:zRotation];
    [self transformConnectedSprites];
}
-(void)setPosition:(CGPoint)position{
    [super setPosition:position];
    [self transformConnectedSprites];
}

- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    [_nodeProtocolImp update:currentTime delta:dt];
    [_animationProtocolImp update:currentTime delta:dt];
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
