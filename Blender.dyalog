:Class Blender : PyClt      

    ⎕IO←⎕ML←1   ⍝ Very Ordinary

    :Field Public BlenderEXE←'C:\Program Files\Blender Foundation\Blender\blender.exe'
    :Field Public ServerScript←'c:\devt\PyBridge\server.py'
    :Field Public BlenderProc←⎕NS ''

    ∇ Init
      :Access Public Shared
     
      :If 0=⎕NC'#.DRC'
          'DRC'#.⎕CY'conga.dws'
          ⎕←'DRC copied form conga.dws'
      :EndIf
    ∇
    
    ∇ Default
      :Access Public
      :Implements Constructor
     
      BlenderProc←⎕NEW #.APLProcess(''('--python-console --python "',ServerScript,'"')BlenderEXE)
      ∘∘∘
    ∇

:EndClass