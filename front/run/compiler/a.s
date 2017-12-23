#初始化sp，检查ram，检查键盘，检查数码管，启动用户程序
#ram检查是每个字节写入55和0AA，然后在读出
#键盘检查：刚开始没有按键，测试时如果是有键状态则是错误
#数码管是依次输出1111H,2222H,3333H。。。9999H

.TEXT 0X0000    #还有2条指令的空余
        LUI  $SP,0X0001   #初始化sp
        ADDI $T0,$ZERO,0
        ORI  $T1,$ZERO,0XFFFC
        LUI  $T5,0X55AA
        ADDI $T5,$T5,0X55AA
        LUI  $T6,0XAA55
        ORI  $T6,$T6,0XAA55
        ADD  $T2,$ZERO,$T5
        ADD  $T3,$ZERO,$T6
        ADDI $T9,$ZERO,0XFFFF     #$T9=0XFFFFFFFF
        ADDI $S0,$ZERO,0X0E1    #ram错误码
CHKRAM: LW   $T8,0($T0)
        SW   $T2,0($T0)
        LW   $T4,0($T0)
        BNE  $T4,$T2,ERROR      #比较：存入55aa55aa和取出数值是否相同
        NOP
        SW   $T3,0($T0)
        LW   $T4,0($T0)
        BNE  $T4,$T3,ERROR      #比较：存入aa55aa55和取出数值是否相同
        NOP
        SW   $T8,0($T0)         #恢复$t8原来的数值
        BEQ  $T0,$T1,CHKKEY     #检查完了则跳转到下个检查项目
        NOP
        ADDI $T0,$T0,4        #没有检查完继续检查下个双字
        SW   $T9,0XFC50($ZERO)
        J    CHKRAM
        NOP
CHKKEY: ADDI $S0,$ZERO,0X0E1    #键盘错误码
        LW   $T0,0XFC12($ZERO)
        ANDI $T0,$T0,1
        BNE  $T0,$ZERO,ERROR    #读键盘后，没有按键时出现按键状态则报错
        NOP
PWM:    ADDI $S0,$ZERO,5        #写PWM，让最大值为5，比较值为3
        SW   $S0,0XFC30($ZERO)
        ADDI $S0,$ZERO,3
        SW   $S0,0XFC32($ZERO)
        ADDI $S0,$ZERO,1
        SW   $S0,0XFC34($ZERO)
CHKLED: ANDI $T0,$ZERO,0
        SW   $T9,0XFC04($ZERO)  #将小数点和数码管数字全部显示
        ORI  $T1,$ZERO,0XFFFF
DISPS:  LUI  $T2,0X007F
        ORI  $T2,$T2,0XFFFF
        SW   $T0,0XFC00($ZERO)  #输出到数码管低四位
        SW   $T0,0XFC02($ZERO)  #输出到数码管高四位
LOP:    ADDI $T2,$T2,-1
	    SW   $T9,0XFC50($ZERO)  #复位看门狗
        BNE  $T2,$ZERO,LOP      #利用循环减控制数码管上的数字显示多长时间
        NOP
        ADDI $T0,$T0,0X1111
        BNE  $T0,$T1,DISPS
        NOP
        SW   $ZERO,0XFC00($ZERO)
        SW   $ZERO,0XFC02($ZERO)
        ORI  $T9,$ZERO,0XFF00
        SW   $T9,0XFC04($ZERO)  #$T9=0000 0001 0000 0001`B,将数码管置为0.
        J    0X0200             #跳转到用户程序首地址
        NOP
ERROR:  SW   $S0,0XFC00($ZERO) #在数码管上输出错误码
LP:     SW   $T9,0XFC50($ZERO)  #复位看门狗
        J    LP
        NOP

#七段数码管    用到的寄存器：$S0,$S1,$S2,$SP,$A0,$A1,$A2,$A3,$RA
#寄存器用途：$S0,$S1,$S2：用于存储临时变量；$RA:子程序返回；
#            $A0：（0号功能：4位数码管数值都改，1号功能：只更改某一位数），
#            $A1：要修改当前数码管端口的哪一位,$A2:要输出的数值。根据$A3来选择数码管的哪个端口输出
#            （0：特殊显示寄存器端口，1：低四位数码管端口，2：高四位数码管端口）
#功能：先根据$a0选择数码管功能，如果是0号功能，即只需要将$a2里的数值输出到$a3所选择的端口；
#      如果是1号功能，则先根据$a3跳到对应数据段取出数据，然后根据$a1跳转对应位数处理程序，
#      修改完数据存到$a2，然后根据$a3跳到对应输出端口将$a2中数值输出到该端口

