
# parsetab.py
# This file is automatically generated. Do not edit.
# pylint: disable=W,C,R
_tabversion = '3.10'

_lr_method = 'LALR'

_lr_signature = 'COLON COMMA FALSE LBRACE LBRACKET NULL NUMBER RBRACE RBRACKET STRING TRUEvalue : STRING\n             | NUMBER\n             | TRUE\n             | FALSE\n             | NULL\n             | object\n             | arrayobject : LBRACE RBRACE\n              | LBRACE members RBRACEmembers : STRING COLON value\n               | members COMMA STRING COLON valuearray : LBRACKET RBRACKET\n             | LBRACKET elements RBRACKETelements : value\n                | elements COMMA value'
    
_lr_action_items = {'STRING':([0,9,10,18,19,21,25,],[2,13,2,22,2,2,2,]),'NUMBER':([0,10,19,21,25,],[3,3,3,3,3,]),'TRUE':([0,10,19,21,25,],[4,4,4,4,4,]),'FALSE':([0,10,19,21,25,],[5,5,5,5,5,]),'NULL':([0,10,19,21,25,],[6,6,6,6,6,]),'LBRACE':([0,10,19,21,25,],[9,9,9,9,9,]),'LBRACKET':([0,10,19,21,25,],[10,10,10,10,10,]),'$end':([1,2,3,4,5,6,7,8,11,14,17,20,],[0,-1,-2,-3,-4,-5,-6,-7,-8,-12,-9,-13,]),'RBRACKET':([2,3,4,5,6,7,8,10,11,14,15,16,17,20,24,],[-1,-2,-3,-4,-5,-6,-7,14,-8,-12,20,-14,-9,-13,-15,]),'COMMA':([2,3,4,5,6,7,8,11,12,14,15,16,17,20,23,24,26,],[-1,-2,-3,-4,-5,-6,-7,-8,18,-12,21,-14,-9,-13,-10,-15,-11,]),'RBRACE':([2,3,4,5,6,7,8,9,11,12,14,17,20,23,26,],[-1,-2,-3,-4,-5,-6,-7,11,-8,17,-12,-9,-13,-10,-11,]),'COLON':([13,22,],[19,25,]),}

_lr_action = {}
for _k, _v in _lr_action_items.items():
   for _x,_y in zip(_v[0],_v[1]):
      if not _x in _lr_action:  _lr_action[_x] = {}
      _lr_action[_x][_k] = _y
del _lr_action_items

_lr_goto_items = {'value':([0,10,19,21,25,],[1,16,23,24,26,]),'object':([0,10,19,21,25,],[7,7,7,7,7,]),'array':([0,10,19,21,25,],[8,8,8,8,8,]),'members':([9,],[12,]),'elements':([10,],[15,]),}

_lr_goto = {}
for _k, _v in _lr_goto_items.items():
   for _x, _y in zip(_v[0], _v[1]):
       if not _x in _lr_goto: _lr_goto[_x] = {}
       _lr_goto[_x][_k] = _y
del _lr_goto_items
_lr_productions = [
  ("S' -> value","S'",1,None,None,None),
  ('value -> STRING','value',1,'p_value','try_ply.py',22),
  ('value -> NUMBER','value',1,'p_value','try_ply.py',23),
  ('value -> TRUE','value',1,'p_value','try_ply.py',24),
  ('value -> FALSE','value',1,'p_value','try_ply.py',25),
  ('value -> NULL','value',1,'p_value','try_ply.py',26),
  ('value -> object','value',1,'p_value','try_ply.py',27),
  ('value -> array','value',1,'p_value','try_ply.py',28),
  ('object -> LBRACE RBRACE','object',2,'p_object','try_ply.py',32),
  ('object -> LBRACE members RBRACE','object',3,'p_object','try_ply.py',33),
  ('members -> STRING COLON value','members',3,'p_members','try_ply.py',37),
  ('members -> members COMMA STRING COLON value','members',5,'p_members','try_ply.py',38),
  ('array -> LBRACKET RBRACKET','array',2,'p_array','try_ply.py',42),
  ('array -> LBRACKET elements RBRACKET','array',3,'p_array','try_ply.py',43),
  ('elements -> value','elements',1,'p_elements','try_ply.py',47),
  ('elements -> elements COMMA value','elements',3,'p_elements','try_ply.py',48),
]
