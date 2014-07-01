//
//  LHBackUINode.mm
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHBackUINode.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

@implementation LHBackUINode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SUPER_DEALLOC();
}


+ (instancetype)backUINodeWithDictionary:(NSDictionary*)dict
                                  parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initBackUINodeWithDictionary:dict
                                                               parent:prnt]);
}

- (instancetype)initBackUINodeWithDictionary:(NSDictionary*)dict
                                      parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
    
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        self.zPosition = -1000;
        self.position = CGPointZero;
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
    }
    
    return self;
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    [_nodeProtocolImp update:currentTime delta:dt];
}



@end
