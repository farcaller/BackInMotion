//
//  rubymotion.h
//  BackInMotion
//
//  Created by farcaller on 8/15/12.
//
//  This file is covered by the Ruby license. See MACRUBY_COPYING for more details.

#ifndef BackInMotion_rubymotion_h
#define BackInMotion_rubymotion_h

typedef unsigned long VALUE;

struct RBasic {
    VALUE klass; /* isa */
    VALUE flags;
};

#define RSTRING_EMBED_LEN_MAX ((sizeof(VALUE)*3)/sizeof(char)-1)

struct RString {
    struct RBasic basic;
    union {
		struct {
			long len;
			char *ptr;
			union {
				long capa;
				VALUE shared;
			} aux;
		} heap;
		char ary[RSTRING_EMBED_LEN_MAX];
    } as;
};

typedef struct {
    short min;		// min number of args that we accept
    short max;		// max number of args that we accept (-1 if rest)
    short left_req;	// number of args required on the left side
    short real;		// number of args of the low level function
} rb_vm_arity_t;

typedef struct rb_vm_method_node {
    rb_vm_arity_t arity;
    Class klass;
    SEL sel;
    IMP objc_imp;
    IMP ruby_imp;
    int flags;
} rb_vm_method_node_t;

struct __bs_element_arg;
struct __bs_element_retval;
typedef struct __bs_element_arg bs_element_arg_t;
typedef struct __bs_element_retval bs_element_retval_t;

typedef struct {
	SEL name;
	bs_element_arg_t *args;
	unsigned args_count;
	bs_element_retval_t *retval;
	bool class_method;
	bool variadic;
	bool ignore;
	char *suggestion;
} bs_element_method_t;

typedef VALUE rb_vm_objc_stub_t(IMP imp, id self, SEL sel, int argc, const VALUE *argv);
typedef VALUE rb_vm_c_stub_t(IMP imp, int argc, const VALUE *argv);

typedef struct {
	char *name;
	bs_element_arg_t *args;
	unsigned args_count;
	bs_element_retval_t *retval;
	bool variadic;
} bs_element_function_t;

struct mcache {
#define MCACHE_RCALL 0x1 // Ruby call
#define MCACHE_OCALL 0x2 // Objective-C call
#define MCACHE_FCALL 0x4 // C call
#define MCACHE_SUPER 0x8 // Super call (only applied with RCALL or OCALL)
    uint8_t flag;
    SEL sel;
    Class klass;
    union {
		struct {
			rb_vm_method_node_t *node;
		} rcall;
		struct {
			IMP imp;
			int argc;
			bs_element_method_t *bs_method;
			rb_vm_objc_stub_t *stub;
		} ocall;
		struct {
			IMP imp;
			bs_element_function_t *bs_function;
			rb_vm_c_stub_t *stub;
		} fcall;
    } as;
};

extern VALUE rb_cObject;
extern VALUE rb_cFixnum;
extern VALUE rb_cFloat;
extern VALUE rb_cTrueClass;
extern VALUE rb_cNilClass;
extern VALUE rb_cFalseClass;
extern VALUE rb_eNoMethodError;
extern VALUE rb_cRubyArray;

/* special contants - i.e. non-zero and non-fixnum constants */
enum ruby_special_consts {
    RUBY_Qfalse = 0,
    RUBY_Qtrue  = 2,
    RUBY_Qnil   = 4,
    RUBY_Qundef = 6,
	
    RUBY_IMMEDIATE_MASK = 0x03,
    RUBY_FIXNUM_FLAG    = 0x01,
    RUBY_FIXFLOAT_FLAG	= 0x03,
    RUBY_SPECIAL_SHIFT  = 8,
};

#if SIZEOF_LONG == SIZEOF_VOIDP
//ypedef unsigned long VALUE;
# define ID unsigned long
# define SIGNED_VALUE long
# define SIZEOF_VALUE SIZEOF_LONG
# define PRIdVALUE "ld"
# define PRIiVALUE "li"
# define PRIoVALUE "lo"
# define PRIuVALUE "lu"
# define PRIxVALUE "lx"
# define PRIXVALUE "lX"
# define PRI_TIMET_PREFIX "l"
#elif SIZEOF_LONG_LONG == SIZEOF_VOIDP
//typedef unsigned LONG_LONG VALUE;
typedef unsigned LONG_LONG ID;
# define SIGNED_VALUE LONG_LONG
# define LONG_LONG_VALUE 1
# define SIZEOF_VALUE SIZEOF_LONG_LONG
# define PRIdVALUE "lld"
# define PRIiVALUE "lli"
# define PRIoVALUE "llo"
# define PRIuVALUE "llu"
# define PRIxVALUE "llx"
# define PRIXVALUE "llX"
# define PRI_TIMET_PREFIX "ll"
#else
# error ---->> ruby requires sizeof(void*) == sizeof(long) to be compiled. <<----
#endif

