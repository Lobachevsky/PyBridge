:Class Blender : PyClt      

    ⎕IO←⎕ML←1   ⍝ Very Ordinary
    
    :Field Public Shared BlenderExe←'"C:\Program Files\Blender Foundation\Blender\blender.exe"'
    :Field Public Shared SrvScript←'"c:\devt\pybridge\server.py"' 

    :Field Public Instance Proc←''   

    ∇ Init
      :Access Public Shared
     
      :If 0=⎕NC'#.DRC'
          'DRC'#.⎕CY'conga.dws'
          ⎕←'DRC copied from conga.dws'
      :EndIf
     
      :If 9≠⎕NC'#.APLProcess'
          ⎕←'APLProcess class is not present - will not be unable to launch Blender'
      :EndIf
    ∇

    ∇ make2(port args)
      :Access Public
     
      :If ~0≡args
          Proc←⎕NEW #.APLProcess(''(args,' --python-exit-code 1 --disable-abort-handler -P ',SrvScript,' -- ',(⍕port))BlenderExe)
      :EndIf
     
      :Implements Constructor :Base port
    ∇
    
    ∇ unmake
      :Implements Destructor
    ⍝  ∘∘∘
    ∇
:EndClass