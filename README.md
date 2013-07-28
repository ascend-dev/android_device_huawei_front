E/HAL     (  168): load: module=/system/lib/hw/gralloc.default.so
E/HAL     (  168): dlopen failed: cannot locate symbol "_ZNK7android9CallStack4dumpEPKc" referenced by "gralloc.default.so"...
E/SurfaceFlinger(  168): gralloc module not found
V/IMGSRV  (  162): pvrsrvinit complete
E/HAL     (  168): load: module=/system/lib/hw/gralloc.default.so
E/HAL     (  168): dlopen failed: cannot locate symbol "_ZNK7android9CallStack4dumpEPKc" referenced by "gralloc.default.so"...
E/ti_hwc  (  168): Composer HAL failed to load compatible Graphics HAL
E/SurfaceFlinger(  168): composer device failed to initialize (Invalid argument)
E/SurfaceFlinger(  168): ERROR: failed to open framebuffer (Invalid argument), aborting
F/libc    (  168): Fatal signal 11 (SIGSEGV) at 0xdeadbaad (code=1), thread 213 (SurfaceFlinger)



framework/native
if we revert cab25d680e644d962041d05a319e485b96136a5d
then we can show bootanimation,but cant into the system
