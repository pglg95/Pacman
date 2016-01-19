.386

.MODEL FLAT, STDCALL

OPTION CASEMAP:NONE

INCLUDE \masm32\include\windows.inc
INCLUDE    \masm32\include\user32.inc
INCLUDE    \masm32\include\kernel32.inc
INCLUDE    \masm32\include\gdi32.inc
INCLUDE    \masm32\include\masm32.inc
INCLUDE    \masm32\include\winmm.inc
INCLUDELIB user32.lib
INCLUDELIB kernel32.lib
INCLUDELIB gdi32.lib
INCLUDELIB winmm.lib
INCLUDELIB \masm32\lib\masm32.lib



RGB MACRO red, green, blue
    mov eax, red or (green shl 8) or (blue shl 16)
ENDM

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
LevelDrawer PROTO 
Set PROTO :DWORD,:SDWORD,:DWORD
Get PROTO :DWORD,:SDWORD

GetMob PROTO :DWORD

LivesDrawer PROTO 
HeroControl PROTO
SetPositionOfHero PROTO :SBYTE,:BYTE,:BYTE
HitThePoint PROTO :SBYTE,:BYTE
HeroDrawer PROTO 
PrepareAnimationForHero PROTO
GameDrawer PROTO 
WindowDrawer PROTO
FinaliseRender PROTO :HWND
TickControl PROTO
LoadLevelFromRes PROTO
MobAndHeroDistance PROTO :BYTE,:BYTE
InitializeMobs PROTO :BYTE
PrepareAnimationForMob PROTO :BYTE,:BYTE
PlayMusic PROTO :BYTE
CleanMusic PROTO
Music PROTO
ScoreDrawer PROTO
ButtonDrawer PROTO
GameControl PROTO
Death PROTO
ZeroAditionalElementsInArray PROTO
SpecialPointDrawer PROTO
HitTheSpecialPoint PROTO
EatGhost PROTO
ZeroScoreBuf PROTO
Win PROTO
RestartGame PROTO
NearCross PROTO :BYTE,:BYTE,:BYTE
T0 PROTO
T1 PROTO
T2 PROTO
ToTarget PROTO :DWORD
InTarget PROTO :DWORD
MobControl2 PROTO
IsCross PROTO :BYTE,:BYTE,:BYTE,:BYTE,:BYTE
FirstWall PROTO :BYTE,:SBYTE,:SBYTE
ZeroInTarget PROTO

Pacman STRUCT
	    lives DB ?
		x SBYTE ?
		y SBYTE ?
		score DW ?
		animationFrame DB ?
		animationDirection DB ?
Pacman ENDS

Mob STRUCT
	typeOfMob DB ?
	x SBYTE ?
	y SBYTE ?
	animationFrame DB ?
Mob ENDS
ExtendedMob STRUCT
	isTarget DB ?
	tx SBYTE ?
	ty SBYTE ?
	dir DB ?
ExtendedMob ENDS

SetMob PROTO :DWORD,:Mob
SetEmob PROTO :DWORD,:ExtendedMob
.DATA

background1 DB "open " ,22h,"background.wav", 22h," type waveaudio alias b1",0
startbackground1 DB "play b1 repeat",0



ClassName DB "SimpleWinClass",0       
AppName   DB "Pacman",0
ButtonClassName DB "button",0
ButtonText      DB "Start gry",0
EditClassName   DB "edit",0
TestString      DB "cos do wpisania",0
messageboxtext DB "kliknales",0
messageboxhead DB "Okienko",0
textTypeName DB "Bitmap",0
textResName DB "IDB_BITMAP1",0
TestS DB "Score: "
death DB "death",0
array DB 629 dup(0) ;+4 dla punktow teleportu
data DB 626 dup(0)
GAMESTAT DB 0

MusicStat DB 1
MusicStatOld DB 1
PlayThisFrame DB 0
scoreBuf DB 4 dup(0)
MouseClick DB 0
timeOfBeingUnDeath DB 60
hittedPoints DW 0
pointsToHit DW 0
playingEatGhost DB 0
playingEatGhostMusic DB 0


;0-stan przed rozpoczeciem gry,wszystko gotowe
;1-stan aktywnej gry
;2-utrata zycia prze bohatera
;3-smierc bohatera,koniec gry
;4-tryb,zjadania mobow
;5-wygrana

hero Pacman <3,24,11,0,0,1>

key DB 0
tick DB 0
specialPointTick DB 0
eatGhostTickTime DB 0
eatMusicTickTime DB 0


.DATA?

hInstance   HINSTANCE ?               
hwndButton  HWND      ?
hwndEdit    HWND      ?
rect		RECT <?,?,?,?>
buffer      DB 512 DUP(?)
wall DD ?
sprites DD ?
startb DD ?
hMemDC DD ?
tempDC DD ?
hdc DD ?
black DD ?
mobs Mob 3 dup (<?,?,?,?>)
emobs ExtendedMob 3 dup (<?,?,?,?>)




.CONST
  
IDB_BITMAP1 EQU 116
IDB_BITMAP2 EQU 102
IDB_BITMAP3 EQU 103
IDB_BITMAP4 EQU 114
IDI_ICON2 EQU 101

ID_TIMER EQU 1
IDR_TEXTFILE1 EQU 104
TEXTFILE EQU 256
IDS_STRING106 EQU 106
IDR_WAVE1     EQU                  106
IDR_WAVE2       EQU                107
IDR_WAVE3       EQU                 108
IDR_WAVE4       EQU                 109
IDR_WAVE5         EQU               110
IDR_WAVE6        EQU                111
IDR_WAVE7         EQU               112
IDR_WAVE8         EQU               113
IDR_WAVE9         EQU               117
IDR_WAVE10        EQU               118
IDR_WAVE11       EQU               119
.CODE

start:
    INVOKE GetModuleHandle, NULL
    mov    hInstance, eax    
 
	INVOKE SetPositionOfHero,12,20,1

	   
    INVOKE WinMain, hInstance, NULL, 0, SW_SHOWDEFAULT
    INVOKE ExitProcess, eax
                
Get PROC row:DWORD, column:SDWORD
			.IF SBYTE ptr column==-1
				.IF row==11
					mov column,0
				.ELSEIF row==13
					mov column,1
				.ENDIF
					mov row,25
			.ELSEIF column==25
				.IF row==11
					mov column,2
				.ELSEIF row==13
					mov column,3
				.ENDIF
					mov row,25
			.ENDIF
				
			mov ecx,25
			mov eax,row
			mul ecx
			add eax,column
			mov al,array[eax]
			ret
Get ENDP

Set PROC row:DWORD,\
		 column:SDWORD,\ 
		 value:DWORD

			pushad

			.IF column==-1
				.IF row==11
					mov column,0
				.ELSEIF row==13
					mov column,1
				.ENDIF
					mov row,25
			.ELSEIF column==25
				.IF row==11
					mov column,2
				.ELSEIF row==13
					mov column,3
				.ENDIF
					mov row,25
			.ENDIF

			mov ecx,25
			mov eax,row
			mul ecx
			add eax,column
			mov ebx,value
			mov array[eax],bl
			popad
			ret
