// .h
#define singleInterface(className) \
+ (className *)shared##className;

// .m  这个方法是让别人取得单例
#define singleImplementation(className) \
static className *_instance;\
+ (className *)shared##className{\
if(_instance == nil){\
    _instance = [[self alloc]init];\
}\
return _instance;\
}\
/* 使用GCD来保证底层的allocWithZone:方法只会执行一次。目的就是防止别人多次调用alloc方法，本质就是防止别人多次创建用alloc*/\
+ (id)allocWithZone:(struct _NSZone *)zone{\
    static dispatch_once_t oneS;\
    dispatch_once(&oneS, ^{\
        _instance = [super allocWithZone:zone];\
    });\
    return _instance;\
}