.DATA    0X0000
        LEDDATA .word 0X0,0X0,0X0101
.TEXT    0X0040                     #还有4条指令空余
        ADDI    $SP,$SP,-4
        SW      $S0,0($SP)          #$s0压栈
        ADDI    $SP,$SP,-4
        SW      $S1,0($SP)          #$s1压栈
        ADDI    $SP,$SP,-4
        SW      $S2,0($SP)          #$s2压栈
        ADDI    $S0,$ZERO,1
        BEQ     $A0,$S0,GETD
        NOP
        J       FUN0
        NOP
GETD:   ADDI    $S0,$ZERO,0
        BEQ     $A3,$S0,DATA0        #低四位数码管端口
        NOP
        ADDI    $S0,$ZERO,1
        BEQ     $A3,$S0,DATA1        #高四位数码管端口
        NOP
        ADDI    $S0,$ZERO,2
        BEQ     $A3,$S0,DATA2        #特殊显示寄存器端口
        NOP
        J       LEDEXIT
        NOP
DATA0:  ADDI    $S2,$ZERO,0
        LW      $S1,LEDDATA($S2)       #数据区提取数据存到$s1中
        J       FUN1
        NOP
DATA1:  ADDI    $S2,$ZERO,4
        LW      $S1,LEDDATA($S2)       #数据区提取数据存到$s1中
        J       FUN1
        NOP
DATA2:  ADDI    $S2,$ZERO,8
        LW      $S1,LEDDATA($S2)       #数据区提取数据存到$s1中
        J       FUN1
        NOP
FUN1:   BEQ     $A1,$ZERO,LOCA0         #根据$a1跳转对应输出位数处理程序
        NOP
        ADDI    $S0,$ZERO,1
        BEQ     $A1,$S0,LOCA1
        NOP
        ADDI    $S0,$ZERO,2
        BEQ     $A1,$S0,LOCA2
        NOP
        ADDI    $S0,$ZERO,3
        BEQ     $A1,$S0,LOCA3
        NOP
        J       LEDEXIT
        NOP
LOCA0:  ADDI   $S2,$ZERO,0XFFF0      #位0输出，$s2=FFFFFFF0
        AND     $S1,$S1,$S2
        OR      $A2,$S1,$A2         #得到最终改好的数据存到$a2中
        J       FUN0
        NOP
LOCA1:  ADDI    $S2,$ZERO,0XFF0F    #位1输出,$s2=FFFFFF0F
        AND     $S1,$S1,$S2
        SLL     $S0,$A2,4           #输出数据左移4位存到$s0中
        ADDI    $S2,$ZERO,0X0F0     #$s2=000000f0，用来排除其他位数据干扰
        AND     $S0,$S0,$S2
        OR      $A2,$S1,$S0         #得到最终改好的数据存到$a2中
        J       FUN0
        NOP
LOCA2:  ADDI    $S2,$ZERO,0XF0FF         #$s2=FFFFF0FF
        AND     $S1,$S1,$S2
        SLL     $S0,$A2,8           #输出数据左移8位存到$s0中
        ADDI    $S2,$ZERO,0X0F00    #$s2=00000f00,用来排除其他位数据干扰
        AND     $S0,$S0,$S2
        OR      $A2,$S1,$S0         #得到最终改好的数据存到$a2中
        J       FUN0
        NOP
LOCA3:  ADDI    $S2,$ZERO,0
        LUI     $S2,0XFFFF
        ADDI    $S2,$S2,0X0FFF      #$s2=FFFF0FFF
        AND     $S1,$S1,$S2
        SLL     $S0,$A2,0X0C        #输出数据左移12位存到$s0中
        ADDI    $S2,$ZERO,0
        LUI     $S2,0XF000          #$s2=f0000000
        SRL     $S2,$S2,0X10        #逻辑右移16位，$s2=0000f000,用来排除其他位数据干扰
        AND     $S0,$S0,$S2
        OR      $A2,$S1,$S0         #得到最终改好的数据存到$a2中
        J       FUN0
        NOP
FUN0:   ADDI    $S0,$ZERO,0
        BEQ     $A3,$S0,DISP0        #低四位数码管端口
        NOP
        ADDI    $S0,$ZERO,1
        BEQ     $A3,$S0,DISP1        #高四位数码管端口
        NOP
        ADDI    $S0,$ZERO,2
        BEQ     $A3,$S0,DISP2        #特殊显示寄存器端口
        NOP
        J       LEDEXIT
        NOP