Set ENDP 
GetMob PROC i:DWORD
			mov ecx,8
			mov eax,i
			mul ecx
			mov ebx,emobs[eax]
			mov eax,mobs[eax]
			ret
GetMob ENDP
SetMob PROC i:DWORD,mb:Mob
	pushad
			mov ecx,8
			mov eax,i
			mul ecx
			mov ebx,mb
			mov mobs[eax],ebx
	popad
	ret
SetMob ENDP
SetEmob PROC i:DWORD,mb:ExtendedMob
	pushad
			mov ecx,8
			mov eax,i
			mul ecx
			mov ebx,mb
			mov emobs[eax],ebx
	popad
	ret
SetEmob ENDP
MobAndHeroDistance PROC x:BYTE,y:BYTE
LOCAL rx:BYTE
LOCAL ry:BYTE
LOCAL xm:BYTE
LOCAL ym:BYTE
	mov al,hero.x
	.IF x>al 
		mov al,x
		sub al,hero.x
		mov rx,al
		mov xm,1
	.ELSE
		sub al,x
		mov rx,al
		mov xm,3
	.ENDIF
	mov al,hero.y
	.IF y>al
		mov al,y
		sub al,hero.y
		mov ry,al
		mov ym,2
	.ELSE
		sub al,y
		mov ry,al
		mov ym,4
	.ENDIF
	mov al,xm
	mov ah,ym
	mov bl,rx
	mov bh,ry
	ret
MobAndHeroDistance ENDP

FirstWall PROC dir:BYTE,stx:SBYTE,sty:SBYTE
LOCAL i:SBYTE
	.IF dir==1
		mov al,stx
		mov i,al
		sub i,1
		.IF i<0
			mov al,i
			ret
		.ELSE
			INVOKE Get,sty,i
			.WHILE SBYTE ptr al!=1 && i>=0
				sub i,1
				.IF i>=0
					INVOKE Get,sty,i
				.ENDIF
			.ENDW
		.ENDIF
	.ELSEIF dir==2
		mov al,sty
		mov i,al
		sub i,1
		.IF i<0
			mov al,i
			ret
		.ELSE
			INVOKE Get,i,stx
			.WHILE SBYTE ptr al!=1 && i>=0
				sub i,1
				.IF i>=0
					INVOKE Get,i,stx
				.ENDIF
			.ENDW
		.ENDIF
	.ELSEIF dir==3
		mov al,stx
		mov i,al
		add i,1
		.IF i>24
			mov al,i
			ret
		.ELSE
			INVOKE Get,sty,i
			.WHILE SBYTE ptr al!=1 && i<=24
				add i,1
				.IF i<=24
					INVOKE Get,sty,i
				.ENDIF
			.ENDW
		.ENDIF
	.ELSE
		mov al,sty
		mov i,al
		add i,1
		.IF i>24
			mov al,i
			ret
		.ELSE
			INVOKE Get,i,stx
			.WHILE SBYTE ptr al!=1 && i<=24
				add i,1
				.IF i<=24
					INVOKE Get,i,stx
				.ENDIF
			.ENDW
		.ENDIF
	.ENDIF
	mov bl,i
	ret
FirstWall ENDP


T0 PROC  ;dla pierwszego moba
LOCAL m:Mob
LOCAL em:ExtendedMob
LOCAL i:BYTE
LOCAL ok:BYTE
pushad
	INVOKE GetMob,0
	mov m,eax
	mov em,ebx
	mov ok,0
	mov al,hero.y
	mov ah,hero.x
	.IF em.dir==1
		INVOKE FirstWall,em.dir,m.x,m.y
		.IF ah<m.x &&  ah> SBYTE ptr bl
			mov ok,1
		.ENDIF
	.ELSEIF em.dir==2
		INVOKE FirstWall,em.dir,m.x,m.y
		.IF al<m.y &&  al>SBYTE ptr bl
			mov ok,1
		.ENDIF
	.ELSEIF em.dir==3
		INVOKE FirstWall,em.dir,m.x,m.y
		.IF ah>m.x &&  ah<SBYTE ptr bl
			mov ok,1
		.ENDIF
	.ELSEIF em.dir==4
		.IF al>m.y &&  al< SBYTE ptr bl
			mov ok,1
		.ENDIF
	.ENDIF
	
	.IF em.dir==1 || em.dir==3
		.IF ok==1 && m.y==al
			mov em.isTarget,1
			mov em.tx,ah
			mov em.ty,al
		.ENDIF
	.ELSE
		.IF ok==1 && m.x==ah
			mov em.isTarget,1
			mov em.tx,ah
			mov em.ty,al
		.ENDIF
	.ENDIF
	INVOKE SetEmob,0,em
popad
ret
T0 ENDP
T1 PROC  ;dla drugiego moba
LOCAL m:Mob
LOCAL em:ExtendedMob
LOCAL i:BYTE
pushad
	INVOKE GetMob,1
	mov m,eax
	mov em,ebx
	mov al,hero.y
	mov ah,hero.x
	.IF em.dir==1 || em.dir==3
		INVOKE FirstWall,em.dir,m.x,m.y
		.IF m.y==al && ah>SBYTE ptr bl && em.dir==1
			mov em.isTarget,1
			mov em.tx,ah
			mov em.ty,al
		.ENDIF
		.IF m.y==al && ah<SBYTE ptr bl && em.dir==3
			mov em.isTarget,1
			mov em.tx,ah
			mov em.ty,al
		.ENDIF
	.ELSE
		INVOKE FirstWall,em.dir,m.x,m.y
		.IF m.x==ah && al>SBYTE ptr bl && em.dir==2
			mov em.isTarget,1
			mov em.tx,ah
			mov em.ty,al
		.ENDIF
		.IF m.x==ah && al<SBYTE ptr bl && em.dir==4
			mov em.isTarget,1
			mov em.tx,ah
			mov em.ty,al
		.ENDIF
	.ENDIF
	INVOKE SetEmob,1,em
popad
ret
T1 ENDP

