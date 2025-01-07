MEMORY {
  PROG : ORIGIN = 0x0, LENGTH = 64K
  DATA : ORIGIN = 64K, LENGTH = 32K
  STACK : ORIGIN = 96K, LENGTH = 32K
  /* BSS : ORIGIN = 128K, LENGTH = 128K */
}

__stack_size = 32K;

ENTRY(_start)

SECTIONS {
   .text : ALIGN(16) {
     *(.text)
   } > PROG

   .data : ALIGN(16) {
     *(.rodata)
     *(.rodata.*)
     *(.data)
     *(.data.*)
   } > DATA

   .bss : ALIGN(16) {
     *(.bss)
     *(.bss.*)
   }

   .stack : ALIGN(16) {
     _estack = .;
   } > STACK

   _sstack = _estack + __stack_size;
 }