DISP0:  ADDI    $S2,$ZERO,0
        SW      $A2,0XFC00($ZERO)   #输出到低四位数码管端口
        SW      $A2,LEDDATA($S2)
        J       LEDEXIT
        NOP
DISP1:  ADDI    $S2,$ZERO,4
        SW      $A2,0XFC02($ZERO)   #输出到高四位数码管端口
        SW      $A2,LEDDATA($S2)
        J       LEDEXIT
        NOP
DISP2:  ADDI    $S2,$ZERO,8
        SW      $A2,0XFC04($ZERO)   #输出到特殊显示寄存器端口
        SW      $A2,LEDDATA($S2)
        J       LEDEXIT
        NOP
LEDEXIT: LW      $S2,0($SP)         #恢复$s0,$s1,$S2的值
        ADDI    $SP,$SP,4
        LW      $S1,0($SP)
        ADDI    $SP,$SP,4
        LW      $S0,0($SP)
        ADDI    $SP,$SP,4
        JR      $RA                 #子程序返回
        NOP

#led灯     $A0保存的是输出到led端口的值
.TEXT    0X00C0
        SW      $A0,0XFC60($ZERO)
        JR      $RA
        NOP
#拨码开关    $v0保存从拨码开关端口读出来的值
.TEXT   0X00D0
        LW      $V0,0XFC70($ZERO)
        JR       $RA
        NOP

# 键盘   用到的寄存器：$S0,$S1,$SP, $A0:选择功能, $V0:保存结果 ,$RA:子程序返回
#寄存器用途：$S0,$S1：用于存储临时变量；$RA:子程序返回
#            $A0:选择几号功能, $V0:保存读到的键值
#功能：$A0=1，非循环等待，没有读到键值输出0ffH，$A0=0，循环等待读键，直到读到键值


.TEXT    0X00E0                     #还有19条指令空余
        ADDI    $SP,$SP,-4
        SW      $S0,0($SP)          #S0压栈
        ADDI    $SP,$SP,-4
        SW      $S1,0($SP)          #S1压栈
        ADDI    $S0,$ZERO,1
        BEQ     $A0,$S0,KFUN1       #A0=1,跳转kfun1
        NOP
  KLOP: LW      $S1,0XFC12($ZERO)   #A0=0,循环等待读键状态
        ANDI    $S1,$S1,1
        BEQ     $S1,$ZERO,KLOP
        NOP
        J       READKEY             #有键读入，读键值
        NOP
 KFUN1: LW      $S1,0XFC12($ZERO)   #读取当前的读键状态
        ANDI    $S1,$S1,1
        BEQ     $S1,$ZERO,NOKEY     #读键状态为0，跳转没读到
        NOP
        J       READKEY             #跳转有键按下
        NOP
 NOKEY: ADDI    $V0,$ZERO,0X0FF     #没有读到键值输出0ffH
        J       KEYEXIT
        NOP