ToTarget PROC a:DWORD
LOCAL m:Mob
LOCAL em:ExtendedMob
LOCAL w:BYTE
LOCAL n:BYTE
LOCAL e:BYTE
LOCAL s:BYTE
LOCAL wstop:BYTE
LOCAL nstop:BYTE
LOCAL estop:BYTE
LOCAL sstop:BYTE
LOCAL set:BYTE
LOCAL r:BYTE
pushad
	mov wstop,0
	mov nstop,0
	mov estop,0
	mov sstop,0
	mov set,0
	INVOKE GetMob,a
	mov m,eax
	mov em,ebx
	mov bl,m.x
	mov bh,m.y
	sub bl,1
	INVOKE Get,bh,bl
	mov w,al
	add bl,2
	INVOKE Get,bh,bl
	mov e,al
	sub bl,1
	sub bh,1
	INVOKE Get,bh,bl
	mov n,al
	add bh,2
	INVOKE Get,bh,bl
	mov s,al
	sub bh,1

	mov bl,m.x
	mov bh,m.y

	.IF m.x==0
		mov w,1
	.ENDIF
	.IF m.y==0
		mov n,1
	.ENDIF
	.IF m.x==24
		mov e,1
	.ENDIF
	.IF m.y==24
		mov s,1
	.ENDIF


	.IF em.dir==1 && w==1
		mov wstop,1
	.ELSEIF em.dir==2 && n==1
		mov nstop,1
	.ELSEIF em.dir==3 && e==1
		mov estop,1
	.ELSEIF em.dir==4 && s==1
		mov sstop,1
	.ENDIF
	
	.IF wstop==1 || nstop==1 || estop==1 || sstop==1
		.IF wstop==1
			.IF e!=1 && n==1 && s==1
				mov em.dir,3
				mov set,1
			.ENDIF
		.ELSEIF nstop==1
			.IF s!=1 && w==1 && e==1
				mov em.dir,4
				mov set,1
			.ENDIF
		.ELSEIF estop==1
			.IF w!=1 && n==1 && s==1
				mov em.dir,1
				mov set,1
			.ENDIF
		.ELSEIF sstop==1
			.IF n!=1 && w==1 && e==1
				mov em.dir,2
				mov set,1
			.ENDIF
		.ENDIF
		.IF set==0
			INVOKE nrandom,2
			mov r,al
			.IF wstop==1 || estop==1
				.IF r==0
					.IF n!=1
						mov em.dir,2
					.ELSE
						mov em.dir,4
					.ENDIF
				.ELSE 
					.IF s!=1
						mov em.dir,4
					.ELSE
						mov em.dir,2
					.ENDIF
				.ENDIF
			.ELSEIF nstop==1 || sstop==1
				.IF r==0
					.IF w!=1
						mov em.dir,1
					.ELSE
						mov em.dir,3
					.ENDIF
				.ELSE 
					.IF e!=1
						mov em.dir,3
					.ELSE
						mov em.dir,1
					.ENDIF
				.ENDIF
			.ENDIF
		.ENDIF
		.ELSE ;do pierwszego warunku
			mov set,0
			INVOKE IsCross,w,n,e,s,em.dir
			.IF al==1 ;jest skrzyzowanie
				.IF em.isTarget==1 ;jets ustalony cel
						mov bl,m.x
						mov bh,m.y
						.IF em.tx<bl
							.IF w!=1
								mov em.dir,1
								mov set,1
							.ENDIF
						.ELSEIF em.tx>bl
							.IF e!=1
								mov em.dir,3
								mov set,1
							.ENDIF
						.ENDIF
						.IF set==0 && em.ty<bh
							.IF n!=1
								mov em.dir,2
								mov set,1
							.ENDIF
						.ELSEIF set==0 && em.ty>bh
							.IF s!=1
								mov em.dir,4
								mov set,1
							.ENDIF
						.ENDIF
					.ELSE ;brak ustawionego celu
							INVOKE nrandom,2
							mov r,al
							.IF r==0 ;zmiana kierunkow
								INVOKE nrandom,2
								mov r,al
								.IF em.dir==1 || em.dir==3
									.IF r==0
										.IF n!=1
											mov em.dir,2
										.ELSE
											mov em.dir,4
										.ENDIF
									.ELSE 
										.IF s!=1
											mov em.dir,4
										.ELSE
											mov em.dir,2
										.ENDIF
									.ENDIF
								.ELSEIF em.dir==2 || em.dir==4
									.IF r==0
										.IF w!=1
											mov em.dir,1
										.ELSE
											mov em.dir,3
										.ENDIF
									.ELSE 
										.IF e!=1
											mov em.dir,3
										.ELSE
											mov em.dir,1
										.ENDIF
									.ENDIF
								.ENDIF
							 .ENDIF
						  .ENDIF
						.ENDIF
					 .ENDIF


	INVOKE SetMob,a,m
	INVOKE SetEmob,a,em
popad
ret
ToTarget ENDP


IsCross PROC w:BYTE,n:BYTE,e:BYTE,s:BYTE,dir:BYTE
	.IF dir==1 || dir==3
		.IF n!=1 || s!=1
			mov al,1
		.ELSE
			mov al,0
		.ENDIF
	.ELSEIF dir==2 || dir==4
		.IF w!=1 || e!=1
			mov al,1
		.ELSE
			mov al,0
		.ENDIF
	.ENDIF
	ret
IsCross ENDP


InTarget PROC a:DWORD
LOCAL m:Mob
LOCAL em:ExtendedMob
pushad
	INVOKE GetMob,a
	mov m,eax
	mov em,ebx
	mov bl,m.x
	mov bh,m.y
	.IF bl==em.tx && bh==em.ty
			mov	em.isTarget,0
	.ENDIF
	INVOKE SetEmob,a,em
popad
ret
InTarget ENDP
ZeroInTarget PROC
LOCAL em:ExtendedMob
LOCAL i:BYTE
pushad
	mov i,0
	.WHILE i<3
		INVOKE GetMob,i
		mov em,ebx
		mov em.isTarget,0
		INVOKE SetEmob,i,em
		add i,1
	.ENDW
popad
ret
ZeroInTarget ENDP
MobControl2 PROC
LOCAL i:BYTE
LOCAL m:Mob
LOCAL em:ExtendedMob
pushad
	mov i,0
	.IF GAMESTAT!=4
		INVOKE T0
		INVOKe T1
		INVOKe T2
	.ENDIF
	.WHILE i<3
		INVOKE InTarget,i
		INVOKE ToTarget,i
		INVOKE GetMob,i
		mov m,eax
		mov em,ebx
				.IF em.dir==1
					sub m.x,1 
				.ELSEIF em.dir==2 
					sub m.y,1
				.ELSEIF em.dir==3 
					add m.x,1
				.ELSEIF em.dir==4 
					add m.y,1
				.ENDIF
				INVOKE PrepareAnimationForMob,em.dir,m.animationFrame
				mov m.animationFrame,al
				INVOKE SetMob,i,m
				add i,1
		.ENDW
