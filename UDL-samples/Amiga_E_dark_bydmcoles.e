-> gradientslider in E!

MODULE 'intuition/intuition', 'intuition/gadgetclass', 'intuition/icclass',
       'gadgets/gradientslider'

DEF w:PTR TO window, grad:PTR TO gadget, gradbase, class, val

PROC main()
  IF w:=OpenWindowTagList(NIL,[WA_FLAGS,$E,WA_IDCMP,$268,WA_WIDTH,400,WA_HEIGHT,80,WA_TITLE,'Gradients in E!',0])
    SetStdRast(w.rport)
    IF gradbase:=OpenLibrary('gadgets/gradientslider.gadget',39)
      IF grad:=NewObjectA(NIL,'gradientslider.gadget',[GA_TOP,20,GA_LEFT,20,GA_WIDTH,350,GA_HEIGHT,30,GA_ID,1,GRAD_PENARRAY,[0,7,-1]:INT,GRAD_KNOBPIXELS,20,0])
        AddGList(w,grad,-1,-1,NIL)
        RefreshGList(grad,w,NIL,-1)
        WHILE (class:=WaitIMessage(w))<>IDCMP_CLOSEWINDOW
          GetAttr(GRAD_CURVAL,grad,{val})
          TextF(20,60,'gradient value = \z$\h[4]',val)
        ENDWHILE
        RemoveGList(w,grad,-1)
        DisposeObject(grad)
      ELSE
        WriteF('Could not create GradientSlider!\n')
      ENDIF
      CloseLibrary(gradbase)
    ELSE
      WriteF('Could not open "gradientslider.gadget"\n')
    ENDIF
    CloseWindow(w)
  ELSE
    WriteF('No Window!\n')
  ENDIF
ENDPROC