READKEY: LW     $S1,0XFC10($ZERO)   #读键值
  KEY1: ADDI    $S0,$ZERO,0X0EE     #根据键值，编码对应的16进制数
        BNE     $S1,$S0,KEY4        #与当前键值比较，不等则继续往下循环比较
        NOP
        ADDI    $V0,$ZERO,1         #相等则把对应编码值存入$V0
        J       KEYEXIT
        NOP
   KEY4: ADDI    $S0,$ZERO,0X0ED
        BNE     $S1,$S0,KEY7
        NOP
        ADDI    $V0,$ZERO,4
        J       KEYEXIT
        NOP
   KEY7: ADDI    $S0,$ZERO,0X0EB
        BNE     $S1,$S0,KEY14
        NOP
        ADDI    $V0,$ZERO,7
        J       KEYEXIT
        NOP
   KEY14: ADDI    $S0,$ZERO,0X0E7
        BNE     $S1,$S0,KEY2
        NOP
        ADDI    $V0,$ZERO,14
        J       KEYEXIT
        NOP
   KEY2: ADDI    $S0,$ZERO,0X0DE
        BNE     $S1,$S0,KEY5
        NOP
        ADDI    $V0,$ZERO,2
        J       KEYEXIT
        NOP
   KEY5: ADDI    $S0,$ZERO,0X0DD
        BNE     $S1,$S0,KEY8
        NOP
        ADDI    $V0,$ZERO,5
        J       KEYEXIT
        NOP
   KEY8: ADDI    $S0,$ZERO,0X0DB
        BNE     $S1,$S0,KEY0
        NOP
        ADDI    $V0,$ZERO,8
        J       KEYEXIT
        NOP
   KEY0: ADDI    $S0,$ZERO,0X0D7
        BNE     $S1,$S0,KEY3
        NOP
        ADDI    $V0,$ZERO,0
        J       KEYEXIT
        NOP
   KEY3: ADDI    $S0,$ZERO,0X0BE
        BNE     $S1,$S0,KEY6
        NOP
        ADDI    $V0,$ZERO,3
        J       KEYEXIT
        NOP
   KEY6: ADDI    $S0,$ZERO,0X0BD
        BNE     $S1,$S0,KEY9
        NOP
        ADDI    $V0,$ZERO,6
        J       KEYEXIT
        NOP
  KEY9: ADDI    $S0,$ZERO,0X0BB
        BNE     $S1,$S0,KEY15
        NOP
        ADDI    $V0,$ZERO,9
        J       KEYEXIT
        NOP
  KEY15: ADDI    $S0,$ZERO,0X0B7
        BNE     $S1,$S0,KEY10
        NOP
        ADDI    $V0,$ZERO,15
        J       KEYEXIT
        NOP
  KEY10: ADDI    $S0,$ZERO,0X7E
        BNE     $S1,$S0,KEY11
        NOP
        ADDI    $V0,$ZERO,10
        J       KEYEXIT
        NOP
  KEY11: ADDI    $S0,$ZERO,0X7D
        BNE     $S1,$S0,KEY12
        NOP
        ADDI    $V0,$ZERO,11
        J       KEYEXIT
        NOP
  KEY12: ADDI    $S0,$ZERO,0X7B
        BNE     $S1,$S0,KEY13
        NOP
        ADDI    $V0,$ZERO,12
        J       KEYEXIT
        NOP
  KEY13: ADDI    $S0,$ZERO,0X77
        BNE     $S1,$S0,KEY16
        NOP
        ADDI    $V0,$ZERO,13
        J       KEYEXIT
        NOP
  KEY16: ADDI    $V0,$ZERO,0X0FF     #没有比较到对应的16进制数，输出0ffH
KEYEXIT: LW      $S1,0($SP)          #恢复$s0,$s1的值
        ADDI    $SP,$SP,4
        LW      $S0,0($SP)
        ADDI    $SP,$SP,4
        JR      $RA                 #子程序返回
        NOP

#异常处理程序，像溢出、break、syscall等会执行显示错误代码，E2
.TEXT 0X0170
        SW   $T9,0XFC04($ZERO)
        ADDI $S0,$ZERO,0X0E2
E2:     SW   $T9,0XFC50($ZERO)
        J    E2
        NOP


#中断处理程序，当cause[13:8]==6'b000011 或者 000001是执行interruptServer0
#casuse[13:8]==6'b000010执行interruptServer1
.TEXT 0X0180                        #剩余25条指令
    MFC0 $K1,$13,0
    ANDI $K1,$K1,0X0100
    BNE  $K1,$ZERO,_interruptServer0
    NOP
    J    _interruptServer1
    NOP


.DATA 0x0100
    update : .word 
 vKeyboard : .word 
   vSwitch : .word 
.TEXT 0x0200
_start:
SW $zero, 0xfc50($zero)                     
      ADDI                  $sp,                  $sp,                  -32
       JAL                _main
       NOP
      ADDI                  $sp,                  $sp,                   32
         J               _start
       NOP
_fib:
        SW                  $ra,               0($sp)
SW $zero, 0xfc50($zero)                     
      ADDI                  $t0,                $zero,                    1
        LW                  $s0,               8($sp)
       SLT                  $t1,                  $t0,                  $s0
       BEQ                  $t1,                $zero,                  _t4
       NOP
         J                  _t5
       NOP
_t4:
      ADDI                  $t2,                $zero,                    1
        LW                  $s0,               8($sp)
       BEQ                  $s0,                  $t2,                  _t1
       NOP
         J                  _t3
       NOP
_t1:
      ADDI                  $t3,                $zero,                    1
         J                  _t2
       NOP
_t3:
      ADDI                  $t3,                $zero,                    0
_t2:
        OR                  $v0,                $zero,                  $t3
        LW                  $ra,               0($sp)
        JR                  $ra
       NOP
