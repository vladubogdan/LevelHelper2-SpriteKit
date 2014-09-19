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
    NSMutableArray* _outlinePoints;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    LH_SAFE_RELEASE(_shapeTriangles);
    LH_SAFE_RELEASE(_outlinePoints);

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
        
        
        self.strokeColor = [dict colorForKey:@"colorOverlay"];
        self.fillColor = [dict colorForKey:@"colorOverlay"];
        
        NSArray* points = [dict objectForKey:@"points"];
        
        _outlinePoints = [[NSMutableArray alloc] init];
        
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
            [_outlinePoints addObject:LHValueWithCGPoint(CGPointMake(vPoint.x, -vPoint.y))];
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

        //scale is handled by physics protocol because of diferences between spritekit and box2d handling

        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        

        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
        
    }
    
    return self;
}

-(NSMutableArray*)shapeTriangles{
    return _shapeTriangles;
}

-(NSMutableArray*)outlinePoints{
    return _outlinePoints;
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
    [_physicsProtocolImp update:currentTime delta:dt];
    [_nodeProtocolImp update:currentTime delta:dt];
    [_animationProtocolImp update:currentTime delta:dt]; 
}


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