popad
ret
MobControl2 ENDP
T2 PROC
LOCAL m:Mob
LOCAL em:ExtendedMob
LOCAL i:BYTE
LOCAL cross:BYTE
LOCAL through:BYTE
LOCAL dis:BYTE
LOCAL br:BYTE
LOCAL dir:BYTE
pushad
	INVOKE GetMob,2
	mov m,eax
	mov em,ebx
	mov al,hero.y
	mov ah,hero.x
	mov dis,1
	mov br,0
	.IF em.dir==1 || em.dir==3 ;poziom
		.IF m.y==al
			mov em.isTarget,1
			mov em.tx,ah
			mov em.ty,al
		.ELSE
			INVOKE NearCross,m.x,m.y,1
			mov cross,al
			mov through,ah
			mov dir,bl
			mov al,hero.y
			mov ah,hero.x
			.IF through==0

				.IF dir==1
					.WHILE dis<4 && br==0
						mov bl,dis
						add bl,m.y
						.IF ah==cross && al==bl
							mov br,1
							mov em.isTarget,1
							mov em.tx,ah
							mov em.ty,al
						.ENDIF
						add dis,1
					.ENDW
				.ELSEIF dir==3
					.WHILE dis<4 && br==0
						mov bl,m.y
						sub bl,dis
						.IF ah==cross && al==bl
							mov br,1
							mov em.isTarget,1
							mov em.tx,ah
							mov em.ty,al
						.ENDIF
						add dis,1
					.ENDW
				.ENDIF
			.ENDIF
			.IF through==1
				.IF dir==1
					.WHILE dis<4 && br==0
						mov bl,m.y
						sub bl,dis
						.IF ah==cross && al==bl
							mov br,1
							mov em.isTarget,1
							mov em.tx,ah
							mov em.ty,al
						.ENDIF
						add dis,1
					.ENDW
				.ELSEIF dir==3
					.WHILE dis<4 && br==0
						mov bl,m.y
						add bl,dis
						.IF ah==cross && al==bl
							mov br,1
							mov em.isTarget,1
							mov em.tx,ah
							mov em.ty,al
						.ENDIF
						add dis,1
					.ENDW
				.ENDIF
			.ENDIF	
		.ENDIF
	.ELSE ;pion
		.IF m.x==ah
			mov em.isTarget,1
			mov em.tx,ah
			mov em.ty,al
		.ELSE
			INVOKE NearCross,m.x,m.y,2
			mov cross,al
			mov through,ah
			mov dir,bl
			mov al,hero.y
			mov ah,hero.x
			.IF through==0

				.IF dir==2
					.WHILE dis<4 && br==0
						mov bl,m.x
						add bl,dis
						.IF al==cross && ah==bl
							mov br,1
							mov em.isTarget,1
							mov em.tx,ah
							mov em.ty,al
						.ENDIF
						add dis,1
					.ENDW
				.ELSEIF dir==4
					.WHILE dis<4 && br==0
						mov bl,m.x
						sub bl,dis
						.IF al==cross && ah==bl
							mov br,1
							mov em.isTarget,1
							mov em.tx,ah
							mov em.ty,al
						.ENDIF
						add dis,1
					.ENDW
				.ENDIF
			.ENDIF
			.IF through==1
				.IF dir==2
					.WHILE dis<4 && br==0
						mov bl,m.x
						sub bl,dis
						.IF al==cross && ah==bl
							mov br,1
							mov em.isTarget,1
							mov em.tx,ah
							mov em.ty,al
						.ENDIF
						add dis,1
					.ENDW
				.ELSEIF dir==4
					.WHILE dis<4 && br==0
						mov bl,m.x
						add bl,dis
						.IF al==cross && ah==bl
							mov br,1
							mov em.isTarget,1
							mov em.tx,ah
							mov em.ty,al
						.ENDIF
						add dis,1
					.ENDW
				.ENDIF
			.ENDIF	
		.ENDIF
	.ENDIF
	INVOKE SetEmob,2,em
	popad
	ret
T2 ENDP
NearCross PROC x:BYTE,y:BYTE,dir:BYTE
LOCAL dis1:BYTE
LOCAL dis2:BYTE
LOCAL br:BYTE
LOCAL i:SBYTE
LOCAL yp:BYTE
LOCAL ym:BYTE
LOCAL s1:BYTE
LOCAL s2:BYTE
LOCAL through1:BYTE
LOCAL through2:BYTE
LOCAL cross1:BYTE
LOCAL cross2:BYTE
LOCAL cd1:BYTE
LOCAL cd2:BYTE
	mov al,x
	mov ah,y
	mov br,0
	mov through1,0
	mov through2,0
	mov dis1,0 ;max mpozliwe
	mov dis2,0 ;max mozliwe
	.IF dir==1 ;poziomo
		mov al,x
		mov ah,y
		mov i,al
		mov yp,ah
		mov ym,ah
		sub ym,1
		add yp,1
		.WHILE i>=0 && br==0
			INVOKE Get,yp,i
			mov s1,al
			INVOKE Get,ym,i
			mov s2,al
			.IF s1==0 || s2==0
				mov al,i
				mov cross1,al ;przeslanie wsp x
				.IF s1==0 && s2==0
					mov through1,1
				.ENDIF
				.IF s1==0
					mov cd1,2
				.ENDIF
				.IF s2==0
					mov cd1,4
				.ENDIF
				mov br,1
			.ENDIF
			add dis1,1
			sub i,1
		.ENDW
		mov br,0
		.WHILE i<=24 && br==0
			INVOKE Get,yp,i
			mov s1,al
			INVOKE Get,ym,i
			mov s2,al
			.IF s1==0 || s2==0
				mov al,i
				mov cross1,al ;przeslanie wsp x
				.IF s1==0 && s2==0
					mov through2,1
				.ENDIF
				.IF s1==0
					mov cd2,2
				.ENDIF
				.IF s2==0
					mov cd2,4
				.ENDIF
				mov br,1
			.ENDIF
			add dis2,1
			add i,1
		.ENDW
		mov al,dis1
		.IF al>=dis2
			mov al,cross1
			mov ah,through1
			mov bl,cd1
		.ELSE
			mov al,cross2
			mov ah,through2
			mov bl,cd2
		.ENDIF				
	.ELSE ;pionowo
		mov al,x
		mov ah,y
		mov i,ah
		mov yp,al
		mov ym,al
		sub ym,1
		add yp,1
		.WHILE i>=0 && br==0
			INVOKE Get,i,yp
			mov s1,al
			INVOKE Get,i,ym
			mov s2,al
			.IF s1==0 || s2==0
				mov al,i
				mov cross1,al ;przeslanie wsp y
				.IF s1==0 && s2==0
					mov through1,1
				.ENDIF
				.IF s1==0
					mov cd1,3
				.ENDIF
				.IF s1==0
					mov cd1,1
				.ENDIF
				mov br,1
			.ENDIF
			add dis1,1
			sub i,1
		.ENDW
		mov br,0
		.WHILE i<=24 && br==0
			INVOKE Get,i,yp
			mov s1,al
			INVOKE Get,i,ym
			mov s2,al
			.IF s1==0 || s2==0
				mov al,i
				mov cross1,al ;przeslanie wsp y
				.IF s1==0 && s2==0
					mov through2,1
				.ENDIF
				.IF s2==0
					mov cd2,3
				.ENDIF
				.IF s2==0
					mov cd2,1
				.ENDIF
				mov br,1
			.ENDIF
			add dis2,1
			add i,1
		.ENDW
		mov al,dis1
		.IF al>=dis2
			mov al,cross1
			mov ah,through1
			mov bl,cd1
		.ELSE
			mov al,cross2
			mov ah,through2
			mov bl,cd2
		.ENDIF				
	.ENDIF
