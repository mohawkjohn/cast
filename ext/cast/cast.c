#include "cast.h"

/* Initialize the cast_ext module.
 */
void Init_cast(void) {
  cast_mC = rb_define_module("C");
  cast_init_parser();
}