#define FIXNUM_FLAG RUBY_FIXNUM_FLAG
#define FIXFLOAT_FLAG RUBY_FIXFLOAT_FLAG
#define IMMEDIATE_MASK RUBY_IMMEDIATE_MASK
#define IMMEDIATE_P(x) ((VALUE)(x) & IMMEDIATE_MASK)
#define FIXNUM_P(f) ((((SIGNED_VALUE)(f)) & IMMEDIATE_MASK) == FIXNUM_FLAG)
#define FIXFLOAT_P(v)  (((VALUE)v & IMMEDIATE_MASK) == FIXFLOAT_FLAG)


#define R_CAST(st)   (struct st*)
#define RBASIC(obj)  (R_CAST(RBasic)(obj))

#define Qfalse ((VALUE)RUBY_Qfalse)
#define Qtrue  ((VALUE)RUBY_Qtrue)
#define Qnil   ((VALUE)RUBY_Qnil)
#define Qundef ((VALUE)RUBY_Qundef)	/* undefined value for placeholder */
#define RTEST(v) (((VALUE)(v) & ~Qnil) != 0)

#define VM_MCACHE_SIZE	0x1000
#define DISPATCH_SUPER		0x4  // super call
#define DISPATCH_SPLAT		0x8  // has splat
#define SPECIAL_CONST_P(x) (IMMEDIATE_P(x) || !RTEST(x))

typedef struct RArray {
    struct RBasic basic;
    size_t beg;
    size_t len;
    size_t cap;
    VALUE *elements;
} rb_ary_t;

#define RARY(x) ((rb_ary_t *)x)
#define CLASS_OF(v) rb_class_of((VALUE)(v))
#define SPLAT_ARG_FOLLOWS	0xdeadbeef

#define T_ARRAY  RUBY_T_ARRAY
enum ruby_value_type {
    RUBY_T_NONE   = 0x00,
	
    RUBY_T_OBJECT = 0x01,
    RUBY_T_CLASS  = 0x02,
    RUBY_T_MODULE = 0x03,
    RUBY_T_FLOAT  = 0x04,
    RUBY_T_STRING = 0x05,
    RUBY_T_REGEXP = 0x06,
    RUBY_T_ARRAY  = 0x07,
    RUBY_T_HASH   = 0x08,
    RUBY_T_STRUCT = 0x09,
    RUBY_T_BIGNUM = 0x0a,
    RUBY_T_FILE   = 0x0b,
    RUBY_T_DATA   = 0x0c,
    RUBY_T_MATCH  = 0x0d,
    RUBY_T_COMPLEX  = 0x0e,
    RUBY_T_RATIONAL = 0x0f,
	
    RUBY_T_NIL    = 0x11,
    RUBY_T_TRUE   = 0x12,
    RUBY_T_FALSE  = 0x13,
    RUBY_T_SYMBOL = 0x14,
    RUBY_T_FIXNUM = 0x15,
    RUBY_T_NATIVE = 0x16,
	
    RUBY_T_UNDEF  = 0x1b,
    RUBY_T_NODE   = 0x1c,
    RUBY_T_ICLASS = 0x1d,
	
    RUBY_T_MASK   = 0x1f,
};

#define NIL_P(v) ((VALUE)(v) == Qnil)

#define RARRAY_LEN(ARRAY) RARY(ARRAY)->len
#define RARRAY_AT(a,i) (RARY(a)->elements[i])

#define xmalloc_ptrs ruby_xmalloc_ptrs


VALUE rb_check_convert_type(VALUE val, int type, const char *tname, const char *method);
VALUE rb_intern(const char*);
struct mcache *rb_vm_get_mcache(void *vm) __attribute__((const));
void *rb_vm_current_vm();
VALUE rb_vm_dispatch(void *_vm, struct mcache *cache, VALUE top, VALUE self_, Class klass, SEL sel, void *block, unsigned char opt, int argc, const VALUE *argv);
static VALUE rb_mod_const_get(VALUE mod, SEL sel, int argc, VALUE *argv);
static inline VALUE rb_class_of(VALUE obj);
static inline VALUE rb_vm_call0(void *vm, VALUE top, VALUE self, Class klass, SEL sel, void *block, unsigned char opt, int argc, const VALUE *argv);
VALUE vm_dispatch(VALUE top, VALUE self, void *sel, void *block, unsigned char opt, int argc, VALUE *argv);
void rb_raise(VALUE exc, const char *fmt, ...);
static void __attribute__((noinline)) vm_resolve_args(VALUE **pargv, size_t argv_size, int *pargc, VALUE *args);
VALUE rb_ary_new4(long n, const VALUE *elts);
void * ruby_xmalloc_ptrs(size_t size);
VALUE rb_const_get(VALUE klass, ID id);

#endif
