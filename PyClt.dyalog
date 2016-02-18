:Class PyClt      

    ⎕IO←⎕ML←1   ⍝ Very Ordinary
    EOL←⎕UCS 10 ⍝ Python seems happy with this 
    
    fromJSON←7159⌶ ⋄ toJSON←7160⌶
    
    :Field Public Instance Host←'127.0.0.1'                     
                      
    ∇ Default
      :Implements Constructor
      :Access Public
      Connect 5000
    ∇

    ∇ Connect port;z
      :Implements Constructor 
      :Access Public
     
      :If ~0=⊃z←#.DRC.Init''
          ('Unable to initialise CONGA: ',⍕z)⎕SIGNAL 11 ⍝ morten was here
      :EndIf
     
      :If ~0=⊃z←#.DRC.Clt''Host port'Text'
          ('Unable to connect to PyServer on port ',(⍕port),': ',⍕z)⎕SIGNAL 11
      :Else
          CONN←2⊃z
      :EndIf
    ∇
     
    ∇ Close;z
      :Implements Destructor  
      :If 2=⎕NC'CONN'
          z←#.DRC.Close CONN
      :EndIf
    ∇
    
    ∇ r←P expr
      :Access Public Instance
      r←X'print(',expr,')'
    ∇
   
   
    ∇ r←Call(fn arg);ns
      :Access Public Instance
      (ns←⎕NS'').(fn arg)←(,fn)arg
      r←'1'do toJSON ns
    ∇
    
    ∇ r←Eval expr;ns
      :Access Public Instance
      (ns←⎕NS'').expr←expr
      r←'0'do toJSON ns
    ∇
    
    ∇ r←Exec expr;ns
      :Access Public Instance
      (ns←⎕NS'').expr←expr
      r←'X'do toJSON ns
    ∇
    

    ∇ r←cmd do json;z;done;ns;json;len
      ⍝ Execute a Python expression and return the result
     
      len←⎕UCS(8⍴256)⊤≢json
     
      :If ~0=⊃z←#.DRC.Send CONN((len,cmd),json)
          ('Send failed: ',⍕z)⎕SIGNAL 11
      :EndIf
     
      r←'' ⋄ len←¯1
      :Repeat
          :Select ⊃z←#.DRC.Wait CONN
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
              :Else
                  ∘∘∘
              :EndSelect
          :Case 100 ⍝ Timeout
              'TIMEOUT'⎕SIGNAL 11
          :EndSelect
      :Until done
     
    ∇

:EndClass