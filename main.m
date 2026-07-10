#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#include "tinyhook/include/tinyhook.h"

#if defined(__arm64__) || defined(__aarch64__)
#define kValidateLicenseAddress 0x10034D4F0
#define kSetRegProgramAddress   0x10026C430
#elif defined(__x86_64__)
#define kValidateLicenseAddress 0x10038E2D0
#define kSetRegProgramAddress   0x100296D90
#endif

#define kGuardFlagOffset        107
#define kLicenseFlagOffset      105
#define kQDocTabPointerOffset   184

static void (*setRegProgram)(void *, BOOL);

static void hooked_ValidateLicense(void *self) {
    *((uint8_t *)self + kGuardFlagOffset) = 1;
    *((uint8_t *)self + kLicenseFlagOffset) = 1;

    void **qdoctab = (void **)((char *)self + kQDocTabPointerOffset);
    if (qdoctab && *qdoctab) {
        setRegProgram(*qdoctab, YES);
    }
}

static int imageIndex(const char *name) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *path = _dyld_get_image_name(i);
        const char *last = strrchr(path, '/');
        if (last && strcmp(last + 1, name) == 0) return i;
        if (!last && strcmp(path, name) == 0) return i;
    }
    return -1;
}

__attribute__((constructor))
static void init() {
    @autoreleasepool {
        NSLog(@"[MPE] loaded");

        int idx = imageIndex("Master PDF Editor");
        if (idx < 0) {
            NSLog(@"[MPE] ERROR: image not found");
            return;
        }

        intptr_t slide = _dyld_get_image_vmaddr_slide(idx);

        void *target = (void *)(kValidateLicenseAddress + slide);
        if (tiny_hook(target, hooked_ValidateLicense, NULL) != 0) {
            NSLog(@"[MPE] ERROR: hook failed");
            return;
        }

        setRegProgram = (void (*)(void *, BOOL))(kSetRegProgramAddress + slide);

        NSLog(@"[MPE] ready");
    }
}
