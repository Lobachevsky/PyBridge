:Namespace TestPyClt

    port←5000 

    ∇ Run;pc
      :If 0=⎕NC'#.DRC'
          'DRC'#.⎕CY'conga.dws'
      :EndIf
     
      pc←⎕NEW #.PyClt
      pc.Connect port
     
      assert 4=pc.Eval'2+2'
      {}pc.Assign'abc'(1 2 3)
      assert 1 2 3≡pc.Eval'abc'
      {}pc.Exec'd = [4,5,6]'
      assert(⍳6)≡pc.Eval'abc+d'
⍝      'Python Exception'(pc.Eval expecterror)'2/0'
    ∇
    
    

    assert←{'Assertion failed'⎕SIGNAL(⍵=0)/11}

      time←{⍺←⊣ ⋄ t←⎕AI[3]
          o←output TEST,' ... '
          z←⍺ ⍺⍺ ⍵
          o←output(⍕⎕AI[3]-t),'ms',⎕UCS 10
          z
      }

      expecterror←{
          0::⎕SIGNAL(⍺≡⊃⎕DMX.DM)↓11
          z←⍺⍺ ⍵
          ⎕SIGNAL 11
      }




:EndNamespace