_t5:
        LW                  $s0,               8($sp)
      ADDI                  $t4,                  $s0,                   -1
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t4,               8($sp)
       JAL                 _fib
       NOP
      ADDI                  $sp,                  $sp,                   12
        OR                  $t5,                  $v0,                $zero
        LW                  $s0,               8($sp)
      ADDI                  $t6,                  $s0,                   -2
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t6,               8($sp)
        SW                  $t5,              16($sp)
       JAL                 _fib
       NOP
      ADDI                  $sp,                  $sp,                   12
        OR                  $t0,                  $v0,                $zero
        LW                  $t1,               4($sp)
       ADD                  $t2,                  $t1,                  $t0
        OR                  $v0,                $zero,                  $t2
        LW                  $ra,               0($sp)
        JR                  $ra
       NOP
_quickSort:
        SW                  $ra,               0($sp)
SW $zero, 0xfc50($zero)                     
        LW                  $s0,              12($sp)
       ADD                  $s1,                $zero,                  $s0
        LW                  $s2,              16($sp)
       ADD                  $s3,                $zero,                  $s2
       ADD                  $t3,                  $s0,                  $s2
      ADDI                  $t4,                $zero,                    2
       DIV                  $t3,                  $t4
      MFLO                  $t5
        LW                  $s4,               8($sp)
       SLL                  $t7,                  $t5,                    2
       ADD                  $t7,                  $t7,                  $s4
        LW                  $t6,               0($t7)
       ADD                  $s5,                $zero,                  $t6
        SW                  $s1,              20($sp)
        SW                  $s3,              24($sp)
        SW                  $s5,              28($sp)
_t16:
SW $zero, 0xfc50($zero)                     
        LW                  $s0,              24($sp)
        LW                  $s1,              20($sp)
       SLT                  $t7,                  $s0,                  $s1
       BEQ                  $t7,                $zero,                 _t14
       NOP
         J                 _t15
       NOP
_t14:
_t8:
SW $zero, 0xfc50($zero)                     
        LW                  $s0,               8($sp)
        LW                  $s1,              20($sp)
       SLL                  $t9,                  $s1,                    2
       ADD                  $t9,                  $t9,                  $s0
        LW                  $t8,               0($t9)
        LW                  $s2,              28($sp)
       SLT                  $t9,                  $t8,                  $s2
       BNE                  $t9,                $zero,                  _t6
       NOP
         J                  _t7
       NOP
_t6:
        LW                  $s0,              20($sp)
      ADDI                  $t0,                  $s0,                    1
       ADD                  $s0,                $zero,                  $t0
        SW                  $s0,              20($sp)
         J                  _t8
       NOP
_t7:
_t11:
SW $zero, 0xfc50($zero)                     
        LW                  $s0,               8($sp)
        LW                  $s1,              24($sp)
       SLL                  $t2,                  $s1,                    2
       ADD                  $t2,                  $t2,                  $s0
        LW                  $t1,               0($t2)
        LW                  $s2,              28($sp)
       SLT                  $t2,                  $s2,                  $t1
       BNE                  $t2,                $zero,                  _t9
       NOP
         J                 _t10
       NOP
_t9:
        LW                  $s0,              24($sp)
      ADDI                  $t3,                  $s0,                   -1
       ADD                  $s0,                $zero,                  $t3
        SW                  $s0,              24($sp)
         J                 _t11
       NOP
_t10:
        LW                  $s0,              24($sp)
        LW                  $s1,              20($sp)
       SLT                  $t4,                  $s0,                  $s1
       BEQ                  $t4,                $zero,                 _t12
       NOP
         J                 _t13
       NOP
_t12:
        LW                  $s0,               8($sp)
        LW                  $s1,              20($sp)
       SLL                  $t6,                  $s1,                    2
       ADD                  $t6,                  $t6,                  $s0
        LW                  $t5,               0($t6)
       ADD                  $s2,                $zero,                  $t5
        LW                  $s3,              24($sp)
       SLL                  $t7,                  $s3,                    2
       ADD                  $t7,                  $t7,                  $s0
        LW                  $t6,               0($t7)
       SLL                  $t7,                  $s1,                    2
       ADD                  $t7,                  $t7,                  $s0
        SW                  $t6,               0($t7)
       SLL                  $t7,                  $s3,                    2
       ADD                  $t7,                  $t7,                  $s0
        SW                  $s2,               0($t7)
      ADDI                  $t7,                  $s1,                    1
       ADD                  $s1,                $zero,                  $t7
      ADDI                  $t8,                  $s3,                   -1
       ADD                  $s3,                $zero,                  $t8
        SW                  $s1,              20($sp)
        SW                  $s3,              24($sp)
_t13:
         J                 _t16
       NOP
