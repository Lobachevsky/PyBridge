:Class Bender : PyClt      

    ⎕IO←⎕ML←1   ⍝ Very Ordinary


    ∇ Init
      :Access Public Shared
      
      :If 0=⎕NC '#.DRC' 
          'DRC' #.⎕CY 'conga.dws' 
          ⎕←'DRC copied from conga.dws' 
      :EndIf

      :If 9≠⎕NC '#.APLProcess'
          ∘∘∘
          ⎕←'APLProcess class is not present - will not be unable to launch Blender'
      :EndIf
    ∇

    ∇ Default
     :Access Public
     :Implements Constructor

      :If 9≠⎕NC '#.APLProcess'
          ∘∘∘
          ⎕←'APLProcess class is not present - will not be unable to launch Blender'
      :EndIf

        
     
    ∇

:EndClass