#ifndef CLIB_INTUITION_PROTOS_H
#define CLIB_INTUITION_PROTOS_H


/*
**	$VER: intuition_protos.h 34.106 (03.10.2019)
**
**	C prototypes. For use with 32 bit integers only.
**
**	Copyright © 2019 
**	All Rights Reserved
*/

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef  INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

/* --- Flags requested at OpenWindow() time by the application --------- */
#define WFLG_SIZEGADGET	    0x00000001L	/* include sizing system-gadget? */
#define WFLG_DRAGBAR	    0x00000002L	/* include dragging system-gadget? */
#define WFLG_DEPTHGADGET    0x00000004L	/* include depth arrangement gadget? */
#define WFLG_CLOSEGADGET    0x00000008L	/* include close-box system-gadget? */

#define WFLG_SIZEBRIGHT	    0x00000010L	/* size gadget uses right border */
#define WFLG_SIZEBBOTTOM    0x00000020L	/* size gadget uses bottom border */

/* --- refresh modes ------------------------------------------------------ */
/* combinations of the WFLG_REFRESHBITS select the refresh type */
#define WFLG_REFRESHBITS    0x000000C0L
#define WFLG_SMART_REFRESH  0x00000000L
#define WFLG_SIMPLE_REFRESH 0x00000040L
#define WFLG_SUPER_BITMAP   0x00000080L
#define WFLG_OTHER_REFRESH  0x000000C0L

#define WFLG_BACKDROP	    0x00000100L	/* this is a backdrop window */

#define WFLG_REPORTMOUSE    0x00000200L	/* to hear about every mouse move */

#define WFLG_GIMMEZEROZERO  0x00000400L	/* a GimmeZeroZero window	*/

#define WFLG_BORDERLESS	    0x00000800L	/* to get a Window sans border */

#define WFLG_ACTIVATE	    0x00001000L	/* when Window opens, it's Active */

/* --- Other User Flags --------------------------------------------------- */
#define WFLG_RMBTRAP	    0x00010000L	/* Catch RMB events for your own */
#define WFLG_NOCAREREFRESH  0x00020000L	/* not to be bothered with REFRESH */

/* - V36 new Flags which the programmer may specify in NewWindow.Flags	*/
#define WFLG_NW_EXTENDED    0x00040000L	/* extension data provided	*/
					/* see struct ExtNewWindow	*/

/* - V39 new Flags which the programmer may specify in NewWindow.Flags	*/
#define WFLG_NEWLOOKMENUS   0x00200000L	/* window has NewLook menus	*/


/* These flags are set only by Intuition.  YOU MAY NOT SET THEM YOURSELF! */
#define WFLG_WINDOWACTIVE   0x00002000L	/* this window is the active one */
#define WFLG_INREQUEST	    0x00004000L	/* this window is in request mode */
#define WFLG_MENUSTATE	    0x00008000L	/* Window is active with Menus on */
#define WFLG_WINDOWREFRESH  0x01000000L	/* Window is currently refreshing */
#define WFLG_WBENCHWINDOW   0x02000000L	/* WorkBench tool ONLY Window */
#define WFLG_WINDOWTICKED   0x04000000L	/* only one timer tick at a time */

/* V36 and higher flags to be set only by Intuition: */
#define WFLG_VISITOR	    0x08000000L	/* visitor window		*/
#define WFLG_ZOOMED	    0x10000000L	/* identifies "zoom state"	*/
#define WFLG_HASZOOM	    0x20000000L	/* window has a zoom gadget	*/


/* --- Other Window Values ---------------------------------------------- */
#define DEFAULTMOUSEQUEUE	(5)	/* no more mouse messages	*/

/* --- IDCMP Classes ------------------------------------------------------ */
/* Please refer to the Autodoc for OpenWindow() and to the Rom Kernel
 * Manual for full details on the IDCMP classes.
 */