_t15:
        LW                  $s0,              12($sp)
        LW                  $s1,              24($sp)
       SLT                  $t9,                  $s0,                  $s1
       BNE                  $t9,                $zero,                 _t17
       NOP
         J                 _t18
       NOP
_t17:
      ADDI                  $sp,                  $sp,                  -36
        LW                  $s0,              44($sp)
        SW                  $s0,               8($sp)
        LW                  $s1,              48($sp)
        SW                  $s1,              12($sp)
        LW                  $s2,              60($sp)
        SW                  $s2,              16($sp)
       JAL           _quickSort
       NOP
      ADDI                  $sp,                  $sp,                   36
_t18:
        LW                  $s0,              20($sp)
        LW                  $s1,              16($sp)
       SLT                  $t0,                  $s0,                  $s1
       BNE                  $t0,                $zero,                 _t19
       NOP
         J                 _t20
       NOP
_t19:
      ADDI                  $sp,                  $sp,                  -36
        LW                  $s0,              44($sp)
        SW                  $s0,               8($sp)
        LW                  $s1,              56($sp)
        SW                  $s1,              12($sp)
        LW                  $s2,              52($sp)
        SW                  $s2,              16($sp)
       JAL           _quickSort
       NOP
      ADDI                  $sp,                  $sp,                   36
_t20:
        LW                  $ra,               0($sp)
        JR                  $ra
       NOP
_interruptServer0:
      ADDI                  $sp,                  $sp,                  -24
        SW                  $ra,               0($sp)
        SW                  $v0,               4($sp)
        SW                  $s0,               8($sp)
        SW                  $s1,              12($sp)
        SW                  $t1,              16($sp)
        SW                  $t2,              20($sp)
        LW                  $s0,       vSwitch($zero)
      ANDI                  $t1,                  $s0,                    2
       BEQ                  $t1,                $zero,                 _t21
       NOP
         J                 _t22
       NOP
_t21:
        LW                  $s0,     vKeyboard($zero)
       SLL                  $t1,                  $s0,                    4
      ADDI                  $t2,                $zero,                -1008
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t2,               0($sp)
       JAL                _ttlw
       NOP
        LW                  $t2,               0($sp)
      ADDI                  $sp,                  $sp,                   12
       ADD                  $t2,                  $t1,                  $t2
       ADD                  $s0,                $zero,                  $t2
      ADDI                  $s1,                $zero,                    1
        SW                  $s0,     vKeyboard($zero)
        SW                  $s1,        update($zero)
_t22:
         J _tt_interruptServer0
       NOP
_tt_interruptServer0:
        LW                  $t2,              20($sp)
        LW                  $t1,              16($sp)
        LW                  $s1,              12($sp)
        LW                  $s0,               8($sp)
      ADDI                  $a0,                $zero,                    1
       JAL               0x00e0
       NOP
        LW                  $v0,               4($sp)
        LW                  $ra,               0($sp)
      ADDI                  $sp,                  $sp,                   24
      ERET                     
       NOP
_interruptServer1:
      ADDI                  $sp,                  $sp,                  -24
        SW                  $ra,               0($sp)
        SW                  $v0,               4($sp)
        SW                  $s0,               8($sp)
        SW                  $s1,              12($sp)
        SW                  $s2,              16($sp)
        SW                  $t2,              20($sp)
        LW                  $s0,       vSwitch($zero)
       ADD                  $s1,                $zero,                  $s0
      ADDI                  $t2,                $zero,                 -912
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t2,               0($sp)
       JAL                _ttlw
       NOP
        LW                  $t2,               0($sp)
      ADDI                  $sp,                  $sp,                   12
       ADD                  $s0,                $zero,                  $t2
       XOR                  $t2,                  $s1,                  $s0
      ANDI                  $t2,                  $t2,                    7
       ADD                  $s2,                $zero,                  $t2
      ADDI                  $t2,                $zero,                 -928
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t2,               0($sp)
        SW                  $s0,               4($sp)
       JAL                _ttsw
       NOP
      ADDI                  $sp,                  $sp,                   12
        SW                  $s2,        update($zero)
        SW                  $s0,       vSwitch($zero)
         J _tt_interruptServer1
       NOP
_tt_interruptServer1:
        LW                  $t2,              20($sp)
        LW                  $s2,              16($sp)
        LW                  $s1,              12($sp)
        LW                  $s0,               8($sp)
       JAL               0x00d0
       NOP
        LW                  $v0,               4($sp)
        LW                  $ra,               0($sp)
      ADDI                  $sp,                  $sp,                   24
      ERET                     
       NOP
