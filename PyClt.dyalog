:Class PyClt      

    ⎕IO←⎕ML←1   ⍝ Very Ordinary
    EOL←⎕UCS 10 ⍝ Python seems happy with this 
    
    fromJSON←7159⌶ ⋄ toJSON←7160⌶
    
    :Field Public Instance Host←'127.0.0.1' 
    :Field Public Instance TimeOut←10000 ⍝ 10 seconds                    
                      
    ∇ Default
      :Implements Constructor
      :Access Public
    ∇

    ∇ make1 port
      :Implements Constructor
      :Access Public
      Connect port
    ∇

    ∇ Connect port;z
      :Access Public
     
      :If ~0=⊃z←#.DRC.Init''
          ('Unable to initialise CONGA: ',⍕z)⎕SIGNAL 11 ⍝ morten was here
      :EndIf
     
      :If ~0=⊃z←#.DRC.Clt''Host port'Text'
      :AndIf ~0=⊃z←#.DRC.Clt''Host port'Text'⊣⎕DL 1
      :AndIf ~0=⊃z←#.DRC.Clt''Host port'Text'⊣⎕DL 3
          ('Unable to connect to PyServer on port ',(⍕port),': ',⍕z)⎕SIGNAL 11
      :Else
          CONN←2⊃z
      :EndIf
    ∇
     
    ∇ Close;z
      :Implements Destructor  
      :If 2=⎕NC'CONN'
          :Trap 0
              z←Quit
          :EndTrap
      :EndIf
    ∇
                           
    ∇ r←DMX
    ⍝ Re-signallable DMX
      r←⊂'EN' 'EM' 'Message',⍪⎕DMX.(EN EM Message)
    ∇
   
    ∇ r←Invoke args;ns;fn
      :Access Public Instance
      fn←⊃args ⋄ args←1↓args
      'No more than 3 args'⎕SIGNAL(3<≢args)/11
      (ns←⎕NS'').(fn args)←(,fn)args
      :Trap 0 ⋄ r←(⍕≢args)do toJSON ns
      :Else ⋄ ⎕SIGNAL DMX
      :EndTrap
    ∇
    
    ∇ r←Assign(name value)
      :Access Public Instance
     
      (ns←⎕NS'').(name value)←(,name)value
      :Trap 0 ⋄ r←'A'do toJSON ns
      :Else ⋄ ⎕SIGNAL DMX
      :EndTrap
    ∇

    ∇ r←Eval expr;ns
      :Access Public Instance
      (ns←⎕NS'').expr←,expr
      :Trap 0 ⋄ r←'0'do toJSON ns
      :Else ⋄ ⎕SIGNAL DMX
      :EndTrap
     
      :If 9=⎕NC'r'
          r.⎕DF'[Python: ',expr,']'
      :EndIf
    ∇
    
    ∇ r←Exec expr;ns
      :Access Public Instance
      (ns←⎕NS'').expr←,expr
     
      :Trap 0 ⋄ r←'X'do toJSON ns
      :Else ⋄ ⎕SIGNAL DMX
      :EndTrap
    ∇
                    
    ∇ r←Quit
      :Access Public Instance     
      r←'Q'do toJSON'Bye'
    ∇

    ∇ r←cmd do json;z;done;ns;json;len
      ⍝ Execute a Python expression and return the result
     
      len←⎕UCS(8⍴256)⊤≢json
     
      :If ~0=⊃z←#.DRC.Send CONN((len,cmd),json)
          ('Send failed: ',⍕z)⎕SIGNAL 11
      :EndIf
     
      r←'' ⋄ len←¯1
      :Repeat
          :Select ⊃z←#.DRC.Wait CONN TimeOut
          :Case 0   ⍝ Success
              :Select 3⊃z
              :Case 'Block' ⍝ That's what we want
                  r,←4⊃z
                  :If (len=¯1)∧8≤⍴r ⋄ len←256⊥⎕UCS 8↑r ⋄ len←256⊥⎕UCS 8↑r ⋄ r←8↓r ⋄ :EndIf
                  :If done←len=≢r
                      :Select ⊃r
                      :Case '0' ⋄ r←fromJSON 1↓r
                      :Case 'E' ⋄ ⎕SIGNAL⊂('EN' 11)('EM' 'Python Exception')('Message'(1↓r))
                      :CaseList '12' ⋄ r←1↓r
                      :EndSelect
                  :EndIf
              :Case 'Error'
                  :If (cmd='Q')∧1105=4⊃z
                      z←#.DRC.Close CONN
                      ⎕EX'CONN'
                      done←1
                  :Else
                      ∘∘∘
                  :EndIf
              :Else
                  ∘∘∘
              :EndSelect
          :Case 100 ⍝ Timeout
              'TIMEOUT'⎕SIGNAL 11
          :EndSelect
      :Until done
     
    ∇

:EndClass