ret
NearCross ENDP

InitializeMobs PROC a:BYTE
LOCAL i:BYTE
LOCAL m:Mob
LOCAL em:ExtendedMob
	pushad
	mov i,0
	.WHILE i<3
		mov al,i
		.IF al==a || a>2
			INVOKE GetMob,i
			mov m,eax
			mov em,ebx
			mov al,i
			mov m.typeOfMob,al
			add al,11
			mov m.x,al 
			mov m.y,12 
			mov m.animationFrame,0
			mov em.isTarget,0
			mov em.tx,0
			mov em.ty,0
			mov em.dir,2
	
			INVOKE Set,12,al,3
			INVOKE SetEmob,i,em
			INVOKE SetMob,i,m
		.ENDIF
		add i,1
	.ENDW
	popad
	ret
InitializeMobs ENDP
PrepareAnimationForMob PROC md:BYTE,an:BYTE
	mov al,an
	and al,1 ;parzysta czy nieparzysta
		.IF md==1 
			mov an,4
		.ELSEIF md==2 
			mov an,0
		.ELSEIF md==3 
			mov an,6
		.ELSEIF md==4 
			mov an,2
		.ENDIF
		.IF al==0
			add an,1
		.ENDIF
		mov al,an
	ret
PrepareAnimationForMob ENDP

MobDrawer PROC
LOCAL i:BYTE
LOCAL xs :WORD
LOCAL ys :WORD
LOCAL x :WORD
LOCAL y :WORD
LOCAL m:Mob
	pushad
		mov i,0
		.WHILE i<3
				INVOKE GetMob,i
				mov m,eax
				mov cl,m.x
				movsx cx,cl
				mov ax,20
				mul cx
				mov x,ax
				add x,38

				mov cl,m.y
				movsx cx,cl
				mov ax,20
				mul cx
				mov y,ax
				add y,38

			.IF GAMESTAT!=4
				mov cl,m.animationFrame
				movsx cx,cl
				mov ax,20
				mul cx
				add ax,3
				mov xs,ax

				mov cl,m.typeOfMob
				movsx cx,cl
				mov ax,20
				mul cx
				add ax,83
				mov ys,ax

				
			.ELSE
				mov cl,m.animationFrame
				and cl,1
				.IF cl==0
					mov xs,3
				.ELSE
					mov xs,23
				.ENDIF
				mov al,timeOfBeingUnDeath
				sub al,20
				.IF eatGhostTickTime>=al && specialPointTick==1
					add xs,40
				.ENDIF
				mov ys,163
			.ENDIF
				INVOKE BitBlt, hMemDC, x, y,14, 14, tempDC, xs, ys,SRCCOPY
				add i,1
			.ENDW
	popad
	ret
MobDrawer ENDP

LoadLevelFromRes PROC
LOCAL i:DWORD
LOCAL j :DWORD
	pushad
	INVOKE LoadString,hInstance,IDS_STRING106,ADDR data,626 ;+ znacznik konca

	mov i,0
	mov j,0
	.WHILE i<25 ;wiersze
		.WHILE j<25 ;kolumny
			mov ecx,25
			mov eax,i
			mul ecx
			add eax,j
			mov bl,data[eax]
			.IF bl==48
				.IF (i==0 && j==0) || (i==0 && j==24) || (i==24 && j==0) || (i==24 && j==24) || (i==14 && j==12)
					INVOKE Set,i,j,10
				.ELSE
					INVOKE Set,i,j,0
				.ENDIF
				add pointsToHit,1
			.ELSEIF bl==49
				INVOKE Set,i,j,1
			.ENDIF
			add j,1
		.ENDW
		add i,1
		mov j,0
	.ENDW
	popad
	ret
LoadLevelFromRes ENDP

HeroControl PROC 
LOCAL x:SBYTE
LOCAL y:BYTE
	pushad
	mov al,hero.x
	mov ah,hero.y
	.IF key==1 && tick!=1;lewo
		sub al,1
	.ELSEIF key==2  && tick!=1;gora
		sub ah,1
	.ELSEIF key==3 && tick!=1;prawo
		add al,1
	.ELSEIF key==4 && tick!=1;dol
		add ah,1
	.ELSEIF tick==1
		INVOKE PrepareAnimationForHero
		ret
	.ELSE
		ret
	.ENDIF
	mov x,al
	mov y,ah

	.IF (x<0 && (y==11 || y==13)) || (x>24 && (y==11 || y==13))
		INVOKE PrepareAnimationForHero
		.IF x<-1
				INVOKE SetPositionOfHero,25,y,0
		.ELSEIF x>25
				INVOKE SetPositionOfHero,-1,y,0
		.ELSE 
			INVOKE SetPositionOfHero,x,y,0
		.ENDIF
	.ENDIF

	.IF x>=0 && y>=0  && x<=24 && y<=24 		
	INVOKE Get,y,x
		.IF al!=1 ;nie sciana
			INVOKE PrepareAnimationForHero
			INVOKE SetPositionOfHero,x,y,0
		.ENDIF
	.ENDIF
	popad
	ret
HeroControl ENDP
TickControl PROC
	pushad
	mov al,tick
	add al,1
	.IF al>2
		mov tick,0
	.ELSE
		mov tick,al
	.ENDIF

	mov al,playingEatGhostMusic
	add al,1
	.IF al>5
		mov playingEatGhostMusic,0
	.ELSE
		mov playingEatGhostMusic,al
	.ENDIF

	mov al,specialPointTick
	add al,1
	.IF al>1
		mov specialPointTick,0
	.ELSE
		mov specialPointTick,al
	.ENDIF

	.IF GAMESTAT==4
		mov al,eatGhostTickTime
		add al,1
		.IF al>timeOfBeingUnDeath
			mov eatGhostTickTime,0
			mov GAMESTAT,2
		.ELSE
			mov eatGhostTickTime,al
		.ENDIF
	.ENDIF

	popad
	ret
TickControl ENDP
PrepareAnimationForHero PROC
	pushad
	.IF hero.animationFrame==0
		mov hero.animationFrame,1
	.ELSE
		mov hero.animationFrame,0
	.ENDIF
	;zmiana oznaczen ze wzgledu na kolejnosc w pliku ze sprite'ami
	mov al,key
	.IF key==1 ;lewo
		mov al,0
	.ELSEIF key==3 ;prawo
		mov al,1
	.ELSEIF key==4 ;dol
		mov al,3
	.ENDIF
	mov hero.animationDirection,al
	popad
	ret
PrepareAnimationForHero ENDP