_delay:
        SW                  $ra,               0($sp)
SW $zero, 0xfc50($zero)                     
       LUI                  $t2,                   15
       ORI                  $t1,                  $t2,                65535
       ADD                  $s0,                $zero,                  $t1
        SW                  $s0,               8($sp)
_t25:
SW $zero, 0xfc50($zero)                     
      ADDI                  $t3,                $zero,                    0
        LW                  $s0,               8($sp)
       BNE                  $s0,                  $t3,                 _t23
       NOP
         J                 _t24
       NOP
_t23:
        LW                  $s0,               8($sp)
      ADDI                  $t4,                  $s0,                   -1
       ADD                  $s0,                $zero,                  $t4
        SW                  $s0,               8($sp)
         J                 _t25
       NOP
_t24:
        LW                  $ra,               0($sp)
        JR                  $ra
       NOP
_main:
        SW                  $ra,               0($sp)
SW $zero, 0xfc50($zero)                     
      ADDI                  $t5,                $zero,                    1
      ADDI                  $t6,                $zero,                   32
      ADDI                  $s0,                  $sp,                    8
       SLL                  $t7,                  $t5,                    2
       ADD                  $t7,                  $t7,                  $s0
        SW                  $t6,               0($t7)
      ADDI                  $t7,                $zero,                    2
      ADDI                  $t8,                $zero,                   48
       SLL                  $t9,                  $t7,                    2
       ADD                  $t9,                  $t9,                  $s0
        SW                  $t8,               0($t9)
      ADDI                  $t9,                $zero,                    3
      ADDI                  $t0,                $zero,                   64
       SLL                  $t2,                  $t9,                    2
       ADD                  $t2,                  $t2,                  $s0
        SW                  $t0,               0($t2)
      ADDI                  $t2,                $zero,                    4
      ADDI                  $t1,                $zero,                   16
       SLL                  $t3,                  $t2,                    2
       ADD                  $t3,                  $t3,                  $s0
        SW                  $t1,               0($t3)
      ADDI                  $s1,                $zero,                    1
      ADDI                  $t3,                $zero,                 -912
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t3,               0($sp)
       JAL                _ttlw
       NOP
        LW                  $t4,               0($sp)
      ADDI                  $sp,                  $sp,                   12
       ADD                  $s2,                $zero,                  $t4
      ADDI                  $s3,                $zero,                    0
        SW                  $s1,        update($zero)
        SW                  $s2,       vSwitch($zero)
        SW                  $s3,     vKeyboard($zero)
_t41:
SW $zero, 0xfc50($zero)                     
      ADDI                  $t6,                $zero,                    1
       BEQ                  $t6,                $zero,                 _t40
       NOP
         J                 _t39
       NOP
_t39:
        LW                  $s0,        update($zero)
       BEQ                  $s0,                $zero,                 _t38
       NOP
         J                 _t37
       NOP
_t37:
        LW                  $s0,        update($zero)
      ANDI                  $t5,                  $s0,                    4
       BEQ                  $t5,                $zero,                 _t27
       NOP
         J                 _t26
       NOP
_t26:
      ADDI                  $t8,                $zero,                    0
      ADDI                  $t7,                $zero,                -1024
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t7,               0($sp)
        SW                  $t8,               4($sp)
       JAL                _ttsw
       NOP
      ADDI                  $sp,                  $sp,                   12
      ADDI                  $s0,                $zero,                    0
      ADDI                  $s1,                $zero,                    0
        SW                  $s0,     vKeyboard($zero)
        SW                  $s1,        update($zero)
         J                 _t41
       NOP
_t27:
        LW                  $s0,       vSwitch($zero)
      ANDI                  $t0,                  $s0,                    2
       BEQ                  $t0,                $zero,                 _t35
       NOP
         J                 _t34
       NOP
_t34:
        LW                  $s0,       vSwitch($zero)
      ANDI                  $t9,                  $s0,                    1
       BEQ                  $t9,                $zero,                 _t32
       NOP
         J                 _t31
       NOP
_t31:
      ADDI                  $sp,                  $sp,                  -12
        LW                  $s0,     vKeyboard($zero)
        SW                  $s0,               8($sp)
       JAL                 _fib
       NOP
      ADDI                  $sp,                  $sp,                   12
        OR                  $t1,                  $v0,                $zero
      ADDI                  $t2,                $zero,                -1024
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t2,               0($sp)
        SW                  $t1,               4($sp)
       JAL                _ttsw
       NOP
      ADDI                  $sp,                  $sp,                   12
         J                 _t33
       NOP
