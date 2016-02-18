:Class Blender : PyClt      

    ⎕IO←⎕ML←1   ⍝ Very Ordinary


    ∇ Init
      :Access Public Shared
     
      :If 0=⎕NC'#.DRC'
          'DRC'#.⎕CY'conga.dws'
          ⎕←'DRC copied form conga.dws'
      :EndIf
    ∇

:EndClass