SetPositionOfHero PROC x:SBYTE,y:BYTE,s:BYTE
LOCAL xold:SBYTE
LOCAL yold:BYTE
	pushad
		mov al,hero.x
		mov ah,hero.y
		mov xold,al
		mov yold,ah
		.IF s==0
			INVOKE Set,yold,xold,4 ;pole bez punktu na bylej pozycji
			INVOKE Get,y,x
				.IF al==0 ;jest punkt
					INVOKE HitThePoint,x,y
				.ELSEIF al==10
					INVOKE HitTheSpecialPoint
				.ENDIF
		.ELSE
			mov hero.animationFrame,0
			mov hero.animationDirection,0
		.ENDIF

		INVOKE Set,y,x,2 ;nowa pozycja bohatera
		mov al,x
		mov ah,y
		mov hero.y,ah
		mov hero.x,al
	popad
	ret
SetPositionOfHero ENDP
HitTheSpecialPoint PROC
	pushad
		mov GAMESTAT,4
		mov eatGhostTickTime,0
		add hittedPoints,1
		INVOKE ZeroInTarget
	popad
	ret
HitTheSpecialPoint ENDP
HeroDrawer PROC 
LOCAL xs :WORD
LOCAL ys :WORD
LOCAL x :WORD
LOCAL y :WORD
	pushad
				mov cl,hero.x
				movsx cx,cl
				
				mov ax,20
				mul cx
				mov x,ax
				add x,38

				mov cl,hero.y
				movsx cx,cl
		
				mov ax,20
				mul cx
				mov y,ax
				add y,38


				mov cl,hero.animationFrame
				movsx cx,cl
				
				mov ax,20
				mul cx
				add ax,3
				mov xs,ax

				mov cl,hero.animationDirection
				movsx cx,cl
			
				mov ax,20
				mul cx
				add ax,3
				mov ys,ax

				INVOKE BitBlt, hMemDC, x, y,14, 14, tempDC, xs, ys,SRCCOPY

	popad
	ret
HeroDrawer ENDP

HitThePoint PROC x:SBYTE,y:BYTE
	INVOKE PlayMusic,1
	add hero.score,1
	add hittedPoints,1
	ret
HitThePoint ENDP

LivesDrawer PROC 
LOCAL a:BYTE
	pushad
	mov al,hero.lives
	sub al,1
	mov a,al
	.IF a > 0
		INVOKE BitBlt, hMemDC, 609, 12, 33, 34, tempDC, 281, 41,SRCCOPY
		.IF a > 1
			INVOKE BitBlt, hMemDC, 654, 12, 33, 34, tempDC, 281, 41,SRCCOPY
			.IF a >2
				INVOKE BitBlt, hMemDC, 699, 12, 33, 34, tempDC, 281, 41,SRCCOPY
			.ENDIF
		.ENDIF
	.ENDIF
	popad
	ret
LivesDrawer ENDP
 
PointDrawer PROC 
LOCAL i :SDWORD
LOCAL j :SDWORD
LOCAL x :SDWORD
LOCAL y :SDWORD
	pushad
	mov i,0
	mov j,0
	.WHILE i<25
		.While j<=25
			push i
			push j
			INVOKE Get,j,i
			.IF al==0
					.IF  j==25
						.IF i==0
							mov i,-1
							mov j,11
						.ELSEIF i==1
							mov i,-1
							mov j,13
						.ELSEIF i==2
							mov i,25
							mov j,11
						.ELSEIF i==3
							mov i,25
							mov j,13
						.ENDIF
					.ENDIF
						
				mov ecx,j
				mov eax,20
				mul ecx
				mov y,eax
				add y,38
				mov ecx,i
				mov eax,20
				mul ecx
				mov x,eax
				add x,38
				INVOKE BitBlt, hMemDC, x, y,8, 8, tempDC, 12, 181,SRCCOPY
			.ENDIF
			pop j
			pop i
		add j,1
		.ENDW
		mov j,0
		add i,1
	.ENDW

	mov i,0
	mov j,0

	popad
	ret
PointDrawer ENDP
SpecialPointDrawer PROC
LOCAL i :DWORD ;kolumna
LOCAL j :DWORD ;wiersz
LOCAL x :DWORD
LOCAL y :DWORD
	pushad
	mov i,0
	mov j,0
		.WHILE i<25
			.WHILE j<25
				mov ecx,j
				mov eax,20
				mul ecx
				mov y,eax
				add y,38
				mov ecx,i
				mov eax,20
				mul ecx
				mov x,eax
				add x,38
				INVOKE Get,j,i
				.IF specialPointTick==0 && al==10
					INVOKE BitBlt, hMemDC, x, y,8, 8, tempDC, 2, 182,SRCCOPY
				.ENDIF
			 add j,1
			.ENDW
			mov j,0
		 add i,1
		.ENDW
popad
ret
SpecialPointDrawer ENDP
           
LevelDrawer PROC 
	;0-pole wolne z punktem 4-pole bez punktu 1-sciana 2-bohater 3-wrog
LOCAL i :DWORD
LOCAL j :DWORD
LOCAL x :DWORD
LOCAL y :DWORD
	pushad
	mov i,0
	mov j,0
	.WHILE i<25
		.While j<25
			INVOKE Get,j,i
			.IF al==1 ;rysuj scianke
				mov ecx,j
				mov eax,20
				mul ecx
				mov y,eax
				add y,32
				mov ecx,i
				mov eax,20
				mul ecx
				mov x,eax
				add x,32
				INVOKE BitBlt, hMemDC, x, y, rect.right, rect.bottom, tempDC, 0, 0,SRCCOPY
			.ENDIF
		add j,1
		.ENDW
		mov j,0
		add i,1
	.ENDW
	popad
	ret
LevelDrawer ENDP

Music PROC
	pushad
	mov al,MusicStat
	.IF al!=MusicStatOld
		.IF al==1;jedzenie
			INVOKE PlaySound,IDR_WAVE4, hInstance, SND_RESOURCE or SND_ASYNC or SND_LOOP 
		.ELSEIF al==0 ;tlo rutyny gry
			INVOKE PlaySound,IDR_WAVE11, hInstance, SND_RESOURCE or SND_ASYNC or SND_LOOP 
		.ELSEIF al==2 ;tlo niesmiertelnosci
			INVOKE PlaySound,IDR_WAVE6, hInstance, SND_RESOURCE or SND_ASYNC or SND_LOOP
		.ELSEIF al==3 ;jedzenie ducha
			INVOKE PlaySound,IDR_WAVE3, hInstance, SND_RESOURCE or SND_ASYNC or SND_LOOP
			mov MusicStatOld,3
		.ENDIF
	.ENDIF
	popad
	ret	
Music ENDP
PlayMusic PROC a:BYTE
	pushad
	.IF playingEatGhost!=1
		mov al,MusicStat
		mov MusicStatOld,al
		mov al,a
		mov MusicStat,al
		mov PlayThisFrame,1
	.ENDIF
	.IF playingEatGhost==1 && playingEatGhostMusic==5
		mov playingEatGhost,0
	.ENDIF
	popad
	ret