_t32:
      ADDI                  $t3,                $zero,                    0
        LW                  $s0,     vKeyboard($zero)
      ADDI                  $s1,                  $sp,                    8
       SLL                  $t4,                  $t3,                    2
       ADD                  $t4,                  $t4,                  $s1
        SW                  $s0,               0($t4)
      ADDI                  $t4,                $zero,                    0
      ADDI                  $t6,                $zero,                    4
      ADDI                  $sp,                  $sp,                  -36
        SW                  $s1,               8($sp)
        SW                  $t4,              12($sp)
        SW                  $t6,              16($sp)
       JAL           _quickSort
       NOP
      ADDI                  $sp,                  $sp,                   36
      ADDI                  $s0,                $zero,                    0
        SW                  $s0,              28($sp)
_t30:
SW $zero, 0xfc50($zero)                     
      ADDI                  $t5,                $zero,                    5
        LW                  $s0,              28($sp)
       SLT                  $t8,                  $s0,                  $t5
       BNE                  $t8,                $zero,                 _t28
       NOP
         J                 _t29
       NOP
_t28:
      ADDI                  $s0,                  $sp,                    8
        LW                  $s1,              28($sp)
       SLL                  $t0,                  $s1,                    2
       ADD                  $t0,                  $t0,                  $s0
        LW                  $t7,               0($t0)
      ADDI                  $t0,                $zero,                -1024
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t0,               0($sp)
        SW                  $t7,               4($sp)
       JAL                _ttsw
       NOP
      ADDI                  $sp,                  $sp,                   12
      ADDI                  $sp,                  $sp,                  -12
       JAL               _delay
       NOP
      ADDI                  $sp,                  $sp,                   12
        LW                  $s0,              28($sp)
      ADDI                  $t9,                  $s0,                    1
       ADD                  $s0,                $zero,                  $t9
        SW                  $s0,              28($sp)
         J                 _t30
       NOP
_t29:
_t33:
      ADDI                  $s0,                $zero,                    0
        SW                  $s0,     vKeyboard($zero)
         J                 _t36
       NOP
_t35:
      ADDI                  $t1,                $zero,                -1024
        LW                  $s0,     vKeyboard($zero)
      ADDI                  $sp,                  $sp,                  -12
        SW                  $t1,               0($sp)
        SW                  $s0,               4($sp)
       JAL                _ttsw
       NOP
      ADDI                  $sp,                  $sp,                   12
_t36:
      ADDI                  $s0,                $zero,                    0
        SW                  $s0,        update($zero)
_t38:
         J                 _t41
       NOP
_t40:
      ADDI                  $t2,                $zero,                    0
        OR                  $v0,                $zero,                  $t2
        LW                  $ra,               0($sp)
        JR                  $ra
       NOP
_ttlw:
        SW                  $v0,               4($sp)
        SW                  $ra,               8($sp)
        LW                  $a1,               0($sp)
      ADDI                  $a0,                $zero,               0xfc10
       BNE                  $a1,                  $a0,                 _tt1
       NOP
      ADDI                  $a0,                $zero,                    1
       JAL               0x00e0
       NOP
         J                 _tt2
       NOP
_tt1:
      ADDI                  $a0,                $zero,               0xfc70
       BNE                  $a1,                  $a0,                 _tt2
       NOP
       JAL               0x00d0
       NOP
_tt2:
        SW                  $v0,               0($sp)
        LW                  $v0,               4($sp)
        LW                  $ra,               8($sp)
        JR                  $ra
       NOP
_ttsw:
        SW                  $ra,               8($sp)
        LW                  $a3,               0($sp)
      ADDI                  $a1,                $zero,               0xfc00
       BNE                  $a1,                  $a3,                 _tt3
       NOP
      ADDI                  $a0,                $zero,                    0
        LW                  $a2,               4($sp)
      ADDI                  $a3,                $zero,                    0
       JAL               0x0040
       NOP
      ADDI                  $a0,                $zero,                    0
        LW                  $a2,               4($sp)
       SRL                  $a2,                  $a2,                   16
      ADDI                  $a3,                $zero,                    1
       JAL               0x0040
       NOP
         J                 _tt4
       NOP
_tt3:
      ADDI                  $a1,                $zero,               0xfc60
       BNE                  $a1,                  $a3,                 _tt4
       NOP
        LW                  $a0,               4($sp)
       JAL               0x00c0
       NOP
_tt4:
        LW                  $ra,               8($sp)
        JR                  $ra
       NOP
