//
//  BackInMotion.m
//  BackInMotion
//
//  Created by farcaller on 8/15/12.
//  Copyright (c) 2012 Hack&Dev. All rights reserved.
//

#import "BackInMotion.h"
#import "rubymotion.h"

@interface RubyObjectProxy : NSProxy

+ (id)objectWithRubyObject:(id)rbObj;

@end


@implementation BackInMotion

+ (id)const_get:(NSString *)topLevelConst
{
	id rbobj = (id)rb_const_get(rb_cObject, rb_intern([topLevelConst UTF8String]));
	
	id proxy = [RubyObjectProxy objectWithRubyObject:rbobj];
	
	return proxy;
}

@end

#pragma mark - Runtime Warapper
static id RubyDispatch(id top, id target, SEL sel, NSArray *args)
{
	const VALUE *argv = NULL;
	int argc = [args count];
	if(argc > 0) {
		argv = (VALUE *)malloc(sizeof(void*) * argc);
		VALUE *a = (VALUE *)argv;
		for(id obj in args) {
			*a = (VALUE)obj;
			a++;
		}
	}
	
	id ret = (id)vm_dispatch((VALUE)top, (VALUE)target, sel, NULL, 0, argc, (VALUE*)argv);
	
	if(argc > 0) {
		free((VALUE *)argv);
	}
	
	return ret;
}

#pragma mark - Proxy Object
@implementation RubyObjectProxy
{
	id _rbObj;
}

+ (id)objectWithRubyObject:(id)rbObj
{
	RubyObjectProxy *o = [RubyObjectProxy alloc];
	o->_rbObj = rbObj;
	return o;
}

- (id)__rubyObject
{
	return _rbObj;
}

- (NSString *)description
{
	return RubyDispatch((id)rb_cObject, _rbObj, @selector(inspect), nil);
}

- (NSString *)descriptionWithLocale:(id)locale
{
	return [self description];
}

- (Class)class
{
	return RubyDispatch((id)rb_cObject, _rbObj, @selector(class), nil);
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	NSMutableArray *args = [NSMutableArray array];
	for(int arg = 2; arg < [[anInvocation methodSignature] numberOfArguments]; arg++) {
		id argVal;
		[anInvocation getArgument:&argVal atIndex:arg];
		[args addObject:argVal];
	}
	
	id ret = RubyDispatch((id)rb_cObject, _rbObj, [anInvocation selector], args);
	// XXX: NSLog(@"dispatch %@#%@", RubyDispatch((id)rb_cObject, _rbObj, @selector(class), @[]), NSStringFromSelector([anInvocation selector]));
	
	id retProxy = [RubyObjectProxy objectWithRubyObject:ret];
	[anInvocation setReturnValue:&retProxy];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if([NSStringFromSelector(aSelector) isEqualToString:@"__rubyObject"]) {
		return YES;
	}
	
	BOOL responds = [RubyDispatch((id)rb_cObject, _rbObj, NSSelectorFromString(@"respond_to?:"), @[ NSStringFromSelector(aSelector) ]) boolValue];
	if(!responds) {
		NSLog(@"object %@ does not respont to %@", _rbObj, NSStringFromSelector(aSelector));
	}
	return responds;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
	const char *s = sel_getName(sel);
	char *p = (char*)s;
	int args = 0;
	while(*p != '\0') {
		p++;
		if(*p == ':') {
			args++;
		}
	}
	
	char sig[255];
	strcpy(sig, "@@:");
	char *sigargs = sig + 3;
	for(int i=0; i<args; ++i) {
		*sigargs = '@';
		sigargs++;
	}
	*sigargs = '\0';
	
	return [NSMethodSignature signatureWithObjCTypes:sig];
}

@end