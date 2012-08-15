//
//  rubymotion.m
//  BackInMotion
//
//  Created by farcaller on 8/15/12.
//
//  This file is covered by the Ruby license. See MACRUBY_COPYING for more details.

#import "rubymotion.h"

static inline VALUE rb_class_of(VALUE obj)
{
    if (IMMEDIATE_P(obj)) {
		if (FIXNUM_P(obj)) {
			return rb_cFixnum;
		}
		if (FIXFLOAT_P(obj)) {
			return rb_cFloat;
		}
		if (obj == Qtrue) {
			return rb_cTrueClass;
		}
    }
    else if (!RTEST(obj)) {
		if (obj == Qnil) {
			return rb_cNilClass;
		}
		if (obj == Qfalse) {
			return rb_cFalseClass;
		}
    }
    return RBASIC(obj)->klass;
}

static inline int rb_vm_mcache_hash(Class klass, SEL sel)
{
    return (((unsigned long)klass >> 3) ^ (unsigned long)sel)
	& (VM_MCACHE_SIZE - 1);
}

static inline VALUE rb_vm_call0(void *vm, VALUE top, VALUE self, Class klass, SEL sel, void *block, unsigned char opt, int argc, const VALUE *argv)
{
    int hash = rb_vm_mcache_hash(klass, sel);
    if (opt & DISPATCH_SUPER) {
		hash++;
    }
    struct mcache *cache = &rb_vm_get_mcache(vm)[hash];
    return rb_vm_dispatch(vm, cache, top, self, klass, sel, block, opt,
						  argc, argv);
}

static inline VALUE *rary_ptr(VALUE ary)
{
    return &RARY(ary)->elements[RARY(ary)->beg];
}

static inline VALUE vm_class_of(VALUE obj)
{
    // TODO: separate the const bits of CLASS_OF to make sure they will get
    // reduced by the optimizer.
    return CLASS_OF(obj);
}

VALUE vm_dispatch(VALUE top, VALUE self, void *sel, void *block, unsigned char opt, int argc, VALUE *argv)
{
    if (opt & DISPATCH_SUPER) {
		if (sel == 0) {
			rb_raise(rb_eNoMethodError, "super called outside of method");
		}
    }
	
    VALUE buf[100];
    if (opt & DISPATCH_SPLAT) {
		if (argc == 1 && !SPECIAL_CONST_P(argv[1])
			&& *(VALUE *)argv[1] == rb_cRubyArray) {
			argc = RARY(argv[1])->len;
			argv = rary_ptr(argv[1]);
		}
		else {
			VALUE *new_argv = buf;
			vm_resolve_args(&new_argv, 100, &argc, argv);
			argv = new_argv;
		}
		if (argc == 0) {
			const char *selname = sel_getName((SEL)sel);
			const size_t selnamelen = strlen(selname);
			if (selname[selnamelen - 1] == ':') {
				// Because
				//   def foo; end; foo(*[])
				// creates foo but dispatches foo:.
				char buf[100];
				strncpy(buf, selname, sizeof buf);
				buf[selnamelen - 1] = '\0';
				sel = sel_registerName(buf);
			}
		}
    }
	
    void *vm = rb_vm_current_vm();
    VALUE klass = vm_class_of(self);
    return rb_vm_call0(vm, top, self, (Class)klass, (SEL)sel,
					   (void *)block, opt, argc, argv);
}

static void __attribute__((noinline)) vm_resolve_args(VALUE **pargv, size_t argv_size, int *pargc, VALUE *args)
{
    unsigned int i, argc = *pargc, real_argc = 0, j = 0;
    VALUE *argv = *pargv;
    bool splat_arg_follows = false;
    for (i = 0; i < argc; i++) {
		VALUE arg = args[j++];
		if (arg == SPLAT_ARG_FOLLOWS) {
			splat_arg_follows = true;
			i--;
		}
		else {
			if (splat_arg_follows) {
				VALUE ary = rb_check_convert_type(arg, T_ARRAY, "Array",
												  "to_a");
				if (NIL_P(ary)) {
					ary = rb_ary_new4(1, &arg);
				}
				int count = RARRAY_LEN(ary);
				if (real_argc + count >= argv_size) {
					const size_t new_argv_size = real_argc + count + 100;
					VALUE *new_argv = (VALUE *)xmalloc_ptrs(sizeof(VALUE)
															* new_argv_size);
					memcpy(new_argv, argv, sizeof(VALUE) * argv_size);
					argv = new_argv;
					argv_size = new_argv_size;
				}
				int j;
				for (j = 0; j < count; j++) {
					argv[real_argc++] = RARRAY_AT(ary, j);
				}
				splat_arg_follows = false;
			}
			else {
				if (real_argc >= argv_size) {
					const size_t new_argv_size = real_argc + 100;
					VALUE *new_argv = (VALUE *)xmalloc_ptrs(sizeof(VALUE)
															* new_argv_size);
					memcpy(new_argv, argv, sizeof(VALUE) * argv_size);
					argv = new_argv;
					argv_size = new_argv_size;
				}
				argv[real_argc++] = arg;
			}
		}
    }
    *pargv = argv;
    *pargc = real_argc;
}
