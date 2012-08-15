//
//  BackInMotion.h
//  BackInMotion
//
//  Created by farcaller on 8/15/12.
//  Copyright (c) 2012 Hack&Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackInMotion : NSObject

+ (id)const_get:(NSString *)topLevelConst;

@end

/** RubyDispatch function is a vm_dispatch-like wrapper for ruby runtime. Handle
    with care.
 */
extern id RubyDispatch(id top, id target, SEL sel, NSArray *args);