#define IDCMP_SIZEVERIFY	0x00000001L
#define IDCMP_NEWSIZE		0x00000002L
#define IDCMP_REFRESHWINDOW	0x00000004L
#define IDCMP_MOUSEBUTTONS	0x00000008L
#define IDCMP_MOUSEMOVE		0x00000010L
#define IDCMP_GADGETDOWN	0x00000020L
#define IDCMP_GADGETUP		0x00000040L
#define IDCMP_REQSET		0x00000080L
#define IDCMP_MENUPICK		0x00000100L
#define IDCMP_CLOSEWINDOW	0x00000200L
#define IDCMP_RAWKEY		0x00000400L
#define IDCMP_REQVERIFY		0x00000800L
#define IDCMP_REQCLEAR		0x00001000L
#define IDCMP_MENUVERIFY	0x00002000L
#define IDCMP_NEWPREFS		0x00004000L
#define IDCMP_DISKINSERTED	0x00008000L
#define IDCMP_DISKREMOVED	0x00010000L
#define IDCMP_WBENCHMESSAGE	0x00020000L  /*	System use only		*/
#define IDCMP_ACTIVEWINDOW	0x00040000L
#define IDCMP_INACTIVEWINDOW	0x00080000L
#define IDCMP_DELTAMOVE		0x00100000L
#define IDCMP_VANILLAKEY	0x00200000L
#define IDCMP_INTUITICKS	0x00400000L
/*  for notifications from "boopsi" gadgets	*/
#define IDCMP_IDCMPUPDATE	0x00800000L  /* new for V36	*/
/* for getting help key report during menu session	*/
#define IDCMP_MENUHELP		0x01000000L  /* new for V36	*/
/* for notification of any move/size/zoom/change window		*/
#define IDCMP_CHANGEWINDOW	0x02000000L  /* new for V36	*/
#define IDCMP_GADGETHELP	0x04000000L  /* new for V39	*/

/* NOTEZ-BIEN:				0x80000000 is reserved for internal use   */

/* the IDCMP Flags do not use this special bit, which is cleared when
 * Intuition sends its special message to the Task, and set when Intuition
 * gets its Message back from the Task.  Therefore, I can check here to
 * find out fast whether or not this Message is available for me to send
 */
#define IDCMP_LONELYMESSAGE	0x80000000L


/* --- IDCMP Codes -------------------------------------------------------- */
/* This group of codes is for the IDCMP_CHANGEWINDOW message */
#define CWCODE_MOVESIZE	0x0000	/* Window was moved and/or sized */
#define CWCODE_DEPTH	0x0001	/* Window was depth-arranged (new for V39) */

/* This group of codes is for the IDCMP_MENUVERIFY message */
#define MENUHOT		0x0001	/* IntuiWants verification or MENUCANCEL    */
#define MENUCANCEL	0x0002	/* HOT Reply of this cancels Menu operation */
#define MENUWAITING	0x0003	/* Intuition simply wants a ReplyMsg() ASAP */

/* These are internal tokens to represent state of verification attempts
 * shown here as a clue.
 */
#define OKOK		MENUHOT	/* guy didn't care			*/
#define OKABORT		0x0004	/* window rendered question moot	*/
#define OKCANCEL	MENUCANCEL /* window sent cancel reply		*/

/* This group of codes is for the IDCMP_WBENCHMESSAGE messages */
#define WBENCHOPEN	0x0001
#define WBENCHCLOSE	0x0002


VOID OpenIntuition(void);
VOID Intuition(struct InputEvent * iEvent);
UWORD AddGadget(struct Window * window, struct Gadget * gadget, ULONG position);
BOOL ClearDMRequest(struct Window * window);
VOID ClearMenuStrip(struct Window * window);
VOID ClearPointer(struct Window * window);
BOOL CloseScreen(struct Screen * screen);
VOID CloseWindow(struct Window * window);
LONG CloseWorkBench(void);
VOID CurrentTime(ULONG * seconds, ULONG * micros);
BOOL DisplayAlert(ULONG alertNumber, const STRPTR string, ULONG height);
VOID DisplayBeep(struct Screen * screen);
BOOL DoubleClick(ULONG sSeconds, ULONG sMicros, ULONG cSeconds, ULONG cMicros);
VOID DrawBorder(struct RastPort * rp, const struct Border * border, LONG leftOffset,
	LONG topOffset);
VOID DrawImage(struct RastPort * rp, struct Image * image, LONG leftOffset,
	LONG topOffset);
VOID EndRequest(struct Requester * requester, struct Window * window);
struct Preferences * GetDefPrefs(struct Preferences * preferences, LONG size);
struct Preferences * GetPrefs(struct Preferences * preferences, LONG size);
VOID InitRequester(struct Requester * requester);
struct MenuItem * ItemAddress(const struct Menu * menuStrip, ULONG menuNumber);
BOOL ModifyIDCMP(struct Window * window, ULONG flags);
VOID ModifyProp(struct Gadget * gadget, struct Window * window,
	struct Requester * requester, ULONG flags, ULONG horizPot,
	ULONG vertPot, ULONG horizBody, ULONG vertBody);
