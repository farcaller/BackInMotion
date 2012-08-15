//
//  BackInMotion.h
//  BackInMotion
//
//  Created by farcaller on 8/15/12.
//  Copyright (c) 2012 Hack&Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This is the main entry point for RubyMotion calls. The only exposed method is
    const_get, that is a proxy to Object#const_get
 */
@interface BackInMotion : NSObject

/** Performs a Object#const_get ruby call and wraps the resulting object into
    RubyObjectProxy
 */
+ (id)const_get:(NSString *)topLevelConst;

@end

/** This is a transparent proxy to ruby object that passes selector calls to
    vm_dispatch. It should be safe to call any ruby method through an instance
    of this class.
 
    Note that you *must* pass only NSObject-based or Object-based arguments. That
    is, wrap up all your numbers and booleans.
 */
@interface RubyObjectProxy : NSProxy

+ (id)objectWithRubyObject:(id)rbObj;

/** This method allows you to access the internal ruby object instance directly.
    It might be useful in some cases, as I'm not the best specialist on NSProxy,
    and there are some cases when RubyObjectProxy works bad.
 */
- (id)__rubyObject;

@end

/** RubyDispatch function is a vm_dispatch-like wrapper for ruby runtime. Handle
    with care.
 */
extern id RubyDispatch(id top, id target, SEL sel, NSArray *args);