PlayMusic ENDP
CleanMusic PROC
	.IF PlayThisFrame==0
		.IF GAMESTAT==2 ;rutyna gry
			INVOKE PlayMusic,0
		.ELSEIF GAMESTAT==4 ;tryb niesmiertelnosci
			INVOKE PlayMusic,2
		.ENDIF
	.ENDIF
	mov PlayThisFrame,0
	ret
CleanMusic ENDP
		
WinMain PROC hInst:     HINSTANCE,\
             hPrevInst: HINSTANCE,\
             CmdLine:   LPSTR,\
             CmdShow:   DWORD

LOCAL wc:   WNDCLASSEX
LOCAL msg:  MSG
LOCAL hwnd: HWND
    mov    wc.cbSize, SIZEOF WNDCLASSEX
    mov    wc.style, CS_HREDRAW or CS_VREDRAW
    mov    wc.lpfnWndProc, OFFSET WndProc
    mov    wc.cbClsExtra, NULL
    mov    wc.cbWndExtra, NULL
    push   hInstance
    pop    wc.hInstance
    mov    wc.hbrBackground, COLOR_WINDOW+1
    mov    wc.lpszMenuName, NULL
    mov    wc.lpszClassName, OFFSET ClassName
    INVOKE LoadIcon, hInst, IDI_ICON2
    mov    wc.hIcon, eax
    mov    wc.hIconSm, eax
    INVOKE LoadCursor,NULL, IDC_ARROW
    mov    wc.hCursor, eax
    INVOKE RegisterClassEx, ADDR wc
    INVOKE CreateWindowEx, NULL,\
                           ADDR ClassName,\
                           ADDR AppName,\
                           WS_BORDER or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,\
                           CW_USEDEFAULT,\
                           CW_USEDEFAULT,\
                           800,\
                           600,\
                           NULL,\
                           NULL,\
                           hInst,\
                           NULL
    mov    hwnd, eax
    INVOKE ShowWindow, hwnd, CmdShow
    INVOKE UpdateWindow, hwnd

    .WHILE TRUE
        INVOKE GetMessage, ADDR msg, NULL, 0, 0
        .BREAK .IF (!eax)
        INVOKE TranslateMessage, ADDR msg
        INVOKE DispatchMessage, ADDR msg
    .ENDW

    mov eax, msg.wParam 
    ret

WinMain ENDP

WindowDrawer PROC 
LOCAL pedzelszary :HBRUSH
LOCAL box :HBRUSH
LOCAL box2 :HPEN
LOCAL olowekszary :HPEN
LOCAL i :DWORD
LOCAL j:DWORD
LOCAL ml :DWORD
LOCal ml2 :DWORD
	pushad
        INVOKE CreateSolidBrush, 00000000h
        mov pedzelszary,eax
   
        INVOKE SelectObject,hMemDC,pedzelszary
        mov box,eax
     
        INVOKE Rectangle,hMemDC, 0, 0, rect.right, rect.bottom
		INVOKE CreatePen,PS_DOT, 1, 00FFFFFFh
        mov olowekszary,eax
		INVOKE SelectObject,hMemDC,olowekszary
        mov box2,eax
		INVOKE MoveToEx,hMemDC ,562, 0,NULL
		INVOKE LineTo, hMemDC, 562, rect.bottom
		

		INVOKE SelectObject,tempDC,wall
		
		mov i,0
		mov j,0
		.WHILE j < 27 ;wiersze
				mov ecx,j
				mov eax,20
				mul ecx
				mov ml2,eax
				add ml2,12
			.WHILE i < 27 ;kolumny
				mov ecx,i
				mov eax,20
				mul ecx
				mov ml,eax
				add ml,12
				.IF j!=0 && j!=26 && j!=12 && j!=14
					.IF i==0 || i==26
					INVOKE BitBlt,hMemDC , ml, ml2, rect.right, rect.bottom, tempDC, 0, 0,SRCCOPY
					.ENDIF
				.ELSE
					.IF j==0 || j==26
						INVOKE BitBlt, hMemDC, ml, ml2, rect.right, rect.bottom, tempDC, 0, 0,SRCCOPY
					.ENDIF
				.ENDIF
				add i,1
			.ENDW
			mov i,0
			add j,1
		.ENDW
		
		INVOKE LevelDrawer
      

        INVOKE DeleteObject,olowekszary
        INVOKE DeleteObject,pedzelszary
	popad
	ret
WindowDrawer ENDP
ZeroScoreBuf PROC
LOCAL i:DWORD
	pushad
		mov i,0
		.WHILE i<4
			mov eax,i
			mov scoreBuf[eax],0
			add i,1
		.ENDW
	popad
	ret
ZeroScoreBuf ENDP
ScoreDrawer PROC
LOCAL a:BYTE 
	pushad
	    RGB    255,255,255
        INVOKE SetTextColor, hMemDC, eax
        RGB    0,0,0
        INVOKE SetBkColor, hMemDC, eax
        INVOKE TextOut, hMemDC, 580, 60, ADDR TestS, SIZEOF TestS
		xor eax,eax
		mov ax,hero.score
		cwde
		INVOKE dwtoa,eax,ADDR scoreBuf
		INVOKE TextOut, hMemDC, 700, 60, ADDR scoreBuf, SIZEOF scoreBuf
	popad
	ret
ScoreDrawer ENDP
GameDrawer PROC 
		pushad
		INVOKE SelectObject,tempDC,sprites
		INVOKE LivesDrawer
		INVOKE PointDrawer
		INVOKE SpecialPointDrawer
		INVOKE HeroDrawer
		INVOKE MobDrawer
		INVOKE ScoreDrawer
		popad
		ret
GameDrawer ENDP
ButtonDrawer PROC
	pushad
	INVOKE SelectObject,tempDC,startb
	INVOKE BitBlt,hMemDC ,580 ,120 , 191, 30, tempDC, 0, 0,SRCCOPY
	popad
	ret
ButtonDrawer ENDP

FinaliseRender PROC hWnd:HWND
LOCAL hbmBufOld: HBITMAP
LOCAL hbmBuf: HBITMAP
LOCAL hbmOld :HBITMAP
LOCAL eff: HBRUSH
	pushad
		INVOKE CreateCompatibleDC, hdc
		mov    hMemDC, eax

		INVOKE CreateCompatibleBitmap ,hdc, rect.right, rect.bottom
		mov hbmBuf,eax
		INVOKE SelectObject,hMemDC,hbmBuf
		mov hbmBufOld,eax

		INVOKE CreateCompatibleDC, hdc
		mov    tempDC, eax
	

		INVOKE GetStockObject,BLACK_BRUSH
		mov eff,eax
		INVOKE FillRect, hMemDC, ADDR rect,eff

		INVOKE WindowDrawer
		INVOKE GameDrawer
		.IF GAMESTAT==0
			INVOKE ButtonDrawer
		.ENDIF

		INVOKE BitBlt,hdc, 0, 0, rect.right, rect.bottom, hMemDC, 0, 0,SRCCOPY

		INVOKE SelectObject,tempDC,hbmOld
		INVOKE DeleteDC, tempDC

		INVOKE SelectObject,hMemDC,hbmBufOld
		INVOKE DeleteDC, hMemDC

		INVOKE DeleteObject,hbmBuf
	popad
	ret