VOID MoveScreen(struct Screen * screen, LONG dx, LONG dy);
VOID MoveWindow(struct Window * window, LONG dx, LONG dy);
VOID OffGadget(struct Gadget * gadget, struct Window * window,
	struct Requester * requester);
VOID OffMenu(struct Window * window, ULONG menuNumber);
VOID OnGadget(struct Gadget * gadget, struct Window * window,
	struct Requester * requester);
VOID OnMenu(struct Window * window, ULONG menuNumber);
struct Screen * OpenScreen(const struct NewScreen * newScreen);
struct Window * OpenWindow(const struct NewWindow * newWindow);
ULONG OpenWorkBench(void);
VOID PrintIText(struct RastPort * rp, const struct IntuiText * iText, LONG left,
	LONG top);
VOID RefreshGadgets(struct Gadget * gadgets, struct Window * window,
	struct Requester * requester);
UWORD RemoveGadget(struct Window * window, struct Gadget * gadget);
VOID ReportMouse(LONG flag, struct Window * window);
VOID ReportMouse1(struct Window * flag, LONG window);
BOOL Request(struct Requester * requester, struct Window * window);
VOID ScreenToBack(struct Screen * screen);
VOID ScreenToFront(struct Screen * screen);
BOOL SetDMRequest(struct Window * window, struct Requester * requester);
BOOL SetMenuStrip(struct Window * window, struct Menu * menu);
VOID SetPointer(struct Window * window, UWORD * pointer, LONG height, LONG width,
	LONG xOffset, LONG yOffset);
VOID SetWindowTitles(struct Window * window, const STRPTR windowTitle,
	const STRPTR screenTitle);
VOID ShowTitle(struct Screen * screen, LONG showIt);
VOID SizeWindow(struct Window * window, LONG dx, LONG dy);
struct View * ViewAddress(void);
struct ViewPort * ViewPortAddress(const struct Window * window);
VOID WindowToBack(struct Window * window);
VOID WindowToFront(struct Window * window);
BOOL WindowLimits(struct Window * window, LONG widthMin, LONG heightMin, ULONG widthMax,
	ULONG heightMax);
struct Preferences  * SetPrefs(const struct Preferences * preferences, LONG size,
	LONG inform);
LONG IntuiTextLength(const struct IntuiText * iText);
BOOL WBenchToBack(void);
BOOL WBenchToFront(void);
BOOL AutoRequest(struct Window * window, const struct IntuiText * body,
	const struct IntuiText * posText, const struct IntuiText * negText,
	ULONG pFlag, ULONG nFlag, ULONG width, ULONG height);
VOID BeginRefresh(struct Window * window);
struct Window * BuildSysRequest(struct Window * window, const struct IntuiText * body,
	const struct IntuiText * posText, const struct IntuiText * negText,
	ULONG flags, ULONG width, ULONG height);
VOID EndRefresh(struct Window * window, LONG complete);
VOID FreeSysRequest(struct Window * window);
VOID MakeScreen(struct Screen * screen);
VOID RemakeDisplay(void);
VOID RethinkDisplay(void);
void * AllocRemember(struct Remember ** rememberKey, ULONG size, ULONG flags);
VOID FreeRemember(struct Remember ** rememberKey, LONG reallyForget);
ULONG LockIBase(ULONG dontknow);
VOID UnlockIBase(ULONG ibLock);
LONG GetScreenData(void * buffer, ULONG size, ULONG type, const struct Screen * screen);
VOID RefreshGList(struct Gadget * gadgets, struct Window * window,
	struct Requester * requester, LONG numGad);
UWORD AddGList(struct Window * window, struct Gadget * gadget, ULONG position,
	LONG numGad, struct Requester * requester);
UWORD RemoveGList(struct Window * remPtr, struct Gadget * gadget, LONG numGad);
VOID ActivateWindow(struct Window * window);
VOID RefreshWindowFrame(struct Window * window);
BOOL ActivateGadget(struct Gadget * gadgets, struct Window * window,
	struct Requester * requester);
VOID NewModifyProp(struct Gadget * gadget, struct Window * window,
	struct Requester * requester, ULONG flags, ULONG horizPot,
	ULONG vertPot, ULONG horizBody, ULONG vertBody, LONG numGad);

#endif	/*  CLIB_INTUITION_PROTOS_H  */
