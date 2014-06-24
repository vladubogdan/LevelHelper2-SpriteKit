//
//  LHShape.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHShape.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

@implementation LHShape
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    NSMutableArray* _shapeTriangles;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    LH_SAFE_RELEASE(_shapeTriangles);
    LH_SAFE_RELEASE(_physicsProtocolImp);

    LH_SUPER_DEALLOC();
}


+ (instancetype)shapeNodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initShapeNodeWithDictionary:dict
                                                              parent:prnt]);
}

- (instancetype)initShapeNodeWithDictionary:(NSDictionary*)dict
                                     parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        self.strokeColor = [dict colorForKey:@"colorOverlay"];
        self.fillColor = [dict colorForKey:@"colorOverlay"];
        
        NSArray* points = [dict objectForKey:@"points"];
        
        CGMutablePathRef linePath = nil;
        for(NSDictionary* pointDict in points)
        {
            CGPoint vPoint = [pointDict pointForKey:@"point"];
            if(!linePath){
                linePath = CGPathCreateMutable();
                CGPathMoveToPoint(linePath, nil, vPoint.x, -vPoint.y);
            }
            else{
                CGPathAddLineToPoint(linePath, nil, vPoint.x, -vPoint.y);
            }
        }

        if(linePath){
            CGPathCloseSubpath(linePath);
            self.path = linePath;
            CGPathRelease(linePath);
        }
        
        NSArray* triangles = [dict objectForKey:@"triangles"];
        if(triangles){
            _shapeTriangles = [[NSMutableArray alloc] initWithArray:triangles];
        }

        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        //scale must be set after loading the physic info or else spritekit will not resize the sprite anymore - bug
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setXScale:scl.x];
        [self setYScale:scl.y];
        

        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
        
    }
    
    return self;
}

-(NSMutableArray*)shapeTriangles{
    return _shapeTriangles;
}


-(CGSize)size{
    return CGPathGetBoundingBox(self.path).size;
}

-(CGRect)boundingBox{
    return CGPathGetBoundingBox(self.path);
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
    [_animationProtocolImp update:currentTime delta:dt];
    [_nodeProtocolImp update:currentTime delta:dt];
}


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