FinaliseRender ENDP
ZeroAditionalElementsInArray PROC
LOCAL i:DWORD
	pushad
	mov i,625
	.WHILE i<629
		mov eax,i
		mov bl,0
		mov array[eax],bl
		add i,1
	.ENDW
	popad
	ret
ZeroAditionalElementsInArray ENDP
GameControl PROC
	pushad
	.IF GAMESTAT==0 ;uaktywnij przycisk
		.IF MouseClick==1
			mov GAMESTAT,1
		.ENDIF
	.ELSEIF GAMESTAT==1 ;nacisniecie przycisk odegranie dzwieku
		INVOKE PlaySound,IDR_WAVE9, hInstance, SND_RESOURCE
		mov GAMESTAT,2
		
	.ELSEIF GAMESTAT==2 || GAMESTAT==4;rutyna gry lub tryb niesmiertelnosci
		INVOKE Win
		INVOKE Death
		.IF GAMESTAT!=0 && GAMESTAT!=3
			INVOKE TickControl
			INVOKE HeroControl
			INVOKE MobControl2
			INVOKE EatGhost
		.ENDIF
		
	
			
	.ELSEIF GAMESTAT==3 ;utrata zycia
		.IF hero.lives>1
			sub hero.lives,1 ;utrata zycia
			INVOKE PlaySound,IDR_WAVE5, hInstance, SND_RESOURCE
			INVOKE SetPositionOfHero,12,20,1
			mov GAMESTAT,2
			INVOKE InitializeMobs,3
			mov MusicStat,1
			mov key,0
		.ELSE ;smierc
			INVOKE PlaySound,IDR_WAVE1, hInstance, SND_RESOURCE
			INVOKE RestartGame
	
		.ENDIF
	.ENDIF
	popad
	ret
GameControl ENDP
Death PROC
LOCAL i:BYTE
LOCAL b:BYTE
LOCAL m:Mob
	pushad
	.IF GAMESTAT==4
		popad
		ret
	.ENDIF
	mov b,0
	mov i,0
	.WHILE i<3 && b==0
		INVOKE GetMob,i
		mov m,eax
		mov al,m.x
		mov ah,m.y
		.IF hero.x==al && hero.y==ah
			mov GAMESTAT,3 ;smierc
			mov b,1
		.ENDIF
		add i,1
	.ENDW
	popad
	ret
Death ENDP
RestartGame PROC
pushad
			mov GAMESTAT,0
			INVOKE LoadLevelFromRes
			INVOKE InitializeMobs,3
			INVOKE SetPositionOfHero,12,20,1
			mov hero.lives,3
			mov hero.score,0
			mov MouseClick,0
			mov MusicStat,1
			mov key,0
			mov PlayThisFrame,0
			mov MusicStatOld,1
			INVOKE ZeroAditionalElementsInArray
			mov specialPointTick,0
			INVOKE ZeroScoreBuf
popad
ret
RestartGame ENDP
EatGhost PROC
LOCAL i:BYTE
LOCAL m:Mob
pushad
	.IF GAMESTAT==2
		popad
		ret
	.ENDIF
	mov i,0
	.WHILE i<3
		INVOKE GetMob,i
		mov m,eax
		mov al,m.x
		mov ah,m.y
		.IF hero.x==al && hero.y==ah
			INVOKE PlayMusic,3
			mov playingEatGhost,1
			mov playingEatGhostMusic,0
			add hero.score,200
			INVOKE InitializeMobs,i			
		.ENDIF
		add i,1
	.ENDW
popad
ret
EatGhost ENDP
Win PROC
	pushad
		mov ax,hittedPoints
		.IF ax==pointsToHit
			INVOKE PlaySound,IDR_WAVE10, hInstance, SND_RESOURCE
			INVOKE RestartGame
		.ENDIF
	popad
	ret
Win ENDP

WndProc PROC hWnd:   HWND, uMsg:   UINT, wParam: WPARAM, lParam: LPARAM 




LOCAL ps: PAINTSTRUCT
LOCAL i :DWORD
LOCAL s:BYTE
LOCAL j:DWORD



    .IF uMsg==WM_CREATE
		INVOKE LoadBitmap, hInstance, IDB_BITMAP1
        mov    wall, eax
		INVOKE LoadBitmap, hInstance, IDB_BITMAP3
		mov    sprites, eax
		INVOKE LoadBitmap, hInstance, IDB_BITMAP4
		mov    startb, eax
		INVOKE LoadBitmap, hInstance, IDB_BITMAP2
		mov    black, eax
		INVOKE SetTimer, hWnd,ID_TIMER,100,NULL
		INVOKE LoadLevelFromRes
		INVOKE InitializeMobs,3
		INVOKE GetTickCount
		INVOKE nseed, eax
		

   .ELSEIF uMsg==WM_PAINT
		
       INVOKE BeginPaint, hWnd, ADDR ps
		
		INVOKE FinaliseRender,hWnd
		
		

       INVOKE EndPaint, hWnd, ADDR ps
        
	.ELSEIF uMsg==WM_TIMER

		INVOKE GetDC,hWnd
		mov hdc,eax
		INVOKE GetClientRect, hWnd, ADDR rect
		INVOKE GameControl
		INVOKE FinaliseRender,hWnd
		INVOKE CleanMusic
		INVOKE Music
		INVOKE ReleaseDC,hWnd, hdc
	 .ELSEIF uMsg==WM_KEYDOWN
		.IF wParam==VK_LEFT
			mov key,1
		.ELSEIF wParam==VK_UP
			mov key,2
		.ELSEIF wParam==VK_RIGHT
			mov key,3
		.ELSEIF wParam==VK_DOWN
			mov key,4
		.ENDIF
	.ELSEIF uMsg==WM_LBUTTONDOWN
        mov    eax, lParam
        .IF ax>=580 && ax<=771
			shr eax,16
			.IF ax>=120 && ax<=150
				 mov    MouseClick, 1
			.ENDIF
		.ENDIF
     .ELSEIF uMsg==WM_DESTROY
        INVOKE PostQuitMessage, NULL
		INVOKE PlaySound,NULL, hInstance, SND_RESOURCE or SND_ASYNC
		INVOKE KillTimer,hWnd, ID_TIMER
    .ELSE
        INVOKE DefWindowProc, hWnd, uMsg, wParam, lParam
        ret 
    .ENDIF 

    xor eax, eax 
    ret 

WndProc ENDP 

END start  