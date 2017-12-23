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
